-- 002_rls_core_privacy.sql
-- Khawi! RLS: profiles/trips/trip_requests + Women-only + Neighborhood
-- Run AFTER 001_init_core.sql

alter table public.profiles enable row level security;
alter table public.trips enable row level security;
alter table public.trip_requests enable row level security;

create or replace function public.me_profile()
returns table (id uuid, gender text, neighborhood_id text)
language sql
stable
as $$
  select p.id, p.gender, p.neighborhood_id
  from public.profiles p
  where p.id = auth.uid()
$$;

-- PROFILES
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
on public.profiles for select
using (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
on public.profiles for update
using (auth.uid() = id)
with check (auth.uid() = id);

-- TRIPS SELECT privacy (drivers always see their own)
drop policy if exists "trips_select_with_privacy" on public.trips;
create policy "trips_select_with_privacy"
on public.trips
for select
using (
  driver_id = auth.uid()
  OR
  (
    (
      women_only = false
      OR (
        women_only = true
        AND exists (select 1 from public.me_profile() mp where mp.gender = 'female')
      )
    )
    AND
    (
      neighborhood_id is null
      OR exists (
        select 1 from public.me_profile() mp
        where mp.neighborhood_id is not null
          and mp.neighborhood_id = public.trips.neighborhood_id
      )
    )
  )
);

-- TRIPS write (driver only)
drop policy if exists "trips_insert_driver_only" on public.trips;
create policy "trips_insert_driver_only"
on public.trips for insert
with check (auth.uid() = driver_id);

drop policy if exists "trips_update_driver_only" on public.trips;
create policy "trips_update_driver_only"
on public.trips for update
using (auth.uid() = driver_id)
with check (auth.uid() = driver_id);

-- TRIP REQUESTS
drop policy if exists "requests_select_passenger" on public.trip_requests;
create policy "requests_select_passenger"
on public.trip_requests for select
using (auth.uid() = passenger_id);

drop policy if exists "requests_select_driver" on public.trip_requests;
create policy "requests_select_driver"
on public.trip_requests for select
using (auth.uid() = driver_id);

drop policy if exists "requests_insert_passenger" on public.trip_requests;
create policy "requests_insert_passenger"
on public.trip_requests for insert
with check (auth.uid() = passenger_id);

drop policy if exists "requests_update_passenger_cancel_only" on public.trip_requests;
create policy "requests_update_passenger_cancel_only"
on public.trip_requests for update
using (auth.uid() = passenger_id)
with check (auth.uid() = passenger_id and status = 'cancelled');

drop policy if exists "requests_update_driver_outcomes" on public.trip_requests;
create policy "requests_update_driver_outcomes"
on public.trip_requests for update
using (auth.uid() = driver_id)
with check (auth.uid() = driver_id and status in ('accepted','declined','expired'));
