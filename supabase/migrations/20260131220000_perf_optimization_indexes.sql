-- 20260131220000_perf_optimization_indexes.sql
-- Optimizing query performance based on audit findings (Spatial, RLS, Realtime)

BEGIN;

-- 1. TRIPS SPATIAL INDEXES
-- Support bounding box queries without PostGIS (lat/lng range)
-- Single column indexes allow Bitmap Intersection for flexible queries
CREATE INDEX IF NOT EXISTS trips_origin_lat_idx ON public.trips (origin_lat);
CREATE INDEX IF NOT EXISTS trips_origin_lng_idx ON public.trips (origin_lng);
CREATE INDEX IF NOT EXISTS trips_dest_lat_idx ON public.trips (dest_lat);
CREATE INDEX IF NOT EXISTS trips_dest_lng_idx ON public.trips (dest_lng);

-- 2. TRIP REQUESTS RLS OPTIMIZATION
-- Optimizes "is_trip_participant" checks which run frequently on chat/tracking
-- Covers the common query: where trip_id=? and passenger_id=? and status=?
CREATE INDEX IF NOT EXISTS trip_requests_rls_lookup_idx 
ON public.trip_requests (trip_id, passenger_id, status);

-- 3. TRIP LOCATIONS REALTIME OPTIMIZATION
-- Optimize "Get latest location" query: order by created_at desc limit 1
-- Replacing the simple foreign key index with a compound index including the sort key
DROP INDEX IF EXISTS trip_locations_trip_idx;

CREATE INDEX IF NOT EXISTS trip_locations_latest_idx 
ON public.trip_locations (trip_id, created_at DESC);

COMMIT;
