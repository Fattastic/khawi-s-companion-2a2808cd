/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * Classifies XP into internal buckets based on source.
 * Called after XP is awarded to categorize it properly.
 */

const BUCKET_MAP: Record<string, string> = {
    // Contribution XP
    trip_completion: "contribution_xp",
    carpooling: "contribution_xp",
    driver_trip: "contribution_xp",
    passenger_trip: "contribution_xp",

    // Safety XP
    clean_trip: "safety_xp",
    kids_trip: "safety_xp",
    behavior_bonus: "safety_xp",
    safe_arrival: "safety_xp",

    // Community XP
    streak_bonus: "community_xp",
    referral: "community_xp",
    helping_new_user: "community_xp",
    peak_hour_bonus: "community_xp",

    // Learning XP
    onboarding: "learning_xp",
    safety_tip: "learning_xp",
    profile_completion: "learning_xp",
};

serve(async (req: Request) => {
    const admin = createClient(
        Deno.env.get("SUPABASE_URL")!,
        Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { userId, source, amount } = await req.json();

    if (!userId || !source || amount === undefined) {
        return new Response(
            JSON.stringify({ error: "Missing userId, source, or amount" }),
            { status: 400 }
        );
    }

    const bucket = BUCKET_MAP[source] || "contribution_xp";

    // Upsert to xp_buckets, incrementing the appropriate bucket
    const { error } = await admin.rpc("increment_xp_bucket", {
        p_user_id: userId,
        p_bucket: bucket,
        p_amount: amount,
    });

    if (error) {
        // Fallback: try direct upsert if RPC doesn't exist
        const { data: existing } = await admin
            .from("xp_buckets")
            .select("*")
            .eq("user_id", userId)
            .single();

        if (existing) {
            const newValue = (existing[bucket] || 0) + amount;
            await admin
                .from("xp_buckets")
                .update({ [bucket]: newValue, updated_at: new Date().toISOString() })
                .eq("user_id", userId);
        } else {
            await admin.from("xp_buckets").insert({
                user_id: userId,
                [bucket]: amount,
            });
        }
    }

    return new Response(JSON.stringify({ success: true, bucket, amount }));
});
