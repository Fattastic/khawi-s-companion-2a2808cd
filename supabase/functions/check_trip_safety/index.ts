// @ts-nocheck - Deno Edge Function (types resolve at runtime)
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface SafetyCheckRequest {
  trip_id: string;
  current_lat: number;
  current_lng: number;
  speed_kmh?: number;
  unexpected_stop_duration?: number;
}

interface SafetyCheckResponse {
  risk_score: number; // 0-100
  alerts: string[];
  recommendations: string[];
}

function jres(body: object, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}

// Haversine distance in km
function haversine(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

serve(async (req) => {
  if (req.method !== "POST") {
    return jres({ error: "method_not_allowed" }, 405);
  }

  try {
    const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
    const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
    const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const authHeader = req.headers.get("authorization") || "";
    const userClient = createClient(SUPABASE_URL, ANON_KEY, {
      global: { headers: { authorization: authHeader } },
    });
    const admin = createClient(SUPABASE_URL, SERVICE_KEY);

    // Verify user is authenticated
    const { data: userData } = await userClient.auth.getUser();
    const userId = userData?.user?.id;
    if (!userId) {
      return jres({ error: "unauthorized" }, 401);
    }

    const body: SafetyCheckRequest = await req.json().catch(() => ({} as SafetyCheckRequest));
    const { trip_id, current_lat, current_lng, speed_kmh = 0, unexpected_stop_duration = 0 } = body;

    if (!trip_id || current_lat === undefined || current_lng === undefined) {
      return jres({ error: "invalid_input", hint: "trip_id, current_lat, current_lng required" }, 400);
    }

    // Fetch trip details
    const { data: trip, error: tripErr } = await admin
      .from("trips")
      .select("id, driver_id, origin_lat, origin_lng, dest_lat, dest_lng, polyline, status")
      .eq("id", trip_id)
      .single();

    if (tripErr || !trip) {
      return jres({ error: "trip_not_found" }, 404);
    }

    // Verify user is participant
    const isDriver = trip.driver_id === userId;
    const { data: requestData } = await admin
      .from("trip_requests")
      .select("id")
      .eq("trip_id", trip_id)
      .eq("passenger_id", userId)
      .eq("status", "accepted")
      .maybeSingle();

    const isPassenger = !!requestData;
    if (!isDriver && !isPassenger) {
      return jres({ error: "not_trip_participant" }, 403);
    }

    // Calculate risk factors
    let riskScore = 0;
    const alerts: string[] = [];
    const recommendations: string[] = [];

    // 1. Route deviation check (simplified - check distance from expected path)
    const distFromOrigin = haversine(current_lat, current_lng, trip.origin_lat, trip.origin_lng);
    const distFromDest = haversine(current_lat, current_lng, trip.dest_lat, trip.dest_lng);
    const tripDistance = haversine(trip.origin_lat, trip.origin_lng, trip.dest_lat, trip.dest_lng);
    
    // If we're further from both origin and dest than the trip length, that's suspicious
    const maxReasonableDeviation = Math.max(tripDistance * 0.5, 5); // 50% of trip or 5km
    if (distFromOrigin > tripDistance + maxReasonableDeviation && 
        distFromDest > maxReasonableDeviation) {
      riskScore += 30;
      alerts.push("significant_route_deviation");
      recommendations.push("Verify driver is on correct route");
    }

    // 2. Speed anomaly check
    if (speed_kmh > 140) {
      riskScore += 25;
      alerts.push("excessive_speed");
      recommendations.push("Driver exceeding safe speed limits");
    } else if (speed_kmh > 120) {
      riskScore += 10;
      alerts.push("high_speed");
    }

    // 3. Unexpected stop check
    if (unexpected_stop_duration > 10) { // More than 10 minutes
      riskScore += 20;
      alerts.push("prolonged_stop");
      recommendations.push("Vehicle stopped for extended period");
    } else if (unexpected_stop_duration > 5) {
      riskScore += 10;
      alerts.push("brief_stop");
    }

    // 4. Time anomaly (trip taking too long)
    // This would require tracking trip start time - simplified here

    // 5. Check for fraud flags on driver
    const { data: fraudFlags } = await admin
      .from("fraud_flags")
      .select("id, flag_type, severity")
      .eq("entity_id", trip.driver_id)
      .is("resolved_at", null)
      .limit(5);

    if (fraudFlags && fraudFlags.length > 0) {
      const highSeverity = fraudFlags.filter((f: any) => f.severity === "high");
      if (highSeverity.length > 0) {
        riskScore += 25;
        alerts.push("driver_fraud_flags");
        recommendations.push("Driver has active safety concerns");
      } else {
        riskScore += 10;
        alerts.push("driver_minor_flags");
      }
    }

    // Cap risk score at 100
    riskScore = Math.min(100, riskScore);

    // Add general recommendations based on risk level
    if (riskScore >= 75) {
      recommendations.push("Consider triggering SOS if you feel unsafe");
    } else if (riskScore >= 40) {
      recommendations.push("Stay alert and monitor your surroundings");
    }

    const response: SafetyCheckResponse = {
      risk_score: riskScore,
      alerts,
      recommendations,
    };

    // Log safety check for analytics (optional)
    await admin.from("trip_locations").insert({
      trip_id,
      user_id: userId,
      lat: current_lat,
      lng: current_lng,
      speed: speed_kmh / 3.6, // Convert to m/s
    }).catch(() => {}); // Silent fail for logging

    return jres(response);
  } catch (error) {
    console.error("Safety check error:", error);
    return jres({ 
      risk_score: 0, 
      alerts: [], 
      recommendations: [],
      error: "internal_error" 
    }, 500);
  }
});
