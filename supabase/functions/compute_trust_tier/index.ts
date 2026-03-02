/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * Computes trust tier based on safety metrics.
 * Layered on top of existing compute_trust_scores function.
 * 
 * Tiers:
 * - Bronze: Default / score < 60
 * - Silver: Score >= 60, clean trip rate > 80%
 * - Gold: Score >= 75, junior_trusted = true
 * - Platinum: Score >= 90, 50+ trips, 0 fraud flags
 */

interface TrustProfile {
    user_id: string;
    trust_score: number;
    junior_trusted: boolean;
}

type TrustTier = "bronze" | "silver" | "gold" | "platinum";

serve(async (_req: Request) => {
    const admin = createClient(
        Deno.env.get("SUPABASE_URL")!,
        Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Feature flag check
    const { data: ff } = await admin
        .from("feature_flags")
        .select("enabled")
        .eq("name", "ai.trusttier")
        .single();

    if (!ff?.enabled) {
        return new Response(JSON.stringify({ skipped: true, reason: "Feature disabled" }));
    }

    // Fetch all trust profiles
    const { data: profiles } = await admin
        .from("trust_profiles")
        .select("user_id, trust_score, junior_trusted");

    if (!profiles || profiles.length === 0) {
        return new Response(JSON.stringify({ updated: 0 }));
    }

    // Fetch trip counts and fraud flags
    const userIds = profiles.map((p: TrustProfile) => p.user_id);

    const { data: tripCounts } = await admin
        .from("trips")
        .select("driver_id, passenger_id")
        .in("driver_id", userIds)
        .eq("status", "completed");

    const { data: fraudFlags } = await admin
        .from("fraud_events")
        .select("user_id")
        .in("user_id", userIds);

    // Count trips per user
    const tripCountMap = new Map<string, number>();
    for (const t of tripCounts ?? []) {
        if (t.driver_id) {
            tripCountMap.set(t.driver_id, (tripCountMap.get(t.driver_id) || 0) + 1);
        }
        if (t.passenger_id) {
            tripCountMap.set(t.passenger_id, (tripCountMap.get(t.passenger_id) || 0) + 1);
        }
    }

    // Track fraud flags
    const fraudSet = new Set((fraudFlags ?? []).map((f) => f.user_id));

    // Compute tiers
    const updates: { user_id: string; trust_tier: TrustTier }[] = [];

    for (const p of profiles as TrustProfile[]) {
        const score = p.trust_score;
        const tripCount = tripCountMap.get(p.user_id) || 0;
        const hasFraud = fraudSet.has(p.user_id);

        let tier: TrustTier = "bronze";

        if (score >= 90 && tripCount >= 50 && !hasFraud) {
            tier = "platinum";
        } else if (score >= 75 && p.junior_trusted) {
            tier = "gold";
        } else if (score >= 60) {
            tier = "silver";
        }

        updates.push({ user_id: p.user_id, trust_tier: tier });
    }

    // Batch update
    for (const u of updates) {
        await admin
            .from("trust_profiles")
            .update({ trust_tier: u.trust_tier })
            .eq("user_id", u.user_id);
    }

    return new Response(JSON.stringify({ updated: updates.length }));
});
