/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

// ─── Types ─────────────────────────────────────────────────────────────────────

interface NextAction {
  action_type: string;
  title_ar: string;
  title_en: string;
  subtitle_ar: string;
  subtitle_en: string;
  potential_xp: number;
  deep_link: string | null;
  expires_at: string | null;
  /** Human-readable explainability reason (GAMI-304) */
  reason: string;
  /** 0.0–1.0 confidence score (GAMI-304) */
  confidence_score: number;
}

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
      return jsonResponse(
        { success: false, error: "Missing authorization", errorCode: "UNAUTHORIZED" },
        401,
      );
    }
    const token = authHeader.replace("Bearer ", "");
    const {
      data: { user },
      error: authError,
    } = await admin.auth.getUser(token);
    if (authError || !user) {
      return jsonResponse(
        { success: false, error: "Invalid token", errorCode: "UNAUTHORIZED" },
        401,
      );
    }

    const userId = user.id;

    // ── Input ──────────────────────────────────────────────────────────────
    const body = await req.json().catch(() => ({}));
    const role: string = body.role ?? "passenger";

    // ── Fetch streak + missions state ──────────────────────────────────────
    const weekStart = getWeekStart();

    const [streakResult, missionsResult] = await Promise.all([
      admin
        .from("user_streaks")
        .select("current_count, status, grace_expires_at")
        .eq("user_id", userId)
        .maybeSingle(),

      admin
        .from("user_missions")
        .select("id, title_ar, title_en, category, current_count, target_count, reward_xp, status, expires_at")
        .eq("user_id", userId)
        .gte("week_start", weekStart)
        .eq("status", "active")
        .order("created_at", { ascending: true }),
    ]);

    const streak = streakResult.data;
    const missions = missionsResult.data ?? [];

    // ── Compute NBA ────────────────────────────────────────────────────────
    const action = computeNextAction(streak, missions, role);

    return jsonResponse({ success: true, next_action: action }, 200);
  } catch (error) {
    return jsonResponse(
      {
        success: false,
        error: (error as Error).message,
        errorCode: "INTERNAL_ERROR",
      },
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

function getWeekStart(): string {
  const d = new Date();
  const day = d.getDay();
  const diff = d.getDate() - day + (day === 0 ? -6 : 1);
  const monday = new Date(d.setDate(diff));
  monday.setHours(0, 0, 0, 0);
  return monday.toISOString().slice(0, 10);
}

function computeNextAction(
  streak: Record<string, unknown> | null,
  missions: Record<string, unknown>[],
  _role: string,
): NextAction | null {
  // 1. Streak in grace — recovery opportunity (highest priority)
  if (streak && streak.status === "grace") {
    return {
      action_type: "recover_streak",
      title_ar: "استعد سلسلتك!",
      title_en: "Recover your streak!",
      subtitle_ar: `أكمل رحلة قبل انتهاء فترة السماح لاستعادة ${streak.current_count} يوم`,
      subtitle_en: `Complete a trip before grace expires to restore your ${streak.current_count}-day streak`,
      potential_xp: 50,
      deep_link: "/trips/new",
      expires_at: (streak.grace_expires_at as string) ?? null,
      reason: "streak_in_grace",
      confidence_score: 0.95,
    };
  }

  // 2. Nearest-to-complete mission (≥70% progress)
  const nearComplete = missions
    .filter((m) => {
      const target = (m.target_count as number) ?? 1;
      const current = (m.current_count as number) ?? 0;
      return target > 0 && current / target >= 0.7;
    })
    .sort((a, b) => {
      const ratioA = ((a.current_count as number) ?? 0) / ((a.target_count as number) ?? 1);
      const ratioB = ((b.current_count as number) ?? 0) / ((b.target_count as number) ?? 1);
      return ratioB - ratioA;
    })[0];

  if (nearComplete) {
    const remaining =
      ((nearComplete.target_count as number) ?? 1) -
      ((nearComplete.current_count as number) ?? 0);
    const ratio =
      ((nearComplete.current_count as number) ?? 0) /
      ((nearComplete.target_count as number) ?? 1);
    return {
      action_type: "complete_mission",
      title_ar: (nearComplete.title_ar as string) ?? "",
      title_en: (nearComplete.title_en as string) ?? "",
      subtitle_ar: `${remaining} مهمة متبقية لإكمالها`,
      subtitle_en: `${remaining} more to complete this mission`,
      potential_xp: (nearComplete.reward_xp as number) ?? 0,
      deep_link: null,
      expires_at: (nearComplete.expires_at as string) ?? null,
      reason: "mission_near_complete",
      confidence_score: Math.min(0.5 + ratio * 0.45, 0.95),
    };
  }

  // 3. Start-streak nudge
  if (!streak || streak.status === "broken" || !streak.status) {
    return {
      action_type: "start_streak",
      title_ar: "ابدأ سلسلة جديدة",
      title_en: "Start a new streak",
      subtitle_ar: "أكمل رحلة اليوم لبدء سلسلة مكافآت",
      subtitle_en: "Complete a trip today to start earning streak rewards",
      potential_xp: 25,
      deep_link: "/trips/new",
      expires_at: null,
      reason: "no_active_streak",
      confidence_score: 0.7,
    };
  }

  return null;
}
