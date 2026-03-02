import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";

serve(async (req) => {
    if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

    try {
        const { lat, lng } = await req.json();

        // In a real app, we would query historical trip data grouped by neighborhood
        // For now, we simulate demand based on time of day and proximity to major "zones"

        const now = new Date();
        const hour = now.getUTCHours() + 3; // AST

        // Simulate high demand in business districts in morning, residential in evening
        const isMorning = hour >= 7 && hour <= 10;
        const isEvening = hour >= 17 && hour <= 21;

        let demandScore = 0.5; // Baseline
        if (isMorning || isEvening) demandScore += 0.3;

        // Random fluctuation
        demandScore += (Math.random() - 0.5) * 0.2;

        return new Response(JSON.stringify({
            demand_score: Number(Math.min(1, Math.max(0, demandScore)).toFixed(2)),
            is_high_demand: demandScore > 0.7,
            surge_multiplier: demandScore > 0.8 ? 1.5 : 1.0,
            zone_label: "Riyadh Central" // Placeholder
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
