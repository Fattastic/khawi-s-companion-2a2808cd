import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const clampScore = (n: number) => Math.max(0, Math.min(100, Math.round(n)));

serve(async (req: Request) => {
    const body = await req.json();
    const {
        user_id,
        trip_ids,
        origin,
        destination,
        women_only,
        max_results = 10
    } = body;

    // Normalize input (handle both direct 'origin' or 'passenger_origin' styles if legacy)
    const passenger_origin = origin || body.passenger_origin;
    const passenger_dest = destination || body.passenger_dest;

    if (!passenger_origin || !passenger_dest) {
        return new Response(JSON.stringify({ error: "Missing origin or destination" }), { status: 400 });
    }

    const admin = createClient(
        Deno.env.get("SUPABASE_URL")!,
        Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // If trip_ids provided, use scoring mode (legacy score_matches behavior)
    if (trip_ids && trip_ids.length > 0) {
        // ... (We could keep the old logic for backward compat, but for now let's focus on the smart_match logic)
        // For now, let's assume smart_match is primarily for search.
    }

    // 1. Fetch Candidates (Rough Bounding Box Filter)
    // +/- 0.5 degrees is roughly +/- 55km, generous search radius
    const latDelta = 0.5;
    const lngDelta = 0.5;

    let query = admin
        .from("trips")
        .select(`
            id, driver_id,
            origin_lat, origin_lng,
            dest_lat, dest_lng,
            polyline,
            women_only,
            is_kids_ride,
            neighborhood_id,
            status
        `)
        .eq("status", "planned")
        .lt("origin_lat", passenger_origin.lat + latDelta)
        .gt("origin_lat", passenger_origin.lat - latDelta)
        .lt("origin_lng", passenger_origin.lng + lngDelta)
        .gt("origin_lng", passenger_origin.lng - lngDelta);

    if (women_only) {
        query = query.eq("women_only", true);
    }

    const { data: trips, error } = await query;

    if (error) {
        return new Response(JSON.stringify({ error: error.message }), { status: 500 });
    }

    // 2. Score Candidates
    const rows = [];

    // Explicitly type 't' as any for now to avoid extensive interface definition in this snippet
    // In a real project we'd share the Db types.
    for (const t of (trips ?? []) as any[]) {
        const dx1 = Math.abs(t.origin_lat - passenger_origin.lat);
        const dy1 = Math.abs(t.origin_lng - passenger_origin.lng);
        const dx2 = Math.abs(t.dest_lat - passenger_dest.lat);
        const dy2 = Math.abs(t.dest_lng - passenger_dest.lng);

        const overlap = Math.max(0, 1 - (dx1 + dy1 + dx2 + dy2) * 5);
        const detourMinutes = Math.round((1 - overlap) * 15);

        if (overlap < 0.1) continue;

        const accept_prob = 0.85;

        let score =
            overlap * 55 +
            accept_prob * 30 +
            (detourMinutes < 5 ? 15 : 0);

        const tags = [];
        if (overlap > 0.75) tags.push("Low detour");
        if (accept_prob > 0.7) tags.push("Likely to accept");
        if (t.women_only) tags.push("Women Only");
        if (tags.length === 0) tags.push("Good match");

        rows.push({
            trip: t,
            score: clampScore(score),
            tags: tags.slice(0, 2),
            accept_prob
        });
    }

    rows.sort((a, b) => b.score - a.score);
    const results = rows.slice(0, max_results);

    return new Response(JSON.stringify({ matches: results }), {
        headers: { "Content-Type": "application/json" }
    });
});
