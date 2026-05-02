// supabase/functions/ai-spark-suggest/index.ts
// Returns a single AI-generated place suggestion based on typed chat text.
// Called with: { text, destination, start_date? }

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const PERPLEXITY_API_KEY = Deno.env.get('PERPLEXITY_API_KEY') ?? '';

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin':  '*',
        'Access-Control-Allow-Headers': 'authorization, content-type',
      },
    });
  }

  try {
    const { text, destination, start_date } = await req.json();

    if (!text || typeof text !== 'string') {
      return new Response(JSON.stringify({ error: 'text is required' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const dateContext = start_date
      ? `Trip starts: ${new Date(start_date).toDateString()}.`
      : '';

    const prompt = [
      `A traveler typed: "${text}"`,
      `Destination: ${destination || 'unknown'}.`,
      dateContext,
      'Suggest ONE specific real place or activity that matches what they typed.',
      'Respond ONLY with valid JSON (no markdown, no backticks):',
      '{',
      '  "place_name": "<specific place name>",',
      '  "category": "<one of: Beach, Cafe, Bar, Restaurant, Museum, Outdoors, Shopping, Hotel, Nightclub, Market, Culture, Place>",',
      '  "date": "<e.g. May 10 or Day 1>",',
      '  "time": "<e.g. 10:00 AM>",',
      '  "emoji": "<single relevant emoji>"',
      '}',
    ].join(' ');

    const aiRes = await fetch('https://api.perplexity.ai/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${PERPLEXITY_API_KEY}`,
        'Content-Type':  'application/json',
      },
      body: JSON.stringify({
        model: 'sonar',
        messages: [{ role: 'user', content: prompt }],
        max_tokens: 150,
        temperature: 0.4,
      }),
    });

    if (!aiRes.ok) {
      throw new Error(`Perplexity ${aiRes.status}`);
    }

    const aiJson  = await aiRes.json();
    const raw     = aiJson.choices?.[0]?.message?.content ?? '{}';
    // Strip any accidental markdown code fences
    const cleaned = raw.replace(/```[a-z]*\n?/gi, '').trim();
    const result  = JSON.parse(cleaned);

    return new Response(JSON.stringify(result), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (err) {
    // Return empty object — Flutter will fall back to local keyword map
    return new Response(JSON.stringify({}), {
      headers: { 'Content-Type': 'application/json' },
    });
  }
});
