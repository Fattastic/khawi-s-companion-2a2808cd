-- 011_route_summaries.sql
-- Add route summary columns to trips and pickup location to requests
-- Upgrades Module A/G capabilities without requiring PostGIS types yet.

begin;

-- 1. Add route_km, route_minutes, route_bbox to trips
do $$
begin
  if to_regclass('public.trips') is not null then
    if not exists (
      select 1 from information_schema.columns
      where table_schema='public' and table_name='trips' and column_name='route_km'
    ) then
      alter table public.trips
        add column route_km numeric,
        add column route_minutes int,
        add column route_bbox jsonb; -- stored as {minLat, maxLat, minLng, maxLng}
    end if;
  end if;
end$$;

do $$
begin
  if to_regclass('public.trips') is not null then
    execute 'create index if not exists trips_neighborhood_departure_idx on public.trips(neighborhood_id, departure_time)';
  end if;
end$$;

-- 2. Add pickup_lat, pickup_lng, pickup_label to trip_requests
-- This allows precise pickups (instead of just passenger home location) for bundling.
do $$
begin
  if to_regclass('public.trip_requests') is not null then
    if not exists (
      select 1 from information_schema.columns
      where table_schema='public' and table_name='trip_requests' and column_name='pickup_lat'
    ) then
      alter table public.trip_requests
        add column pickup_lat double precision,
        add column pickup_lng double precision,
        add column pickup_label text;
    end if;
  end if;
end$$;

commit;
