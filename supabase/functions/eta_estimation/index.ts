import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";

function getHaversineDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371; // km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}

serve(async (req) => {
    if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

    try {
        const { origin, destination } = await req.json();

        const distanceKm = getHaversineDistance(
            origin.lat, origin.lng,
            destination.lat, destination.lng
        );

        // Heuristic: Average speed in Riyadh is ~40 km/h
        // Rush hours: 7-9 AM, 4-7 PM -> Multiplier 1.8x
        const now = new Date();
        const hour = now.getUTCHours() + 3; // AST
        const isRushHour = (hour >= 7 && hour <= 9) || (hour >= 16 && hour <= 19);

        const baseMinutes = (distanceKm / 40) * 60;
        const trafficMultiplier = isRushHour ? 1.8 : 1.2;
        const estimatedMinutes = Math.round(baseMinutes * trafficMultiplier + 5); // +5 min overhead

        return new Response(JSON.stringify({
            eta_minutes: estimatedMinutes,
            distance_km: Number(distanceKm.toFixed(2)),
            traffic_level: isRushHour ? 'high' : 'normal'
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
