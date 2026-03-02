/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * Evaluates and awards/revokes badges based on user metrics.
 * Called after trip completion or on a scheduled basis.
 */

interface BadgeCriteria {
    min_trips?: number;
    min_kids_trips?: number;
    min_behavior_score?: number;
    min_rating?: number;
    min_ontime_rate?: number;
    min_referrals?: number;
    min_peak_trips?: number;
    max_safety_incidents?: number;
    min_tier?: string;
    parent_verified?: boolean;
    nafath_verified?: boolean;
    role?: string;
}

serve(async (req: Request) => {
    const admin = createClient(
        Deno.env.get("SUPABASE_URL")!,
        Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { userId } = await req.json();

    if (!userId) {
        return new Response(JSON.stringify({ error: "Missing userId" }), { status: 400 });
    }

    // Fetch all badge definitions
    const { data: badges } = await admin.from("badges").select("*");

    if (!badges || badges.length === 0) {
        return new Response(JSON.stringify({ evaluated: 0, awarded: [] }));
    }

    // Fetch user metrics
    const [
        { data: profile },
        { data: trustProfile },
        { data: trips },
        { data: kidsTrips },
        { data: ratings },
        { data: behaviorScore },
        { count: referralCount },
        { count: peakTripCount },
    ] = await Promise.all([
        admin.from("profiles").select("is_verified").eq("id", userId).single(),
        admin.from("trust_profiles").select("trust_tier, trust_score").eq("user_id", userId).single(),
        admin.from("trips").select("id").or(`driver_id.eq.${userId},passenger_id.eq.${userId}`).eq("status", "completed"),
        admin.from("junior_trips").select("id, rating").eq("driver_id", userId).eq("status", "completed"),
        admin.from("ratings").select("stars").eq("ratee_id", userId),
        admin.from("driver_behavior_scores").select("score").eq("driver_id", userId).order("created_at", { ascending: false }).limit(1),
        admin.from("referrals").select("*", { count: "exact", head: true }).eq("referrer_id", userId),
        admin.from("trips").select("*", { count: "exact", head: true }).eq("driver_id", userId).eq("is_peak_hour", true).eq("status", "completed"),
    ]);

    const tripCount = trips?.length || 0;
    const kidsTripCount = kidsTrips?.length || 0;
    const avgRating = ratings?.length ? ratings.reduce((sum, r) => sum + r.stars, 0) / ratings.length : 0;
    const kidsAvgRating = kidsTrips?.length ? kidsTrips.reduce((sum, t) => sum + (t.rating || 0), 0) / kidsTrips.length : 0;
    const latestBehaviorScore = behaviorScore?.[0]?.score || 0;
    const userTier = trustProfile?.trust_tier || "bronze";
    const isVerified = profile?.is_verified || false;

    const awarded: string[] = [];
    const revoked: string[] = [];

    for (const badge of badges) {
        const criteria = badge.criteria as BadgeCriteria;
        let earned = true;

        // Check each criterion
        if (criteria.min_trips !== undefined && tripCount < criteria.min_trips) earned = false;
        if (criteria.min_kids_trips !== undefined && kidsTripCount < criteria.min_kids_trips) earned = false;
        if (criteria.min_behavior_score !== undefined && latestBehaviorScore < criteria.min_behavior_score) earned = false;
        if (criteria.min_rating !== undefined && kidsAvgRating < criteria.min_rating) earned = false;
        if (criteria.min_referrals !== undefined && (referralCount || 0) < criteria.min_referrals) earned = false;
        if (criteria.min_peak_trips !== undefined && (peakTripCount || 0) < criteria.min_peak_trips) earned = false;

        // Tier check
        if (criteria.min_tier) {
            const tierOrder = ["bronze", "silver", "gold", "platinum"];
            if (tierOrder.indexOf(userTier) < tierOrder.indexOf(criteria.min_tier)) earned = false;
        }

        // Verification checks
        if (criteria.nafath_verified && !isVerified) earned = false;

        // Check if user already has this badge
        const { data: existingBadge } = await admin
            .from("user_badges")
            .select("id, revoked_at")
            .eq("user_id", userId)
            .eq("badge_id", badge.id)
            .single();

        if (earned) {
            if (!existingBadge) {
                // Award new badge
                await admin.from("user_badges").insert({
                    user_id: userId,
                    badge_id: badge.id,
                });
                awarded.push(badge.key);
            } else if (existingBadge.revoked_at) {
                // Reinstate revoked badge
                await admin
                    .from("user_badges")
                    .update({ revoked_at: null, earned_at: new Date().toISOString() })
                    .eq("id", existingBadge.id);
                awarded.push(badge.key);
            }
        } else if (existingBadge && !existingBadge.revoked_at) {
            // Revoke badge silently
            await admin
                .from("user_badges")
                .update({ revoked_at: new Date().toISOString() })
                .eq("id", existingBadge.id);
            revoked.push(badge.key);
        }
    }

    return new Response(
        JSON.stringify({
            evaluated: badges.length,
            awarded,
            revoked,
        })
    );
});
