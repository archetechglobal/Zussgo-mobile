// supabase/functions/send-chat-notification/index.ts
//
// Called fire-and-forget after every message insert.
// Looks up the OTHER participant in the connection, fetches their FCM token,
// and sends a chat push notification via Firebase FCM HTTP v1.
// Uses the same Firebase OAuth2 RSA signing pattern as send-match-notification.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

async function getAccessToken(serviceAccount: Record<string, string>): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header  = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss:   serviceAccount.client_email,
    sub:   serviceAccount.client_email,
    aud:   "https://oauth2.googleapis.com/token",
    iat:   now,
    exp:   now + 3600,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  };

  const encode = (obj: object) =>
    btoa(JSON.stringify(obj))
      .replace(/\+/g, "-")
      .replace(/\//g, "_")
      .replace(/=+$/, "");

  const signingInput = `${encode(header)}.${encode(payload)}`;

  const pemBody = serviceAccount.private_key
    .replace(/-----BEGIN RSA PRIVATE KEY-----|-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END RSA PRIVATE KEY-----|-----END PRIVATE KEY-----/g, "")
    .replace(/\s/g, "");

  const keyData = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    keyData,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(signingInput)
  );

  const jwt = `${signingInput}.${btoa(
    String.fromCharCode(...new Uint8Array(signature))
  ).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "")}`;

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion:  jwt,
    }),
  });

  const tokenData = await tokenRes.json();
  if (!tokenData.access_token) {
    throw new Error(`Failed to get access token: ${JSON.stringify(tokenData)}`);
  }
  return tokenData.access_token;
}

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
    const { connection_id, sender_id, content } = await req.json();

    if (!connection_id || !sender_id || !content) {
      return new Response(
        JSON.stringify({ error: "connection_id, sender_id, content are required" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // ── 1. Fetch the connection to find the OTHER participant ─────────────────
    const { data: conn, error: connErr } = await supabase
      .from("connections")
      .select("requester_id, receiver_id")
      .eq("id", connection_id)
      .single();

    if (connErr || !conn) {
      return new Response(
        JSON.stringify({ skipped: true, reason: "connection_not_found" }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    // The recipient is whoever is NOT the sender
    const recipientId = conn.requester_id === sender_id
      ? conn.receiver_id
      : conn.requester_id;

    // ── 2. Fetch recipient profile (FCM token + name) ─────────────────────────
    const { data: recipient, error: recipientErr } = await supabase
      .from("profiles")
      .select("fcm_token, name")
      .eq("id", recipientId)
      .single();

    if (recipientErr || !recipient?.fcm_token) {
      return new Response(
        JSON.stringify({ skipped: true, reason: "no_fcm_token" }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    // ── 3. Fetch sender name for the notification title ───────────────────────
    const { data: sender } = await supabase
      .from("profiles")
      .select("name")
      .eq("id", sender_id)
      .single();

    const senderName = sender?.name ?? "Someone";

    // Truncate long messages for the notification body
    const bodyPreview = content.length > 80
      ? content.substring(0, 77) + "..."
      : content;

    // ── 4. Get Firebase OAuth2 access token ──────────────────────────────────
    const serviceAccountRaw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
    if (!serviceAccountRaw) {
      throw new Error("FIREBASE_SERVICE_ACCOUNT secret not set");
    }
    const serviceAccount: Record<string, string> = JSON.parse(serviceAccountRaw);
    const projectId   = serviceAccount.project_id;
    const accessToken = await getAccessToken(serviceAccount);

    // ── 5. Send FCM push ──────────────────────────────────────────────────────
    const fcmRes = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            token: recipient.fcm_token,
            notification: {
              title: senderName,
              body:  bodyPreview,
            },
            data: {
              type:          "chat_message",
              connection_id: connection_id,
              sender_id:     sender_id,
            },
            android: {
              priority: "high",
              notification: {
                channel_id:    "zussgo_chat",
                default_sound: true,
              },
            },
          },
        }),
      }
    );

    if (!fcmRes.ok) {
      const err = await fcmRes.json();
      console.error("FCM send failed:", JSON.stringify(err));
      return new Response(
        JSON.stringify({ success: false, error: err }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({ success: true, recipient_id: recipientId }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (err) {
    console.error("send-chat-notification error:", err);
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
