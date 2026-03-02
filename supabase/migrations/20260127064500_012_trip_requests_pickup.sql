-- 20260127064500_012_trip_requests_pickup.sql
-- Idempotent migration to ensure pickup columns exist and add index for bundling

begin;

-- Safe additions (in case 011 partially ran or was skipped, though 011 is in history)
alter table public.trip_requests
  add column if not exists pickup_lat double precision,
  add column if not exists pickup_lng double precision,
  add column if not exists pickup_label text;

-- Add index to speed up bundling queries that filter by lat/lng presence
create index if not exists trip_requests_pickup_idx
  on public.trip_requests (trip_id, passenger_id)
  where pickup_lat is not null and pickup_lng is not null;

commit;
