import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const clamp = (n: number) => Math.max(0, Math.min(1, n));

serve(async (req) => {
    if (req.method !== "POST") {
        return new Response(JSON.stringify({ error: "POST only" }), { status: 405 });
    }

    const { driver_id, passenger_id } = await req.json();

    const admin = createClient(
        Deno.env.get("SUPABASE_URL")!,
        Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Last 60 days
    const since = new Date(Date.now() - 60 * 864e5).toISOString();

    const { data: history } = await admin
        .from("trip_requests")
        .select("status, passenger_id")
        .eq("driver_id", driver_id)
        .gte("created_at", since);

    let accepted = 0;
    let declined = 0;
    let samePassengerBoost = 0;

    for (const r of history ?? []) {
        if (r.status === "accepted") accepted++;
        if (r.status === "declined") declined++;
        if (r.passenger_id === passenger_id && r.status === "accepted") {
            samePassengerBoost = 0.1;
        }
    }

    const decisions = accepted + declined;
    const baseRate = decisions > 0 ? accepted / decisions : 0.6;

    // Pending load penalty
    const { count: pendingCount } = await admin
        .from("trip_requests")
        .select("*", { count: "exact", head: true })
        .eq("driver_id", driver_id)
        .eq("status", "pending");

    const loadPenalty = Math.min((pendingCount ?? 0) * 0.05, 0.2);

    const acceptProb = clamp(baseRate + samePassengerBoost - loadPenalty);

    return new Response(JSON.stringify({
        accept_prob: Number(acceptProb.toFixed(3)),
        model_version: "heuristic_v1"
    }));
});
