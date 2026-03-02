import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async () => {
    const admin = createClient(
        Deno.env.get("SUPABASE_URL")!,
        Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const since = new Date(Date.now() - 21 * 864e5).toISOString();

    const { data: reqs } = await admin
        .from("trip_requests")
        .select("driver_id, passenger_id, status")
        .eq("status", "accepted")
        .gte("created_at", since);

    const pairs = new Map<string, number>();

    for (const r of reqs ?? []) {
        const k = `${r.driver_id}|${r.passenger_id}`;
        pairs.set(k, (pairs.get(k) ?? 0) + 1);
    }

    const flags = [];
    const throttle = [];

    for (const [k, n] of pairs) {
        if (n < 8) continue;
        const [d, p] = k.split("|");
        const sev = n >= 14 ? "high" : n >= 10 ? "medium" : "low";

        flags.push(
            { entity_type: "profile", entity_id: d, flag_type: "pair_collusion", severity: sev, evidence_json: { count: n } },
            { entity_type: "profile", entity_id: p, flag_type: "pair_collusion", severity: sev, evidence_json: { count: n } }
        );

        if (sev !== "low") throttle.push(d, p);
    }

    if (flags.length) await admin.from("fraud_flags").insert(flags);

    if (throttle.length) {
        const until = new Date(Date.now() + 7 * 864e5).toISOString();
        await admin.from("profiles")
            .update({ xp_throttle: true, xp_throttle_until: until })
            .in("id", [...new Set(throttle)]);
    }

    return new Response(JSON.stringify({ flags: flags.length }));
});
