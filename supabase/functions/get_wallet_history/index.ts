/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
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

    // ── Pagination params ──────────────────────────────────────────────────
    const body = await req.json().catch(() => ({}));
    const limit: number = Math.min(Math.max(parseInt(body.limit ?? "20", 10), 1), 100);
    const offset: number = Math.max(parseInt(body.offset ?? "0", 10), 0);

    // ── Fetch paginated transaction history ────────────────────────────────
    const { data: rows, error: fetchErr, count } = await admin
      .from("wallet_transactions")
      .select("id, user_id, amount, type, reason, reference_id, created_at", { count: "exact" })
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .range(offset, offset + limit - 1);

    if (fetchErr) {
      return jsonResponse({ success: false, error: fetchErr.message, errorCode: "DB_ERROR" }, 500);
    }

    return jsonResponse(
      {
        success: true,
        transactions: rows ?? [],
        pagination: {
          total: count ?? 0,
          limit,
          offset,
          has_more: offset + limit < (count ?? 0),
        },
      },
      200,
    );
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
