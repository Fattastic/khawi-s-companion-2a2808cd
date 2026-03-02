import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const clampScore = (n: number) => Math.max(0, Math.min(100, Math.round(n)));

serve(async (req) => {
    const body = await req.json();
    const {
        user_id,
        trip_ids,
        passenger_origin,
        passenger_dest
    } = body;

    const admin = createClient(
        Deno.env.get("SUPABASE_URL")!,
        Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { data: trips } = await admin
        .from("trips")
        .select(`
      id, driver_id,
      origin_lat, origin_lng,
      dest_lat, dest_lng,
      polyline,
      women_only,
      is_kids_ride,
      neighborhood_id
    `)
        .in("id", trip_ids)
        .eq("status", "planned");

    const rows = [];

    for (const t of trips ?? []) {
        // Overlap heuristic (no PostGIS)
        const dx1 = Math.abs(t.origin_lat - passenger_origin.lat);
        const dy1 = Math.abs(t.origin_lng - passenger_origin.lng);
        const dx2 = Math.abs(t.dest_lat - passenger_dest.lat);
        const dy2 = Math.abs(t.dest_lng - passenger_dest.lng);

        const overlap = Math.max(0, 1 - (dx1 + dy1 + dx2 + dy2) * 5);
        const detourMinutes = Math.round((1 - overlap) * 15);

        // Acceptance prediction (Module B)
        const acceptResp = await fetch(
            `${Deno.env.get("SUPABASE_URL")}/functions/v1/predict_acceptance`,
            {
                method: "POST",
                headers: {
                    "Authorization": `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`,
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    driver_id: t.driver_id,
                    passenger_id: user_id
                })
            }
        );

        const { accept_prob } = await acceptResp.json();

        // Fetch behavior score from profile
        const { data: profile } = await admin
            .from("profiles")
            .select("behavior_score")
            .eq("id", t.driver_id)
            .single();

        const behaviorScore = profile?.behavior_score ?? 50;

        let score =
            overlap * 50 +
            accept_prob * 25 +
            (behaviorScore / 100) * 15 +
            (detourMinutes < 5 ? 10 : 0);

        const tags = [];
        if (overlap > 0.75) tags.push("Low detour");
        if (accept_prob > 0.7) tags.push("Likely to accept");
        if (behaviorScore > 85) tags.push("Top rated driver");
        if (tags.length === 0) tags.push("Good match");

        rows.push({
            user_id,
            trip_id: t.id,
            match_score: clampScore(score),
            detour_minutes: detourMinutes,
            overlap_ratio: Number(overlap.toFixed(3)),
            accept_prob,
            explanation_tags: tags.slice(0, 2),
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
        });
    }

    if (rows.length) {
        await admin.from("match_scores").upsert(rows);

        // 3️⃣ OPTIONAL: Lightweight event logging (Canonical)
        await admin.from("event_log").insert({
            actor_id: user_id,
            event_type: "match_scored",
            entity_type: "trip",
            entity_id: trip_ids[0], // Log one representative ID or generic
            payload: {
                model: "heuristic_v1",
                count: rows.length,
                top_score: Math.max(...rows.map(r => r.match_score))
            }
        });
    }

    return new Response(JSON.stringify({ matches: rows.length }));
});
