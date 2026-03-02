/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />

import { serve } from "std/http/server.ts";
import { createClient } from "@supabase/supabase-js";
import { corsHeaders } from "../_shared/cors.ts";

// ─── Handler ───────────────────────────────────────────────────────────────────

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // ── Auth ───────────────────────────────────────────────────────────────
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ success: false, error: "Missing authorization", errorCode: "UNAUTHORIZED" }, 401);
    }
    const {
      data: { user },
      error: authError,
    } = await admin.auth.getUser(authHeader.replace("Bearer ", ""));
    if (authError || !user) {
      return jsonResponse({ success: false, error: "Invalid token", errorCode: "UNAUTHORIZED" }, 401);
    }

    const userId = user.id;

    // ── Recompute and return current summary ───────────────────────────────
    const { data: rows, error: rpcErr } = await admin.rpc("compute_wallet_summary", {
      p_user_id: userId,
    });
    if (rpcErr) {
      return jsonResponse({ success: false, error: rpcErr.message, errorCode: "RPC_ERROR" }, 500);
    }

    const row = Array.isArray(rows) ? rows[0] : rows;
    if (!row) {
      // No transactions yet — return empty summary
      return jsonResponse(
        {
          success: true,
          summary: {
            user_id: userId,
            total_earned: 0,
            total_unlocked: 0,
            total_pending: 0,
            total_redeemed: 0,
            available: 0,
          },
        },
        200,
      );
    }

    return jsonResponse({ success: true, summary: row }, 200);
  } catch (error) {
    return jsonResponse(
      { success: false, error: (error as Error).message, errorCode: "INTERNAL_ERROR" },
      500,
    );
  }
});

// ─── Helpers ───────────────────────────────────────────────────────────────────

function jsonResponse(data: unknown, status: number): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
