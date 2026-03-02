/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />

import { serve } from "std/http/server.ts";
import { createClient } from "@supabase/supabase-js";
import { corsHeaders } from "../_shared/cors.ts";

// ─── Types ─────────────────────────────────────────────────────────────────────

interface AssignResult {
  assigned: boolean;
  count?: number;
  reason?: string;
}

interface AssignResponse {
  success: boolean;
  result?: AssignResult;
  error?: string;
  errorCode?: string;
}

// ─── Handler ───────────────────────────────────────────────────────────────────

serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url = new URL(req.url);
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

  // ── Auth ────────────────────────────────────────────────────────────────
  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader.startsWith("Bearer ")) {
    return json({ success: false, error: "Missing authorization", errorCode: "UNAUTHORIZED" }, 401);
  }

  const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: { user }, error: authErr } = await userClient.auth.getUser();
  if (authErr || !user) {
    return json({ success: false, error: "Unauthorized", errorCode: "UNAUTHORIZED" }, 401);
  }

  // Allow admin override via query param ?user_id=... (service role only)
  const queryUserId = url.searchParams.get("user_id");
  let targetUserId = user.id;
  if (queryUserId) {
    const adminHeader = req.headers.get("X-Service-Role-Key") ?? "";
    if (adminHeader !== serviceRoleKey) {
      return json({ success: false, error: "Forbidden", errorCode: "FORBIDDEN" }, 403);
    }
    targetUserId = queryUserId;
  }

  const sb = createClient(supabaseUrl, serviceRoleKey);

  try {
    const { data, error } = await sb.rpc("assign_weekly_missions", {
      p_user_id: targetUserId,
    });

    if (error) {
      console.error("assign_weekly_missions RPC error:", error);
      return json({
        success: false,
        error: error.message,
        errorCode: "RPC_ERROR",
      }, 500);
    }

    const result = data as AssignResult;
    return json({ success: true, result });
  } catch (err) {
    console.error("assign_weekly_missions edge fn error:", err);
    return json({ success: false, error: String(err), errorCode: "INTERNAL" }, 500);
  }
});

function json(body: AssignResponse, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
