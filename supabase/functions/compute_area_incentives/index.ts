import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const clamp = (n: number, a: number, b: number) => Math.max(a, Math.min(b, n));

function bucket(d: Date) {
    d.setMinutes(0, 0, 0);
    return d.toISOString();
}

serve(async () => {
    const admin = createClient(
        Deno.env.get("SUPABASE_URL")!,
        Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const since = new Date(Date.now() - 7 * 864e5).toISOString();

    const { data: trips } = await admin
        .from("trips")
        .select("id, neighborhood_id, departure_time, seats_available")
        .eq("status", "planned")
        .gte("departure_time", since);

    const { data: reqs } = await admin
        .from("trip_requests")
        .select("trip_id")
        .eq("status", "pending");

    const tripMap = new Map(trips?.map(t => [t.id, t]) ?? []);

    const supply = new Map<string, number>();
    const demand = new Map<string, number>();

    for (const t of trips ?? []) {
        const k = `${t.neighborhood_id}|${bucket(new Date(t.departure_time))}`;
        supply.set(k, (supply.get(k) ?? 0) + (t.seats_available ?? 0));
    }

    for (const r of reqs ?? []) {
        const t = tripMap.get(r.trip_id);
        if (!t) continue;
        const k = `${t.neighborhood_id}|${bucket(new Date(t.departure_time))}`;
        demand.set(k, (demand.get(k) ?? 0) + 1);
    }

    const rows = [];

    for (const k of new Set([...supply.keys(), ...demand.keys()])) {
        const [area, time] = k.split("|");
        const s = supply.get(k) ?? 0;
        const d = demand.get(k) ?? 0;
        const ratio = s ? d / s : d ? 3 : 1;
        const mult = clamp(1 + (ratio - 1) * 0.35, 1, 2);

        rows.push({
            area_id: area,
            time_bucket: time,
            dynamic_xp_multiplier: mult,
            reason_tag: ratio > 1.3 ? "demand_high" : ratio < 0.7 ? "supply_high" : "balanced",
            computed_at: new Date().toISOString(),
        });
    }

    if (rows.length) {
        await admin.from("area_incentives").insert(rows);
    }

    return new Response(JSON.stringify({ rows: rows.length }));
});
