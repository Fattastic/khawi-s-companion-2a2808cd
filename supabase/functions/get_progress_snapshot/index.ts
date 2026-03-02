/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

// ─── Types ─────────────────────────────────────────────────────────────────────

interface StreakSnapshot {
  user_id: string;
  current_count: number;
  longest_count: number;
  status: "active" | "grace" | "broken" | "recovered";
  grace_expires_at: string | null;
}

interface MissionSnapshot {
  id: string;
  title_ar: string;
  title_en: string;
  description_ar: string;
  description_en: string;
  category: string;
  current_count: number;
  target_count: number;
  reward_xp: number;
  status: string;
  week_start: string;
  expires_at: string;
}

interface WalletSnapshot {
  user_id: string;
  total_earned: number;
  total_unlocked: number;
  total_pending: number;
  total_redeemed: number;
}

interface ProgressResponse {
  success: boolean;
  streak: StreakSnapshot | null;
  active_missions: MissionSnapshot[];
  wallet_summary: WalletSnapshot | null;
  next_action: NextAction | null;
  fetched_at: string;
  error?: string;
  errorCode?: string;
}

interface NextAction {
  action_type: string;
  title_ar: string;
  title_en: string;
  subtitle_ar: string;
  subtitle_en: string;
  potential_xp: number;
  deep_link: string | null;
  expires_at: string | null;
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

    // ── Parallel reads ─────────────────────────────────────────────────────
    const now = new Date().toISOString();
    const weekStart = getWeekStart();

    const [streakResult, missionsResult, walletResult] = await Promise.all([
      admin
        .from("user_streaks")
        .select("*")
        .eq("user_id", userId)
        .maybeSingle(),

      admin
        .from("user_missions")
        .select("*")
        .eq("user_id", userId)
        .gte("week_start", weekStart)
        .in("status", ["active", "completed"])
        .order("created_at", { ascending: true }),

      admin
        .from("user_wallet_summary")
        .select("*")
        .eq("user_id", userId)
        .maybeSingle(),
    ]);

    // ── Build streak ───────────────────────────────────────────────────────
    let streak: StreakSnapshot | null = null;
    if (streakResult.data) {
      const s = streakResult.data;
      streak = {
        user_id: s.user_id,
        current_count: s.current_count ?? 0,
        longest_count: s.longest_count ?? 0,
        status: s.status ?? "broken",
        grace_expires_at: s.grace_expires_at ?? null,
      };
    }

    // ── Build missions ─────────────────────────────────────────────────────
    const activeMissions: MissionSnapshot[] = (missionsResult.data ?? []).map(
      (m: Record<string, unknown>) => ({
        id: (m.id as string) ?? "",
        title_ar: (m.title_ar as string) ?? "",
        title_en: (m.title_en as string) ?? "",
        description_ar: (m.description_ar as string) ?? "",
        description_en: (m.description_en as string) ?? "",
        category: (m.category as string) ?? "general",
        current_count: (m.current_count as number) ?? 0,
        target_count: (m.target_count as number) ?? 1,
        reward_xp: (m.reward_xp as number) ?? 0,
        status: (m.status as string) ?? "active",
        week_start: (m.week_start as string) ?? weekStart,
        expires_at: (m.expires_at as string) ?? "",
      }),
    );

    // ── Build wallet ───────────────────────────────────────────────────────
    let walletSummary: WalletSnapshot | null = null;
    if (walletResult.data) {
      const w = walletResult.data;
      walletSummary = {
        user_id: w.user_id,
        total_earned: w.total_earned ?? 0,
        total_unlocked: w.total_unlocked ?? 0,
        total_pending: w.total_pending ?? 0,
        total_redeemed: w.total_redeemed ?? 0,
      };
    }

    // ── Next-best-action (simple heuristic — promote to ML later) ──────
    const nextAction = computeNextAction(streak, activeMissions, role);

    // ── Response ───────────────────────────────────────────────────────────
    const response: ProgressResponse = {
      success: true,
      streak,
      active_missions: activeMissions,
      wallet_summary: walletSummary,
      next_action: nextAction,
      fetched_at: now,
    };

    return jsonResponse(response, 200);
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

/** ISO date of the most recent Monday (week boundary). */
function getWeekStart(): string {
  const d = new Date();
  const day = d.getDay();
  const diff = d.getDate() - day + (day === 0 ? -6 : 1); // Monday
  const monday = new Date(d.setDate(diff));
  monday.setHours(0, 0, 0, 0);
  return monday.toISOString().slice(0, 10);
}

/**
 * Simple heuristic NBA — picks the highest-priority recommendation.
 * Priority: broken streak recovery > incomplete missions > first-trip nudge.
 */
function computeNextAction(
  streak: StreakSnapshot | null,
  missions: MissionSnapshot[],
  _role: string,
): NextAction | null {
  // 1. Streak recovery opportunity
  if (streak?.status === "grace") {
    return {
      action_type: "recover_streak",
      title_ar: "استعد سلسلتك!",
      title_en: "Recover your streak!",
      subtitle_ar: `أكمل رحلة قبل انتهاء فترة السماح لاستعادة ${streak.current_count} يوم`,
      subtitle_en: `Complete a trip before grace expires to restore your ${streak.current_count}-day streak`,
      potential_xp: 50,
      deep_link: "/trips/new",
      expires_at: streak.grace_expires_at,
    };
  }

  // 2. Near-complete mission
  const nearComplete = missions
    .filter(
      (m) =>
        m.status === "active" &&
        m.target_count > 0 &&
        m.current_count / m.target_count >= 0.7,
    )
    .sort(
      (a, b) =>
        b.current_count / b.target_count - a.current_count / a.target_count,
    )[0];

  if (nearComplete) {
    const remaining = nearComplete.target_count - nearComplete.current_count;
    return {
      action_type: "complete_mission",
      title_ar: nearComplete.title_ar,
      title_en: nearComplete.title_en,
      subtitle_ar: `${remaining} مهمة متبقية لإكمالها`,
      subtitle_en: `${remaining} more to complete this mission`,
      potential_xp: nearComplete.reward_xp,
      deep_link: null,
      expires_at: nearComplete.expires_at,
    };
  }

  // 3. Start-streak nudge for broken/new users
  if (!streak || streak.status === "broken") {
    return {
      action_type: "start_streak",
      title_ar: "ابدأ سلسلة جديدة",
      title_en: "Start a new streak",
      subtitle_ar: "أكمل رحلة اليوم لبدء سلسلة مكافآت",
      subtitle_en: "Complete a trip today to start earning streak rewards",
      potential_xp: 25,
      deep_link: "/trips/new",
      expires_at: null,
    };
  }

  return null;
}
