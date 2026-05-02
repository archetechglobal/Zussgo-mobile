// supabase/functions/notify-trip-matches/index.ts
// Triggered fire-and-forget after a new trip is created.
// 1. Fetches candidate profiles with FCM tokens (excluding the creator)
// 2. Scores each candidate via Perplexity sonar AI
// 3. Inserts in-app notification rows + sends FCM push to each match

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { trip_id, destination, vibe, budget, intent } = await req.json()

    if (!trip_id) {
      return new Response(JSON.stringify({ error: 'trip_id required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // 1. Confirm the trip exists and get creator_id
    const { data: trip, error: tripErr } = await supabase
      .from('trips')
      .select('creator_id')
      .eq('id', trip_id)
      .single()

    if (tripErr || !trip) {
      return new Response(JSON.stringify({ error: 'Trip not found' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 2. Fetch candidate profiles (exclude creator, must have FCM token)
    const { data: candidates, error: candErr } = await supabase
      .from('profiles')
      .select('id, name, vibes, base_city, fcm_token')
      .neq('id', trip.creator_id)
      .not('fcm_token', 'is', null)
      .limit(200)

    if (candErr || !candidates || candidates.length === 0) {
      return new Response(JSON.stringify({ matched: 0 }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 3. AI scoring via Perplexity sonar
    const perplexityKey = Deno.env.get('PERPLEXITY_API_KEY')
    let matches: Array<{ user_id: string; score: number; reason: string }> = []

    if (perplexityKey) {
      try {
        const aiRes = await fetch('https://api.perplexity.ai/chat/completions', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${perplexityKey}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            model: 'sonar',
            messages: [
              {
                role: 'system',
                content: 'You are a travel companion matching engine. Return only valid JSON array, no markdown, no explanation.',
              },
              {
                role: 'user',
                content: `New trip posted:\ndestination: ${destination}\nvibe: ${vibe || 'any'}\nbudget: ${budget || 'any'}\nintent: "${intent || ''}"\n\nScore these users for compatibility (0.0 to 1.0). Only include users with score >= 0.65.\nUsers: ${JSON.stringify(candidates.map(c => ({ id: c.id, vibes: c.vibes, city: c.base_city })))}\n\nReturn JSON array only: [{ "user_id": "...", "score": 0.0-1.0, "reason": "one short sentence" }]`,
              },
            ],
            max_tokens: 1200,
          }),
        })

        const aiJson = await aiRes.json()
        const raw = aiJson?.choices?.[0]?.message?.content ?? '[]'
        // Strip any markdown code fences the model may wrap around JSON
        const cleaned = raw.replace(/```json\n?|\n?```/g, '').trim()
        matches = JSON.parse(cleaned)
      } catch (_) {
        // AI failed — fall back to notifying first 10 candidates
        matches = candidates.slice(0, 10).map((c: { id: string }) => ({
          user_id: c.id,
          score:   0.7,
          reason:  `New trip to ${destination} — might be a great fit for you!`,
        }))
      }
    } else {
      // No Perplexity key configured — notify first 10 as fallback
      matches = candidates.slice(0, 10).map((c: { id: string }) => ({
        user_id: c.id,
        score:   0.7,
        reason:  `New trip to ${destination} — check it out!`,
      }))
    }

    if (matches.length === 0) {
      return new Response(JSON.stringify({ matched: 0 }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 4. Batch-insert in-app notifications + fire FCM pushes in parallel
    const fcmProject = Deno.env.get('FCM_PROJECT_ID')
    const fcmKey     = Deno.env.get('FCM_SERVER_KEY')

    const notifInserts: object[] = []
    const fcmPromises:  Promise<unknown>[] = []

    for (const match of matches) {
      const candidate = candidates.find((c: { id: string }) => c.id === match.user_id)
      if (!candidate) continue

      // In-app notification row
      notifInserts.push({
        user_id: match.user_id,
        type:    'trip_match',
        title:   `\u2708\uFE0F New trip to ${destination}`,
        body:    match.reason,
        data:    { trip_id, score: match.score, destination },
      })

      // FCM push — only if credentials are configured
      if (fcmKey && fcmProject && candidate.fcm_token) {
        fcmPromises.push(
          fetch(
            `https://fcm.googleapis.com/v1/projects/${fcmProject}/messages:send`,
            {
              method:  'POST',
              headers: {
                'Authorization': `Bearer ${fcmKey}`,
                'Content-Type':  'application/json',
              },
              body: JSON.stringify({
                message: {
                  token:        candidate.fcm_token,
                  notification: {
                    title: `\u2708\uFE0F Trip to ${destination}`,
                    body:  match.reason,
                  },
                  data: {
                    type:        'trip_match',
                    trip_id:     trip_id,
                    destination: destination,
                    match_score: String(match.score),
                  },
                  android: {
                    notification: {
                      channel_id: 'zussgo_matches',
                      priority:   'high',
                    },
                  },
                },
              }),
            }
          ).catch(() => null) // individual FCM failure never kills the batch
        )
      }
    }

    // Insert all notification rows in one round trip
    if (notifInserts.length > 0) {
      await supabase.from('notifications').insert(notifInserts)
    }

    // Fire all FCM requests concurrently
    await Promise.allSettled(fcmPromises)

    return new Response(
      JSON.stringify({ matched: matches.length }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    return new Response(
      JSON.stringify({ error: String(err) }),
      {
        status:  500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }
})
