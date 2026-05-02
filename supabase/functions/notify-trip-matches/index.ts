// supabase/functions/notify-trip-matches/index.ts
//
// Called (fire-and-forget) when a new trip is published.
// 1. Fetches all candidate profiles that have an FCM token (excluding creator).
// 2. Scores every candidate against the trip via the existing `match-score` function.
// 3. match-score internally calls `send-match-notification` for scores >= 75,
//    which handles Firebase OAuth2, FCM HTTP v1, dedup, and in-app notification inserts.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL              = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  try {
    const { trip_id, destination, vibe, budget, intent } = await req.json();

    if (!trip_id) {
      return new Response(JSON.stringify({ error: "trip_id required" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // ── 1. Fetch the trip ────────────────────────────────────────────────────
    const { data: trip, error: tripErr } = await supabase
      .from("trips")
      .select("id, creator_id, destination, vibe, budget, intent")
      .eq("id", trip_id)
      .single();

    if (tripErr || !trip) {
      return new Response(JSON.stringify({ error: "trip not found" }), {
        status: 404,
        headers: { "Content-Type": "application/json" },
      });
    }

    // ── 2. Fetch the creator profile ─────────────────────────────────────────
    const { data: creator } = await supabase
      .from("profiles")
      .select("id, name, vibes, base_city, budget, pace, accommodation, bio, age")
      .eq("id", trip.creator_id)
      .single();

    // ── 3. Fetch candidate profiles (not creator, has FCM token) ─────────────
    const { data: candidates, error: candErr } = await supabase
      .from("profiles")
      .select("id, name, vibes, base_city, budget, pace, accommodation, bio, age, fcm_token")
      .neq("id", trip.creator_id)
      .not("fcm_token", "is", null);

    if (candErr || !candidates || candidates.length === 0) {
      return new Response(
        JSON.stringify({ matched: 0, reason: "no_candidates" }),
        { status: 200, headers: { "Content-Type": "application/json" } },
      );
    }

    const tripDest   = destination || trip.destination;
    const tripVibe   = vibe        || trip.vibe   || "";
    const tripBudget = budget      || trip.budget || "";

    // ── 4. Score each candidate via match-score (which fires push if score >= 75) ──
    let notified = 0;
    const results: Array<{ user_id: string; score: number; notificationSent: boolean }> = [];

    // Run in parallel batches of 5 to avoid hammering Perplexity rate limits
    const BATCH = 5;
    for (let i = 0; i < candidates.length; i += BATCH) {
      const batch = candidates.slice(i, i + BATCH);
      await Promise.all(
        batch.map(async (candidate) => {
          try {
            const res = await fetch(
              `${SUPABASE_URL}/functions/v1/match-score`,
              {
                method: "POST",
                headers: {
                  "Content-Type": "application/json",
                  // Service role key bypasses JWT verify on match-score
                  Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
                },
                body: JSON.stringify({
                  // viewer = the candidate being notified
                  viewer: {
                    id:            candidate.id,
                    name:          candidate.name,
                    age:           candidate.age,
                    baseCity:      candidate.base_city,
                    vibes:         candidate.vibes ?? [],
                    budget:        candidate.budget,
                    pace:          candidate.pace,
                    accommodation: candidate.accommodation,
                    bio:           candidate.bio,
                  },
                  // candidate = the trip creator
                  candidate: {
                    id:            creator?.id,
                    name:          creator?.name,
                    age:           creator?.age,
                    baseCity:      creator?.base_city,
                    vibes:         creator?.vibes ?? [],
                    budget:        creator?.budget,
                    pace:          creator?.pace,
                    accommodation: creator?.accommodation,
                    bio:           creator?.bio,
                  },
                  tripDestination: tripDest,
                  tripVibe:        tripVibe,
                  tripBudget:      tripBudget,
                  tripId:          trip.id,
                  silent:          false, // let match-score send the push
                }),
              },
            );

            const data = await res.json();
            results.push({
              user_id:          candidate.id,
              score:            data.score ?? 0,
              notificationSent: data.notificationSent === true,
            });
            if (data.notificationSent) notified++;
          } catch (e) {
            console.error(`Score failed for candidate ${candidate.id}:`, e);
          }
        }),
      );
    }

    return new Response(
      JSON.stringify({
        trip_id:          trip.id,
        destination:      tripDest,
        total_candidates: candidates.length,
        notified,
        results,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("notify-trip-matches error:", err);
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
