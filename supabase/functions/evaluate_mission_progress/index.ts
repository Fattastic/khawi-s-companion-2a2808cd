/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />

import { serve } from "std/http/server.ts";
import { createClient } from "@supabase/supabase-js";
import { corsHeaders } from "../_shared/cors.ts";

// ─── Types ─────────────────────────────────────────────────────────────────────

interface MissionUpdateResult {
  mission_id: string;
  category: string;
  new_count: number;
  target: number;
  completed: boolean;
}

interface EvalResult {
  missions_updated: MissionUpdateResult[];
}

interface EvalResponse {
  success: boolean;
  result?: EvalResult;
  error?: string;
  errorCode?: string;
}

// ─── Handler ───────────────────────────────────────────────────────────────────

serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";

  // ── Auth ────────────────────────────────────────────────────────────────
  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader.startsWith("Bearer ")) {
    return json({ success: false, error: "Missing authorization", errorCode: "UNAUTHORIZED" }, 401);
  }

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: { user }, error: authErr } = await userClient.auth.getUser();
  if (authErr || !user) {
    return json({ success: false, error: "Unauthorized", errorCode: "UNAUTHORIZED" }, 401);
  }

  // ── Body ────────────────────────────────────────────────────────────────
  let body: Record<string, unknown> = {};
  try {
    body = req.method === "POST" ? await req.json() : {};
  } catch (_) {
    // empty body is fine
  }

  const category = (body["category"] as string) ?? "commute";
  const validCategories = ["commute", "social", "safety", "general"];
  if (!validCategories.includes(category)) {
    return json({ success: false, error: "Invalid category", errorCode: "BAD_REQUEST" }, 400);
  }

  const increment = Math.max(1, Math.min(10, Number(body["increment"] ?? 1)));

  const sb = createClient(supabaseUrl, serviceRoleKey);

  try {
    const { data, error } = await sb.rpc("evaluate_mission_progress", {
      p_user_id: user.id,
      p_category: category,
      p_increment: increment,
    });

    if (error) {
      console.error("evaluate_mission_progress RPC error:", error);
      return json({
        success: false,
        error: error.message,
        errorCode: "RPC_ERROR",
      }, 500);
    }

    const raw = data as { missions_updated: unknown[] };
    const result: EvalResult = {
      missions_updated: (raw.missions_updated ?? []) as MissionUpdateResult[],
    };

    return json({ success: true, result });
  } catch (err) {
    console.error("evaluate_mission_progress edge fn error:", err);
    return json({ success: false, error: String(err), errorCode: "INTERNAL" }, 500);
  }
});

function json(body: EvalResponse, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
