begin;

-- Feature flags ON
insert into public.feature_flags(name, enabled, rollout_percentage)
values
  ('ai.trustscore', true, 100),
  ('ai.area_incentives', true, 100),
  ('ai.fraud', true, 100)
on conflict (name) do update set enabled = excluded.enabled, rollout_percentage = excluded.rollout_percentage;

-- Ensure pickup columns exist (safe)
alter table public.trip_requests
  add column if not exists pickup_lat double precision,
  add column if not exists pickup_lng double precision,
  add column if not exists pickup_label text;

-- Pick 2 drivers + 2 passengers from existing auth users/profiles
-- (role filters match your schema)
with
drivers as (
  select id from public.profiles where role='driver' limit 2
),
passengers as (
  select id from public.profiles where role='passenger' limit 2
),
d as (select (array_agg(id))[1] as d1, (array_agg(id))[2] as d2 from drivers),
p as (select (array_agg(id))[1] as p1, (array_agg(id))[2] as p2 from passengers)

-- Create 2 trips
insert into public.trips(
  driver_id, origin_lat, origin_lng, dest_lat, dest_lng,
  origin_label, dest_label, polyline,
  departure_time, seats_total, seats_available,
  women_only, tags, status, is_kids_ride, neighborhood_id
)
select
  d.d1, 24.7136, 46.6753, 24.7743, 46.7386,
  'A', 'B', null,
  now() + interval '2 hours', 3, 2,
  false, array['quiet'], 'planned', false, 'n1'
from d
where d.d1 is not null
union all
select
  d.d2, 24.7136, 46.6753, 24.7000, 46.8000,
  'A', 'C', null,
  now() + interval '3 hours', 3, 3,
  false, array['fast'], 'planned', false, 'n2'
from d
where d.d2 is not null;

-- Create requests against the newest trips
with
latest_trips as (
  select id, driver_id from public.trips order by created_at desc limit 2
),
t as (
  select (array_agg(id))[1] as t1, (array_agg(id))[2] as t2,
         (array_agg(driver_id))[1] as d1, (array_agg(driver_id))[2] as d2
  from latest_trips
),
passengers as (
  select id from public.profiles where role='passenger' limit 2
),
p as (select (array_agg(id))[1] as p1, (array_agg(id))[2] as p2 from passengers)

insert into public.trip_requests(trip_id, passenger_id, status, pickup_lat, pickup_lng, pickup_label)
select t.t1, p.p1, 'accepted', 24.7200, 46.6800, 'Pickup 1'
from t, p
where t.t1 is not null and p.p1 is not null
on conflict do nothing;

commit;
