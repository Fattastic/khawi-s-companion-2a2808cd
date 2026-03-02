import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { corsHeaders } from "../_shared/cors.ts"

serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const supabaseClient = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_ANON_KEY') ?? '',
            { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
        )

        // 1. Get User Location / Time
        const { lat, lng, time } = await req.json()

        // 2. Logic: Mock Dynamic Pricing / XP Multiplier
        // In real app, query "area_incentives" table with PostGIS
        // Here: heuristic based on time of day (Rush Hour)

        const date = time ? new Date(time) : new Date();
        const hour = date.getHours();

        let multiplier = 1.0;
        let reason = null;
        let areaId = "global";

        // Rush Hour: 7-9 AM, 4-6 PM
        if ((hour >= 7 && hour <= 9) || (hour >= 16 && hour <= 18)) {
            multiplier = 2.0;
            reason = "Rush Hour Bonus";
            areaId = "downtown_riyadh";
        } else if (hour >= 22 || hour <= 4) {
            multiplier = 1.5;
            reason = "Night Owl Bonus";
            areaId = "night_zone";
        }

        return new Response(
            JSON.stringify({
                multiplier,
                reason,
                area_id: areaId,
                valid_until: new Date(date.getTime() + 60 * 60 * 1000).toISOString()
            }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
        )
    }
})
