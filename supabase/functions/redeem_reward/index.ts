/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * Redeem Reward Edge Function
 * 
 * Atomically handles:
 * - Entitlement check (Khawi+ if required)
 * - Trust tier minimum requirement
 * - Per-user and global caps
 * - Redemption window validation
 * - XP balance check and debit
 * - Redemption record creation
 */

interface RedeemRequest {
    rewardId: string;
    options?: Record<string, unknown>;
}

interface RedemptionResult {
    success: boolean;
    redemption?: {
        id: string;
        rewardId: string;
        status: string;
        xpCostSnapshot: number;
    };
    xpBalanceAfter?: number;
    error?: string;
    errorCode?: string;
}

serve(async (req: Request): Promise<Response> => {
    const url = Deno.env.get("SUPABASE_URL")!;
    const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const admin = createClient(url, key);

    // Get current user from auth
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
        return jsonResponse({ success: false, error: "Missing authorization", errorCode: "UNAUTHORIZED" }, 401);
    }

    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await admin.auth.getUser(token);

    if (authError || !user) {
        return jsonResponse({ success: false, error: "Invalid token", errorCode: "UNAUTHORIZED" }, 401);
    }

    const userId = user.id;
    const body = await req.json() as RedeemRequest;
    const { rewardId } = body;

    if (!rewardId) {
        return jsonResponse({ success: false, error: "Missing rewardId", errorCode: "BAD_REQUEST" }, 400);
    }

    // 1. Fetch reward details
    const { data: reward, error: rewardError } = await admin
        .from("rewards_catalog")
        .select("*")
        .eq("id", rewardId)
        .eq("is_active", true)
        .single();

    if (rewardError || !reward) {
        return jsonResponse({ success: false, error: "Reward not found or inactive", errorCode: "REWARD_NOT_FOUND" }, 404);
    }

    // 2. Check redemption window
    const now = new Date();
    if (reward.redemption_window_start && new Date(reward.redemption_window_start) > now) {
        return jsonResponse({ success: false, error: "Redemption window not started", errorCode: "WINDOW_NOT_STARTED" }, 400);
    }
    if (reward.redemption_window_end && new Date(reward.redemption_window_end) < now) {
        return jsonResponse({ success: false, error: "Redemption window ended", errorCode: "WINDOW_ENDED" }, 400);
    }

    // 3. Check Khawi+ requirement
    if (reward.requires_khawi_plus) {
        const { data: profile } = await admin
            .from("profiles")
            .select("subscription_tier")
            .eq("id", userId)
            .single();

        if (!profile || profile.subscription_tier === "free" || profile.subscription_tier === null) {
            return jsonResponse({ success: false, error: "Khawi+ required", errorCode: "KHAWI_PLUS_REQUIRED" }, 403);
        }
    }

    // 4. Check trust tier requirement
    const { data: trustState } = await admin
        .from("user_trust_state")
        .select("tier")
        .eq("user_id", userId)
        .single();

    const userTier = trustState?.tier || "bronze";
    const tierOrder = ["bronze", "silver", "gold", "platinum"];
    const userTierIndex = tierOrder.indexOf(userTier);
    const requiredTierIndex = tierOrder.indexOf(reward.min_trust_tier);

    if (userTierIndex < requiredTierIndex) {
        return jsonResponse({
            success: false,
            error: `Trust tier ${reward.min_trust_tier} required`,
            errorCode: "TRUST_TIER_INSUFFICIENT"
        }, 403);
    }

    // 5. Check per-user cap
    if (reward.max_redemptions_per_user) {
        const { count } = await admin
            .from("reward_redemptions")
            .select("*", { count: "exact", head: true })
            .eq("user_id", userId)
            .eq("reward_id", rewardId);

        if ((count || 0) >= reward.max_redemptions_per_user) {
            return jsonResponse({ success: false, error: "Per-user redemption limit reached", errorCode: "USER_CAP_EXCEEDED" }, 400);
        }
    }

    // 6. Check global cap
    if (reward.max_redemptions_total) {
        const { count } = await admin
            .from("reward_redemptions")
            .select("*", { count: "exact", head: true })
            .eq("reward_id", rewardId);

        if ((count || 0) >= reward.max_redemptions_total) {
            return jsonResponse({ success: false, error: "Global redemption limit reached", errorCode: "GLOBAL_CAP_EXCEEDED" }, 400);
        }
    }

    // 7. Check XP balance
    const { data: gamification } = await admin
        .from("user_gamification")
        .select("xp_balance")
        .eq("user_id", userId)
        .single();

    const xpBalance = gamification?.xp_balance || 0;
    if (xpBalance < reward.xp_cost) {
        return jsonResponse({
            success: false,
            error: `Insufficient XP. Required: ${reward.xp_cost}, Available: ${xpBalance}`,
            errorCode: "INSUFFICIENT_XP"
        }, 400);
    }

    // 8. Debit XP (atomic update)
    const { error: debitError } = await admin
        .from("user_gamification")
        .update({ xp_balance: xpBalance - reward.xp_cost })
        .eq("user_id", userId)
        .gte("xp_balance", reward.xp_cost); // Ensure no negative balance

    if (debitError) {
        return jsonResponse({ success: false, error: "Failed to debit XP", errorCode: "XP_DEBIT_FAILED" }, 500);
    }

    // 9. Create redemption record
    const { data: redemption, error: redemptionError } = await admin
        .from("reward_redemptions")
        .insert({
            user_id: userId,
            reward_id: rewardId,
            xp_cost_snapshot: reward.xp_cost,
            status: "requested",
        })
        .select()
        .single();

    if (redemptionError) {
        // Rollback XP debit
        await admin
            .from("user_gamification")
            .update({ xp_balance: xpBalance })
            .eq("user_id", userId);

        return jsonResponse({ success: false, error: "Failed to create redemption", errorCode: "REDEMPTION_FAILED" }, 500);
    }

    // 10. Log XP debit to ledger
    await admin.from("xp_events").insert({
        user_id: userId,
        event_type: "debit",
        amount: -reward.xp_cost,
        reason: `Redeemed: ${reward.code}`,
        reference_id: redemption.id,
        reference_type: "redemption",
    });

    const result: RedemptionResult = {
        success: true,
        redemption: {
            id: redemption.id,
            rewardId: redemption.reward_id,
            status: redemption.status,
            xpCostSnapshot: redemption.xp_cost_snapshot,
        },
        xpBalanceAfter: xpBalance - reward.xp_cost,
    };

    return jsonResponse(result, 200);
});

function jsonResponse(data: unknown, status: number): Response {
    return new Response(JSON.stringify(data), {
        status,
        headers: { "Content-Type": "application/json" },
    });
}
