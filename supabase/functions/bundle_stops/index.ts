import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import type { LatLng } from "../_shared/geo.ts";
import { clamp, approxMinutesFromKm } from "../_shared/geo.ts";
import { decodePolylineSafe, samplePolyline, nearestToRoute } from "../_shared/poly.ts";

type Json = Record<string, unknown>;

function jres(body: Json, status = 200) {
    return new Response(JSON.stringify(body), {
        status,
        headers: { "content-type": "application/json" },
    });
}

async function flagEnabled(admin: any, name: string): Promise<boolean> {
    try {
        const { data } = await admin.from("feature_flags").select("enabled,rollout_percentage").eq("name", name).single();
        return Boolean(data?.enabled) && (data.rollout_percentage ?? 0) > 0;
    } catch {
        return true;
    }
}

serve(async (req) => {
    try {
        if (req.method !== "POST") return jres({ error: "method_not_allowed" }, 405);

        const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
        const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
        const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

        const authHeader = req.headers.get("authorization") || "";
        const userClient = createClient(SUPABASE_URL, ANON_KEY, {
            global: { headers: { authorization: authHeader } },
        });
        const admin = createClient(SUPABASE_URL, SERVICE_KEY);

        const { data: u } = await userClient.auth.getUser();
        const userId = u?.user?.id;
        if (!userId) return jres({ error: "unauthorized" }, 401);

        if (!(await flagEnabled(admin, "ai.bundling"))) {
            return jres({ ok: true, skipped: true, reason: "flag_disabled" });
        }

        const body = await req.json().catch(() => ({} as any));
        const tripId = String(body.trip_id ?? "");
        const passengerIds = Array.isArray(body.passenger_ids) ? body.passenger_ids.map(String) : [];

        if (!tripId || passengerIds.length < 2 || passengerIds.length > 4) {
            return jres({ error: "invalid_input", hint: "trip_id + passenger_ids[2..4]" }, 400);
        }

        // Fetch trip (exact schema)
        const { data: trip, error: tErr } = await admin
            .from("trips")
            .select("id, driver_id, origin_lat, origin_lng, dest_lat, dest_lng, polyline, status")
            .eq("id", tripId)
            .single();

        if (tErr || !trip) return jres({ error: "trip_not_found" }, 404);
        if (String(trip.driver_id) !== userId) return jres({ error: "forbidden" }, 403);

        // Fetch trip_requests pickup coords (requires pickup_lat/lng migration)
        const { data: reqs, error: rErr } = await admin
            .from("trip_requests")
            .select("passenger_id, pickup_lat, pickup_lng, pickup_label, status")
            .eq("trip_id", tripId)
            .in("passenger_id", passengerIds);

        if (rErr) return jres({ error: "requests_fetch_failed", details: rErr.message }, 500);

        // Only consider pending/accepted for suggestion (avoid declined/expired/cancelled)
        const pickups = (reqs ?? [])
            .filter((r: any) => r.status === "pending" || r.status === "accepted")
            .filter((r: any) => r.pickup_lat != null && r.pickup_lng != null)
            .map((r: any) => ({
                passengerId: String(r.passenger_id),
                point: { lat: Number(r.pickup_lat), lng: Number(r.pickup_lng) } as LatLng,
                label: r.pickup_label ? String(r.pickup_label) : null,
            }));

        if (pickups.length < 2) {
            return jres({
                error: "insufficient_pickup_points",
                hint: "Ensure trip_requests has pickup_lat/pickup_lng for each passenger.",
            }, 400);
        }

        const driverOrigin: LatLng = { lat: Number(trip.origin_lat), lng: Number(trip.origin_lng) };
        const driverDest: LatLng = { lat: Number(trip.dest_lat), lng: Number(trip.dest_lng) };

        const raw = decodePolylineSafe(trip.polyline);
        const route = raw.length >= 6 ? samplePolyline(raw, 32) : [driverOrigin, driverDest];

        const enriched = pickups.map((p) => {
            const n = nearestToRoute(p.point, route);
            const eta = clamp(approxMinutesFromKm(n.minKm), 0, 15);
            return {
                passenger_id: p.passengerId,
                pickup_point: p.point,
                pickup_label: p.label,
                eta_delta_min: eta,
                route_idx: n.idx,
                off_route_km: n.minKm,
            };
        });

        // Sort by route progress
        enriched.sort((a, b) => a.route_idx - b.route_idx);

        // Compute acceptability score (0-100)
        const sumOff = enriched.reduce((s, x) => s + x.off_route_km, 0);
        const maxOff = Math.max(...enriched.map((x) => x.off_route_km), 0);

        let score = 100;
        score -= Math.min(45, sumOff * 10);
        score -= Math.max(0, enriched.length - 2) * 8;
        if (maxOff > 3.5) score -= 10;
        score = clamp(Math.round(score), 0, 100);

        const detourByPassenger: Record<string, number> = {};
        for (const e of enriched) detourByPassenger[e.passenger_id] = e.eta_delta_min;

        // Persist suggestion
        const suggestedOrder = enriched.map((e) => ({
            passenger_id: e.passenger_id,
            pickup_point: e.pickup_point,
            pickup_label: e.pickup_label,
            eta_delta_min: e.eta_delta_min,
        }));

        const { error: insErr } = await admin.from("bundle_suggestions").insert({
            trip_id: tripId,
            driver_id: userId,
            passenger_ids: enriched.map((e) => e.passenger_id),
            suggested_order: suggestedOrder,
            detour_by_passenger: detourByPassenger,
            acceptability_score: score,
            model_version: "heuristic_poly_v1",
            computed_at: new Date().toISOString(),
        });

        if (insErr) return jres({ error: "bundle_insert_failed", details: insErr.message }, 500);

        // Best-effort log
        try {
            await admin.from("event_log").insert({
                actor_id: userId,
                event_type: "bundle_stops_ran",
                entity_type: "trip",
                entity_id: tripId,
                payload: { passengers: enriched.length, acceptability: score, model: "heuristic_poly_v1" },
            });
        } catch {
            // ignore
        }

        return jres({
            ok: true,
            trip_id: tripId,
            acceptability_score: score,
            suggested_order: suggestedOrder,
            detour_by_passenger: detourByPassenger,
        });
    } catch (e) {
        return jres({ error: (e as Error).message }, 500);
    }
});
