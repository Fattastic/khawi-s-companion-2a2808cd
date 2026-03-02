import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const clamp = (n: number, a: number, b: number) => Math.max(a, Math.min(b, n));

serve(async (req) => {
    const admin = createClient(
        Deno.env.get("SUPABASE_URL")!,
        Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // feature flag
    const { data: ff } = await admin
        .from("feature_flags")
        .select("enabled, rollout_percentage")
        .eq("name", "ai.trustscore")
        .single();

    if (!ff?.enabled || ff.rollout_percentage === 0) {
        return new Response(JSON.stringify({ skipped: true }));
    }

    const since = new Date(Date.now() - 120 * 864e5).toISOString();

    const { data: reqs } = await admin
        .from("trip_requests")
        .select("driver_id, passenger_id, status")
        .gte("created_at", since);

    const stats = new Map<string, any>();

    for (const r of reqs ?? []) {
        for (const uid of [r.driver_id, r.passenger_id]) {
            if (!uid) continue;
            const s = stats.get(uid) ?? { acc: 0, dec: 0, can: 0, tot: 0 };
            if (r.status === "accepted") s.acc++;
            if (r.status === "declined") s.dec++;
            if (r.status === "cancelled") s.can++;
            s.tot++;
            stats.set(uid, s);
        }
    }

    const userIds = [...stats.keys()];
    const { data: profs } = await admin
        .from("profiles")
        .select("id, is_verified")
        .in("id", userIds);

    const verified = new Map(profs?.map(p => [p.id, p.is_verified]) ?? []);

    const rows = [];

    for (const [uid, s] of stats) {
        const decisions = s.acc + s.dec;
        const accRate = decisions ? s.acc / decisions : 0.6;
        const cancelRate = s.tot ? s.can / s.tot : 0.05;
        const isVer = verified.get(uid) ?? false;

        const score = clamp(
            100 * (0.6 * accRate + 0.25 * (1 - cancelRate) + 0.15 * (isVer ? 1 : 0)),
            0, 100
        );

        const badge = score >= 80 ? "gold" : score >= 60 ? "silver" : "bronze";

        rows.push({
            user_id: uid,
            trust_score: score,
            trust_badge: badge,
            junior_trusted: isVer && score >= 75 && cancelRate <= 0.1,
            computed_at: new Date().toISOString(),
        });
    }

    if (rows.length) {
        await admin.from("trust_profiles").upsert(rows);
    }

    return new Response(JSON.stringify({ updated: rows.length }));
});
