import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

serve(async (req) => {
    if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

    try {
        const { driver_id } = await req.json();

        const admin = createClient(
            Deno.env.get("SUPABASE_URL")!,
            Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
        );

        // 1. Fetch recent ratings
        const { data: ratings } = await admin
            .from("ratings")
            .select("stars")
            .eq("ratee_id", driver_id)
            .limit(10);

        // 2. Calculate average rating
        const avgRating = ratings && ratings.length > 0
            ? ratings.reduce((acc, r) => acc + r.stars, 0) / ratings.length
            : 4.5; // Default for new drivers

        // 3. Simulate telemetry score (e.g. speeding, braking)
        // In a real app, this would query a telemetry table
        const telemetryScore = 80 + (Math.random() * 20); // 80-100

        // 4. Final behavior score (weighted average)
        const behaviorScore = Math.round((avgRating / 5) * 60 + (telemetryScore / 100) * 40);

        // 5. Update profile
        await admin
            .from("profiles")
            .update({ behavior_score: behaviorScore })
            .eq("id", driver_id);

        return new Response(JSON.stringify({
            behavior_score: behaviorScore,
            rating_component: avgRating,
            telemetry_component: telemetryScore
        }), {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (e) {
        return new Response(JSON.stringify({ error: e.message }), {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }
});
