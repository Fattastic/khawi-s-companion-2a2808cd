import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

interface XpCalcRequest {
    userId: string;
    tripId: string;
    role: "passenger" | "driver";
    distanceKm: number;
    passengerCount?: number;
    isPeakHour?: boolean;
}

serve(async (req) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        const supabaseClient = createClient(
            Deno.env.get("SUPABASE_URL") ?? "",
            Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
        );

        const { userId, tripId, role, distanceKm, passengerCount = 1, isPeakHour = false } = await req.json() as XpCalcRequest;

        // 1. Fetch Profile Extensions & Streaks
        const [extRes, streakRes] = await Promise.all([
            supabaseClient.from("profile_extensions").select("*").eq("user_id", userId).single(),
            supabaseClient.from("streak_stats").select("*").eq("user_id", userId).single(),
        ]);

        const ext = extRes.data;
        const streaks = streakRes.data;

        let multiplier = 1.0;

        // 2. Role-Based Base Multiplier
        if (role === "passenger") {
            multiplier = 1.0;
            // Bonus for car owners carpooling
            if (ext?.vehicle_info?.owns_car) {
                multiplier = isPeakHour ? 1.35 : 1.25;
            }
        } else if (role === "driver") {
            multiplier = 1.5;
            if (passengerCount >= 2) multiplier = 1.65;
            // High demand/Peak hour boost
            if (isPeakHour) multiplier = 1.8;

            // Kids trip check (from trip tags or metadata)
            const { data: trip } = await supabaseClient.from("trips").select("is_kids_ride").eq("id", tripId).single();
            if (trip?.is_kids_ride) multiplier = 1.9;
        }

        // 3. Streak Multiplier
        if (role === "driver" && streaks) {
            const dStreak = streaks.driver_streak || 0;
            if (dStreak >= 20) multiplier = Math.max(multiplier, 2.5);
            else if (dStreak >= 10) multiplier = Math.max(multiplier, 2.2);
            else if (dStreak >= 5) multiplier = Math.max(multiplier, 2.0);
            else if (dStreak >= 3) multiplier += 0.1;
        }

        // 4. Diminishing Returns (Anti-Abuse)
        // Same route trips in the same day earn reduced XP
        const today = new Date().toISOString().split('T')[0];
        const { count: sameRouteCount } = await supabaseClient
            .from("trips")
            .select("*", { count: "exact", head: true })
            .eq("driver_id", role === "driver" ? userId : null)
            .eq("passenger_id", role === "passenger" ? userId : null)
            .gte("created_at", `${today}T00:00:00`)
            .eq("status", "completed");

        let diminishingFactor = 1.0;
        if ((sameRouteCount || 0) >= 5) {
            diminishingFactor = 0.25; // 75% reduction after 5 trips/day
        } else if ((sameRouteCount || 0) >= 3) {
            diminishingFactor = 0.5; // 50% reduction after 3 trips/day
        }

        // 5. Calculate Final XP
        const baseTripXP = 50;
        const perKmXP = 5;
        const baseResult = baseTripXP + (distanceKm * perKmXP);
        const totalXp = Math.round(baseResult * multiplier * diminishingFactor);

        // 6. Classify XP into bucket
        const xpSource = role === "driver" ? "driver_trip" : "passenger_trip";
        try {
            await supabaseClient.functions.invoke("classify_xp_bucket", {
                body: { userId, source: xpSource, amount: totalXp },
            });
        } catch {
            // Non-blocking: bucket classification failure doesn't affect XP award
        }

        return new Response(
            JSON.stringify({
                totalXp,
                multiplier,
                baseResult,
                streakInfo: {
                    passenger: streaks?.passenger_streak || 0,
                    driver: streaks?.driver_streak || 0,
                }
            }),
            {
                headers: { ...corsHeaders, "Content-Type": "application/json" },
                status: 200,
            }
        );

    } catch (error) {
        return new Response(JSON.stringify({ error: (error as Error).message }), {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
            status: 400,
        });
    }
});
