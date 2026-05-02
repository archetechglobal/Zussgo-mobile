// supabase/functions/send-chat-notification/index.ts
// Sends an FCM push notification to the OTHER participant of a chat connection.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
);

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
    const { connection_id, sender_id, content } = await req.json();

    // 1. Find the connection to get both participants
    const { data: conn, error: connErr } = await supabase
      .from('connections')
      .select('requester_id, receiver_id')
      .eq('id', connection_id)
      .single();

    if (connErr || !conn) {
      return new Response(JSON.stringify({ error: 'connection not found' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // 2. Determine recipient (the participant who is NOT the sender)
    const recipientId =
      conn.requester_id === sender_id
        ? conn.receiver_id
        : conn.requester_id;

    // 3. Fetch recipient FCM token + sender name
    const [recipientRes, senderRes] = await Promise.all([
      supabase
        .from('profiles')
        .select('fcm_token')
        .eq('id', recipientId)
        .single(),
      supabase
        .from('profiles')
        .select('name')
        .eq('id', sender_id)
        .single(),
    ]);

    const fcmToken  = recipientRes.data?.fcm_token as string | null;
    const senderName = senderRes.data?.name as string ?? 'Someone';

    if (!fcmToken) {
      // Recipient has no FCM token — silently skip, not an error
      return new Response(JSON.stringify({ sent: false, reason: 'no_token' }), {
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // 4. Build notification body (truncate long plan-card messages)
    const body = content.startsWith('\u{1F4CD}')
      ? '📍 Sent you a place suggestion'
      : content.length > 80
      ? content.substring(0, 80) + '...'
      : content;

    // 5. Send via FCM HTTP v1
    const fcmProjectId = Deno.env.get('FCM_PROJECT_ID')!;
    const fcmKey       = Deno.env.get('FCM_SERVER_KEY')!;

    const fcmRes = await fetch(
      `https://fcm.googleapis.com/v1/projects/${fcmProjectId}/messages:send`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${fcmKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token:        fcmToken,
            notification: {
              title: senderName,
              body,
            },
            data: {
              type:          'chat_message',
              connection_id: connection_id,
              sender_id:     sender_id,
            },
            android: {
              priority: 'high',
              notification: { channel_id: 'chat_messages' },
            },
          },
        }),
      },
    );

    const fcmJson = await fcmRes.json();

    return new Response(
      JSON.stringify({ sent: true, fcm: fcmJson }),
      { headers: { 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: { 'Content-Type': 'application/json' } },
    );
  }
});
