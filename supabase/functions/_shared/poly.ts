import polyline from "https://esm.sh/@mapbox/polyline@1.2.0";
import type { LatLng } from "./geo.ts";
import { haversineKm } from "./geo.ts";

export function decodePolylineSafe(encoded?: string | null): LatLng[] {
    if (!encoded || typeof encoded !== "string" || encoded.length < 6) return [];
    try {
        const pts = polyline.decode(encoded) as [number, number][];
        return pts.map(([lat, lng]) => ({ lat, lng }));
    } catch {
        return [];
    }
}

/**
 * Uniform-ish downsampling to keep computations cheap.
 */
export function samplePolyline(points: LatLng[], targetSamples = 24): LatLng[] {
    if (points.length <= targetSamples) return points;
    const step = Math.max(1, Math.floor(points.length / targetSamples));
    const out: LatLng[] = [];
    for (let i = 0; i < points.length; i += step) out.push(points[i]);
    if (out[out.length - 1] !== points[points.length - 1]) out.push(points[points.length - 1]);
    return out;
}

export function nearestToRoute(p: LatLng, route: LatLng[]): { minKm: number; idx: number } {
    let bestKm = Infinity;
    let bestIdx = 0;
    for (let i = 0; i < route.length; i++) {
        const km = haversineKm(p, route[i]);
        if (km < bestKm) {
            bestKm = km;
            bestIdx = i;
        }
    }
    return { minKm: bestKm, idx: bestIdx };
}
