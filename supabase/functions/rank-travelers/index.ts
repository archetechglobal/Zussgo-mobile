// supabase/functions/rank-travelers/index.ts
//
// Ranks a list of candidate travelers against the current user's profile
// using Perplexity sonar. Called non-blocking from aiRankedTravelersProvider
// in home_provider.dart whenever a user searches a destination.
//
// Request body:
//   destination   : string          — e.g. "Goa"
//   current_user  : object          — { vibes[], base_city, bio, budget, pace }
//   candidates    : object[]        — [{ id, vibes[], base_city, bio }]
//
// Response body:
//   { ranked: [{ id: string, score: number }] }  — sorted descending by score

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

const PERPLEXITY_API = 'https://api.perplexity.ai/chat/completions'

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin':  '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'authorization, content-type',
      },
    })
  }

  let body: { destination: string; current_user: Record<string, unknown>; candidates: Array<Record<string, unknown>> }
  try {
    body = await req.json()
  } catch {
    return new Response(JSON.stringify({ ranked: [] }), { status: 400 })
  }

  const { destination, current_user, candidates } = body

  if (!candidates?.length) {
    return new Response(JSON.stringify({ ranked: [] }), {
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const prompt = `You are a travel companion matching AI for ZussGo app.

Destination: ${destination}
Current user profile:
  vibes: ${JSON.stringify(current_user.vibes ?? [])}
  base_city: ${current_user.base_city ?? 'unknown'}
  budget: ${current_user.budget ?? 'any'}
  pace: ${current_user.pace ?? 'any'}
  bio: "${current_user.bio ?? ''}"

Candidates to rank:
${JSON.stringify(candidates, null, 2)}

Score each candidate 0.0–1.0 based on:
- Vibe compatibility with the current user
- Whether their base city suggests they are likely to travel to ${destination}
- Budget and pace compatibility if available
- Enthusiasm hinted in bio

Return ONLY a valid JSON array, nothing else:
[{"id":"...","score":0.0},{"id":"...","score":0.0}]
Sorted by score descending. Include all candidates.`

  try {
    const res = await fetch(PERPLEXITY_API, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('PERPLEXITY_API_KEY')}`,
        'Content-Type':  'application/json',
      },
      body: JSON.stringify({
        model:      'sonar',
        messages:   [{ role: 'user', content: prompt }],
        max_tokens: 800,
      }),
    })

    const json   = await res.json()
    const raw    = json?.choices?.[0]?.message?.content ?? '[]'

    // Strip potential markdown code fences before parsing
    const clean  = raw.replace(/```json?\n?/g, '').replace(/```/g, '').trim()
    const ranked = JSON.parse(clean)

    return new Response(JSON.stringify({ ranked }), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (err) {
    console.error('rank-travelers error:', err)
    // Return empty ranked list — client falls back to unranked gracefully
    return new Response(JSON.stringify({ ranked: [] }), {
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
