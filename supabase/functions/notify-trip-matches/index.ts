// supabase/functions/notify-trip-matches/index.ts
//
// Triggered after a new trip is created.
// 1. Fetches candidate users (active, has FCM token, not the creator).
// 2. Scores each candidate against the trip using Perplexity AI.
// 3. For every match above the threshold:
//    - Inserts a row into `notifications`
//    - Sends an FCM push notification via Firebase Cloud Messaging HTTP v1

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const MATCH_THRESHOLD = 0.65; // minimum AI score to notify

serve(async (req: Request) => {
  try {
    const { trip_id, destination, vibe, budget, intent } = await req.json();

    if (!trip_id) {
      return new Response(JSON.stringify({ error: 'trip_id required' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    // ── 1. Fetch the new trip with creator info ─────────────────────────────
    const { data: trip, error: tripErr } = await supabase
      .from('trips')
      .select('id, creator_id, destination, vibe, budget, intent, dates')
      .eq('id', trip_id)
      .single();

    if (tripErr || !trip) {
      return new Response(JSON.stringify({ error: 'trip not found' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // ── 2. Fetch candidate profiles ─────────────────────────────────────────
    // Exclude the creator. Only users with an FCM token can be notified.
    const { data: candidates, error: candidatesErr } = await supabase
      .from('profiles')
      .select('id, name, vibes, base_city, fcm_token')
      .neq('id', trip.creator_id)
      .not('fcm_token', 'is', null);

    if (candidatesErr || !candidates || candidates.length === 0) {
      return new Response(JSON.stringify({ matched: 0, reason: 'no candidates' }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // ── 3. AI scoring via Perplexity ────────────────────────────────────────
    const perplexityKey = Deno.env.get('PERPLEXITY_API_KEY')!;

    const candidateSummary = candidates.map((c) => ({
      id: c.id,
      vibes: c.vibes ?? [],
      city: c.base_city ?? 'unknown',
    }));

    const prompt = [
      `A user just posted a new travel trip:`,
      `  Destination: ${destination || trip.destination}`,
      `  Vibe: ${vibe || trip.vibe || 'not specified'}`,
      `  Budget: ${budget || trip.budget || 'not specified'}`,
      `  Intent: "${intent || trip.intent || 'not specified'}"`,
      ``,
      `Here are potential travel companions (JSON):`,
      JSON.stringify(candidateSummary),
      ``,
      `For each candidate, return a JSON array with objects:`,
      `[{ "user_id": "<id>", "score": <0.0-1.0>, "reason": "<1 sentence why they match>" }]`,
      `Only include users with score >= ${MATCH_THRESHOLD}.`,
      `Return ONLY the JSON array, no explanation, no markdown.`,
    ].join('\n');

    const aiRes = await fetch('https://api.perplexity.ai/chat/completions', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${perplexityKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'sonar',
        messages: [{ role: 'user', content: prompt }],
        max_tokens: 1024,
        temperature: 0.2,
      }),
    });

    const aiJson = await aiRes.json();
    const rawContent: string = aiJson?.choices?.[0]?.message?.content ?? '[]';

    // Strip any accidental markdown code fences
    const cleaned = rawContent.replace(/```[\s\S]*?```/g, (m) =>
      m.replace(/```(?:json)?/g, '').trim(),
    ).trim();

    let matches: Array<{ user_id: string; score: number; reason: string }> = [];
    try {
      matches = JSON.parse(cleaned);
    } catch {
      // AI returned malformed JSON — log and exit gracefully
      console.error('AI JSON parse failed:', cleaned);
      return new Response(JSON.stringify({ matched: 0, reason: 'ai_parse_error' }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // ── 4. Notify each match ────────────────────────────────────────────────
    const fcmProjectId = Deno.env.get('FCM_PROJECT_ID')!;
    const fcmServerKey = Deno.env.get('FCM_SERVER_KEY')!;

    let notified = 0;

    for (const match of matches) {
      if (!match.user_id || match.score < MATCH_THRESHOLD) continue;

      const candidate = candidates.find((c) => c.id === match.user_id);
      if (!candidate) continue;

      const notifTitle = `✈️ New trip to ${trip.destination}`;
      const notifBody  = match.reason;

      // Insert in-app notification row
      await supabase.from('notifications').insert({
        user_id:   match.user_id,
        type:      'trip_match',
        title:     notifTitle,
        body:      notifBody,
        data: {
          trip_id:     trip.id,
          destination: trip.destination,
          match_score: match.score,
        },
        is_read: false,
      });

      // Send FCM push (HTTP v1)
      if (candidate.fcm_token) {
        await fetch(
          `https://fcm.googleapis.com/v1/projects/${fcmProjectId}/messages:send`,
          {
            method: 'POST',
            headers: {
              Authorization: `Bearer ${fcmServerKey}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              message: {
                token: candidate.fcm_token,
                notification: {
                  title: notifTitle,
                  body:  notifBody,
                },
                data: {
                  type:        'trip_match',
                  trip_id:     trip.id,
                  destination: trip.destination,
                  match_score: String(match.score),
                },
                android: {
                  priority: 'high',
                  notification: {
                    channel_id:   'zussgo_matches',
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                  },
                },
              },
            }),
          },
        ).catch(() => {}); // per-user FCM failure should not abort the loop
      }

      notified++;
    }

    return new Response(
      JSON.stringify({ matched: notified, total_candidates: candidates.length }),
      { status: 200, headers: { 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    console.error('notify-trip-matches error:', err);
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});
