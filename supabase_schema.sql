-- =========================
-- 0) Extensions & Cleanup
-- =========================
create extension if not exists postgis;

-- =========================
-- 1) PROFILES table
-- =========================
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null default '',
  avatar_url text,
  role text not null default 'passenger' check (role in ('passenger','driver','junior')),
  is_premium boolean not null default false,
  is_verified boolean not null default false,
  total_xp integer not null default 0,
  redeemable_xp integer not null default 0,
  gender text check (gender in ('male','female') or gender is null),
  neighborhood_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists profiles_role_idx on public.profiles(role);

-- Helper: Update updated_at
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;
drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at before update on public.profiles for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;
create policy "profiles_select_own" on public.profiles for select using (auth.uid() = id);
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

-- Auto-create profile
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', ''), new.raw_user_meta_data->>'avatar_url')
  on conflict (id) do nothing;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();

-- Helper: me_profile
create or replace function public.me_profile() returns table (id uuid, gender text, neighborhood_id text) language sql stable as $$
  select p.id, p.gender, p.neighborhood_id from public.profiles p where p.id = auth.uid()
$$;

-- =========================
-- 2) TRIPS table (Standard Carpool)
-- =========================
create table if not exists public.trips (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid not null references public.profiles(id) on delete cascade,
  origin_lat double precision not null,
  origin_lng double precision not null,
  dest_lat double precision not null,
  dest_lng double precision not null,
  origin_label text,
  dest_label text,
  polyline text,
  departure_time timestamptz not null,
  is_recurring boolean not null default false,
  schedule_json jsonb,
  seats_total integer not null default 1 check (seats_total >= 1),
  seats_available integer not null default 1 check (seats_available >= 0),
  women_only boolean not null default false,
  tags text[] not null default '{}'::text[],
  status text not null default 'planned' check (status in ('planned','active','completed','cancelled')),
  is_kids_ride boolean not null default false,
  neighborhood_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists trips_driver_id_idx on public.trips(driver_id);
create index if not exists trips_status_time_idx on public.trips(status, departure_time);
drop trigger if exists trg_trips_updated_at on public.trips;
create trigger trg_trips_updated_at before update on public.trips for each row execute function public.set_updated_at();

alter table public.trips enable row level security;
create policy "trips_select_with_privacy" on public.trips for select using (
  driver_id = auth.uid() OR (
    (women_only = false OR (women_only = true AND exists (select 1 from public.me_profile() mp where mp.gender = 'female')))
    AND
    (neighborhood_id is null OR exists (select 1 from public.me_profile() mp where mp.neighborhood_id is not null and mp.neighborhood_id = public.trips.neighborhood_id))
  )
);
create policy "trips_insert_driver_only" on public.trips for insert with check (auth.uid() = driver_id);
create policy "trips_update_driver_only" on public.trips for update using (auth.uid() = driver_id) with check (auth.uid() = driver_id);

-- =========================
-- 3) TRIP REQUESTS table
-- =========================
create table if not exists public.trip_requests (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  passenger_id uuid not null references public.profiles(id) on delete cascade,
  driver_id uuid references public.profiles(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted','declined','cancelled','expired')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint uniq_trip_passenger unique (trip_id, passenger_id)
);
create index if not exists trip_requests_trip_id_idx on public.trip_requests(trip_id);
create index if not exists trip_requests_passenger_id_idx on public.trip_requests(passenger_id);
create index if not exists trip_requests_driver_id_idx on public.trip_requests(driver_id);
drop trigger if exists trg_trip_requests_updated_at on public.trip_requests;
create trigger trg_trip_requests_updated_at before update on public.trip_requests for each row execute function public.set_updated_at();

-- Auto-fill driver_id
create or replace function public.fill_request_driver_id() returns trigger language plpgsql as $$
begin
  select t.driver_id into new.driver_id from public.trips t where t.id = new.trip_id;
  if new.driver_id is null then raise exception 'Trip not found for request'; end if;
  return new;
end;
$$;
drop trigger if exists trg_fill_request_driver_id on public.trip_requests;
create trigger trg_fill_request_driver_id before insert on public.trip_requests for each row execute function public.fill_request_driver_id();

alter table public.trip_requests enable row level security;
create policy "requests_select_own" on public.trip_requests for select using (auth.uid() = passenger_id);
create policy "requests_select_driver" on public.trip_requests for select using (auth.uid() = driver_id);
create policy "requests_insert_own" on public.trip_requests for insert with check (auth.uid() = passenger_id);
create policy "requests_update_own_cancel_only" on public.trip_requests for update using (auth.uid() = passenger_id) with check (auth.uid() = passenger_id and status = 'cancelled');
create policy "requests_update_driver_accept_decline" on public.trip_requests for update using (auth.uid() = driver_id) with check (auth.uid() = driver_id and status in ('accepted','declined','expired'));

-- =========================
-- 4) REALTIME (Messages & Locations)
-- =========================
-- Helpers
create or replace function public.is_trip_participant(p_trip_id uuid) returns boolean language sql stable as $$
  select auth.uid() is not null and (
    exists (select 1 from public.trips t where t.id = p_trip_id and t.driver_id = auth.uid())
    or exists (select 1 from public.trip_requests r where r.trip_id = p_trip_id and r.passenger_id = auth.uid() and r.status = 'accepted')
  );
$$;
create or replace function public.is_trip_driver(p_trip_id uuid) returns boolean language sql stable as $$
  select auth.uid() is not null and exists (select 1 from public.trips t where t.id = p_trip_id and t.driver_id = auth.uid());
$$;

create table if not exists public.trip_messages (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);
create index if not exists trip_messages_trip_idx on public.trip_messages(trip_id);
alter table public.trip_messages enable row level security;
create policy "trip_messages_select_participants" on public.trip_messages for select using (public.is_trip_participant(trip_id));
create policy "trip_messages_insert_participants" on public.trip_messages for insert with check (sender_id = auth.uid() and public.is_trip_participant(trip_id));

create table if not exists public.trip_locations (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  lat double precision not null,
  lng double precision not null,
  heading double precision,
  speed double precision,
  created_at timestamptz not null default now()
);
create index if not exists trip_locations_trip_idx on public.trip_locations(trip_id);
alter table public.trip_locations enable row level security;
create policy "trip_locations_select_participants" on public.trip_locations for select using (public.is_trip_participant(trip_id));
create policy "trip_locations_insert_driver_only" on public.trip_locations for insert with check (user_id = auth.uid() and public.is_trip_driver(trip_id));

-- =========================
-- 5) KHAWI JUNIOR (Merged Safety & Grants Model)
-- =========================

-- Core Tables
create table if not exists public.kids (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  avatar_url text,
  school_name text,
  notes text,
  created_at timestamptz not null default now()
);
create index if not exists kids_parent_idx on public.kids(parent_id);

create table if not exists public.trusted_drivers (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid not null references public.profiles(id) on delete cascade,
  driver_id uuid not null references public.profiles(id) on delete cascade,
  label text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique(parent_id, driver_id)
);
alter table public.trusted_drivers enable row level security;
create policy trusted_select_parent on public.trusted_drivers for select using (auth.uid() = parent_id);
create policy trusted_write_parent on public.trusted_drivers for insert with check (auth.uid() = parent_id);

create table if not exists public.junior_runs (
  id uuid primary key default gen_random_uuid(),
  kid_id uuid not null references public.kids(id) on delete cascade,
  parent_id uuid not null references public.profiles(id) on delete cascade,
  assigned_driver_id uuid references public.profiles(id) on delete set null,
  status text not null default 'planned' check (status in ('planned','driver_assigned','picked_up','arrived','completed','cancelled')),
  pickup_lat double precision not null,
  pickup_lng double precision not null,
  dropoff_lat double precision not null,
  dropoff_lng double precision not null,
  pickup_time timestamptz not null,
  trip_id uuid references public.trips(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists junior_runs_parent_idx on public.junior_runs(parent_id);
create index if not exists junior_runs_driver_idx on public.junior_runs(assigned_driver_id);
drop trigger if exists trg_junior_runs_updated_at on public.junior_runs;
create trigger trg_junior_runs_updated_at before update on public.junior_runs for each row execute function public.set_updated_at();

-- Grants Table (Time-Limited Access)
create table if not exists public.junior_driver_grants (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid not null references public.profiles(id) on delete cascade,
  driver_id uuid not null references public.profiles(id) on delete cascade,
  kid_id uuid references public.kids(id) on delete cascade,
  run_id uuid references public.junior_runs(id) on delete cascade,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  constraint grant_time_valid check (ends_at > starts_at)
);
create index if not exists jdg_driver_idx on public.junior_driver_grants(driver_id, starts_at, ends_at);

-- Audit Trail
create table if not exists public.junior_run_events (
  id uuid primary key default gen_random_uuid(),
  run_id uuid not null references public.junior_runs(id) on delete cascade,
  actor_id uuid not null references public.profiles(id) on delete cascade,
  actor_role text not null check (actor_role in ('parent','driver','system')),
  event_type text not null check (event_type in ('created','driver_assigned','picked_up','arrived','completed','cancelled','note')),
  prev_status text,
  new_status text,
  lat double precision,
  lng double precision,
  meta jsonb,
  created_at timestamptz not null default now()
);
create index if not exists junior_run_events_run_idx on public.junior_run_events(run_id, created_at);

-- SOS Events
create table if not exists public.sos_events (
  id uuid primary key default gen_random_uuid(),
  run_id uuid references public.junior_runs(id) on delete set null,
  trip_id uuid references public.trips(id) on delete set null,
  triggered_by uuid not null references public.profiles(id) on delete cascade,
  parent_id uuid references public.profiles(id) on delete set null,
  driver_id uuid references public.profiles(id) on delete set null,
  kind text not null default 'sos' check (kind in ('sos','panic','medical','traffic_accident','harassment','other')),
  severity int not null default 3 check (severity between 1 and 5),
  lat double precision not null,
  lng double precision not null,
  message text,
  meta jsonb,
  status text not null default 'open' check (status in ('open','acknowledged','resolved','false_alarm')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists sos_events_parent_idx on public.sos_events(parent_id, created_at);
drop trigger if exists trg_sos_updated_at on public.sos_events;
create trigger trg_sos_updated_at before update on public.sos_events for each row execute function public.set_updated_at();

-- Invite Codes
create table if not exists public.junior_invite_codes (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid not null references public.profiles(id) on delete cascade,
  run_id uuid not null references public.junior_runs(id) on delete cascade,
  code text not null,
  expires_at timestamptz not null,
  is_used boolean not null default false,
  created_at timestamptz not null default now(),
  unique(run_id), unique(code)
);

-- JUNIOR RUN LOCATIONS (Live Tracking)
create table if not exists public.junior_run_locations (
  id uuid primary key default gen_random_uuid(),
  run_id uuid not null references public.junior_runs(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  lat double precision not null,
  lng double precision not null,
  heading double precision,
  speed double precision,
  accuracy double precision,
  created_at timestamptz not null default now()
);
create index if not exists jrl_run_idx on public.junior_run_locations(run_id, created_at);
create index if not exists jrl_user_idx on public.junior_run_locations(user_id, created_at);

create or replace view public.junior_run_latest_location as
select distinct on (run_id)
  run_id, user_id, lat, lng, heading, speed, accuracy, created_at
from public.junior_run_locations
order by run_id, created_at desc;

-- =========================
-- 6) Helper Functions (Access Control)
-- =========================
create or replace function public.has_active_grant_for_run(p_run_id uuid) returns boolean language sql stable as $$
  select auth.uid() is not null and exists (select 1 from public.junior_driver_grants g where g.run_id = p_run_id and g.driver_id = auth.uid() and g.is_active = true and now() >= g.starts_at and now() <= g.ends_at);
$$;
create or replace function public.has_active_grant_for_kid(p_kid_id uuid) returns boolean language sql stable as $$
  select auth.uid() is not null and exists (select 1 from public.junior_driver_grants g where g.kid_id = p_kid_id and g.driver_id = auth.uid() and g.is_active = true and now() >= g.starts_at and now() <= g.ends_at);
$$;
create or replace function public.is_run_driver_with_grant(p_run_id uuid) returns boolean language sql stable as $$
  select auth.uid() is not null and exists (select 1 from public.junior_runs r where r.id = p_run_id and auth.uid() = r.assigned_driver_id and public.has_active_grant_for_run(p_run_id));
$$;
create or replace function public.is_run_party(p_run_id uuid) returns boolean language sql stable as $$
  select auth.uid() is not null and exists (select 1 from public.junior_runs r where r.id = p_run_id and (auth.uid() = r.parent_id or (auth.uid() = r.assigned_driver_id and public.has_active_grant_for_run(p_run_id))));
$$;

-- =========================
-- 7) RLS POLICIES (Merged & Strict)
-- =========================
alter table public.kids enable row level security;
alter table public.junior_runs enable row level security;
alter table public.junior_driver_grants enable row level security;
alter table public.junior_run_events enable row level security;
alter table public.sos_events enable row level security;
alter table public.junior_invite_codes enable row level security;
alter table public.junior_run_locations enable row level security;

-- kids
create policy kids_select_safe on public.kids for select using (auth.uid() = parent_id OR public.has_active_grant_for_kid(id));
create policy kids_insert_parent on public.kids for insert with check (auth.uid() = parent_id);
create policy kids_update_parent on public.kids for update using (auth.uid() = parent_id) with check (auth.uid() = parent_id);
create policy kids_delete_parent on public.kids for delete using (auth.uid() = parent_id);

-- junior_runs
create policy jr_select_safe on public.junior_runs for select using (auth.uid() = parent_id OR public.is_run_driver_with_grant(id));
create policy jr_insert_parent on public.junior_runs for insert with check (auth.uid() = parent_id);
create policy jr_update_parent on public.junior_runs for update using (auth.uid() = parent_id) with check (auth.uid() = parent_id);
create policy jr_update_driver_granted on public.junior_runs for update using (public.is_run_driver_with_grant(id)) with check (public.is_run_driver_with_grant(id));
create policy jr_delete_parent on public.junior_runs for delete using (auth.uid() = parent_id);

-- grants
create policy jdg_parent_select on public.junior_driver_grants for select using (auth.uid() = parent_id);
create policy jdg_parent_insert on public.junior_driver_grants for insert with check (auth.uid() = parent_id);
create policy jdg_parent_update on public.junior_driver_grants for update using (auth.uid() = parent_id) with check (auth.uid() = parent_id);
create policy jdg_driver_select on public.junior_driver_grants for select using (auth.uid() = driver_id);

-- events (audit)
create policy jr_events_select_safe on public.junior_run_events for select using (public.is_run_party(run_id));
create policy jr_events_insert_none on public.junior_run_events for insert with check (false);
create policy jr_events_update_none on public.junior_run_events for update using (false);
create policy jr_events_delete_none on public.junior_run_events for delete using (false);

-- sos
create policy sos_select_safe on public.sos_events for select using (auth.uid() = triggered_by OR auth.uid() = parent_id OR auth.uid() = driver_id);
create policy sos_insert_none on public.sos_events for insert with check (false);
create policy sos_update_none on public.sos_events for update using (false);

-- invite codes
create policy jic_parent_select on public.junior_invite_codes for select using (auth.uid() = parent_id);
create policy jic_parent_insert on public.junior_invite_codes for insert with check (auth.uid() = parent_id);
create policy jic_parent_update on public.junior_invite_codes for update using (auth.uid() = parent_id);

-- junior_run_locations
create policy jrl_select_safe on public.junior_run_locations for select using (public.is_run_party(run_id));
create policy jrl_insert_none on public.junior_run_locations for insert with check (false);
create policy jrl_update_none on public.junior_run_locations for update using (false);
create policy jrl_delete_none on public.junior_run_locations for delete using (false);

-- =========================
-- 8) RPCs (Merged & Safe)
-- =========================

-- Create Grant & Assign Driver
create or replace function public.create_run_grant_and_assign_driver(p_run_id uuid, p_driver_id uuid, p_starts_at timestamptz, p_ends_at timestamptz) returns public.junior_driver_grants language plpgsql security definer as $$
declare v_run public.junior_runs; v_grant public.junior_driver_grants;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  select * into v_run from public.junior_runs where id = p_run_id for update;
  if not found then raise exception 'Run not found'; end if;
  if v_run.parent_id <> auth.uid() then raise exception 'Not authorized'; end if;
  if not exists (select 1 from public.trusted_drivers td where td.parent_id = auth.uid() and td.driver_id = p_driver_id and td.is_active = true) then raise exception 'Driver is not trusted'; end if;
  update public.junior_runs set assigned_driver_id = p_driver_id, status = case when status='planned' then 'driver_assigned' else status end, updated_at = now() where id = p_run_id;
  insert into public.junior_driver_grants(parent_id, driver_id, kid_id, run_id, starts_at, ends_at, is_active) values (auth.uid(), p_driver_id, v_run.kid_id, p_run_id, p_starts_at, p_ends_at, true) returning * into v_grant;
  insert into public.junior_run_events(run_id, actor_id, actor_role, event_type, prev_status, new_status, meta) values (p_run_id, auth.uid(), 'parent', 'driver_assigned', v_run.status, 'driver_assigned', jsonb_build_object('assigned_driver_id', p_driver_id, 'grant_id', v_grant.id));
  return v_grant;
end;
$$;
grant execute on function public.create_run_grant_and_assign_driver(uuid, uuid, timestamptz, timestamptz) to authenticated;
alter function public.create_run_grant_and_assign_driver(uuid, uuid, timestamptz, timestamptz) set row_security = on;

-- Revoke Grant
create or replace function public.revoke_driver_grant(p_grant_id uuid) returns void language plpgsql security definer as $$
declare v public.junior_driver_grants;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  select * into v from public.junior_driver_grants where id = p_grant_id for update;
  if not found then raise exception 'Grant not found'; end if;
  if v.parent_id <> auth.uid() then raise exception 'Not authorized'; end if;
  update public.junior_driver_grants set is_active = false where id = p_grant_id;
  if v.run_id is not null then
    insert into public.junior_run_events(run_id, actor_id, actor_role, event_type, meta) values (v.run_id, auth.uid(), 'parent', 'note', jsonb_build_object('action', 'revoke_grant', 'grant_id', v.id));
  end if;
end;
$$;
grant execute on function public.revoke_driver_grant(uuid) to authenticated;
alter function public.revoke_driver_grant(uuid) set row_security = on;

-- Update Run Status (Strict Transitions)
create or replace function public.update_junior_run_status(p_run_id uuid, p_new_status text, p_lat double precision default null, p_lng double precision default null, p_meta jsonb default null) returns public.junior_runs language plpgsql security definer as $$
declare v_run public.junior_runs; v_prev text; v_actor_role text;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  select * into v_run from public.junior_runs where id = p_run_id for update;
  if not found then raise exception 'Run not found'; end if;
  v_prev := v_run.status;
  if auth.uid() = v_run.parent_id then v_actor_role := 'parent';
  elsif auth.uid() = v_run.assigned_driver_id and public.has_active_grant_for_run(p_run_id) then v_actor_role := 'driver';
  else raise exception 'Not authorized'; end if;
  
  if p_new_status not in ('planned','driver_assigned','picked_up','arrived','completed','cancelled') then raise exception 'Invalid status'; end if;
  -- Strict transitions
  if p_new_status = 'driver_assigned' and (v_actor_role <> 'parent' or v_prev <> 'planned') then raise exception 'Invalid transition to driver_assigned'; end if;
  if p_new_status = 'picked_up' and (v_actor_role <> 'driver' or v_prev <> 'driver_assigned') then raise exception 'Invalid transition to picked_up'; end if;
  if p_new_status = 'arrived' and (v_actor_role <> 'driver' or v_prev <> 'picked_up') then raise exception 'Invalid transition to arrived'; end if;
  if p_new_status = 'completed' and v_prev <> 'arrived' then raise exception 'Invalid transition to completed'; end if;
  if p_new_status = 'cancelled' and v_actor_role <> 'parent' then raise exception 'Only parent can cancel'; end if;

  update public.junior_runs set status = p_new_status, updated_at = now() where id = p_run_id returning * into v_run;
  insert into public.junior_run_events(run_id, actor_id, actor_role, event_type, prev_status, new_status, lat, lng, meta) values (p_run_id, auth.uid(), v_actor_role, p_new_status, v_prev, p_new_status, p_lat, p_lng, p_meta);
  return v_run;
end;
$$;
grant execute on function public.update_junior_run_status(uuid, text, double precision, double precision, jsonb) to authenticated;
alter function public.update_junior_run_status(uuid, text, double precision, double precision, jsonb) set row_security = on;

-- Create SOS
create or replace function public.create_sos(p_run_id uuid default null, p_trip_id uuid default null, p_kind text default 'sos', p_severity int default 3, p_lat double precision, p_lng double precision, p_message text default null, p_meta jsonb default null) returns public.sos_events language plpgsql security definer as $$
declare v_sos public.sos_events; v_parent uuid; v_driver uuid;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  if p_run_id is not null then
    if not public.is_run_party(p_run_id) then raise exception 'Not authorized for run'; end if;
    select parent_id, assigned_driver_id into v_parent, v_driver from public.junior_runs where id = p_run_id;
  else
    select driver_id into v_driver from public.trips where id = p_trip_id;
    if v_driver is null then raise exception 'Trip not found'; end if;
  end if;
  insert into public.sos_events(run_id, trip_id, triggered_by, parent_id, driver_id, kind, severity, lat, lng, message, meta) values (p_run_id, p_trip_id, auth.uid(), v_parent, v_driver, p_kind, p_severity, p_lat, p_lng, p_message, p_meta) returning * into v_sos;
  if p_run_id is not null then
    insert into public.junior_run_events(run_id, actor_id, actor_role, event_type, lat, lng, meta) values (p_run_id, auth.uid(), 'note', 'note', p_lat, p_lng, jsonb_build_object('sos_id', v_sos.id, 'kind', p_kind));
  end if;
  return v_sos;
end;
$$;
grant execute on function public.create_sos(uuid, uuid, text, int, double precision, double precision, text, jsonb) to authenticated;
alter function public.create_sos(uuid, uuid, text, int, double precision, double precision, text, jsonb) set row_security = on;

-- Update SOS
create or replace function public.update_sos_status(p_sos_id uuid, p_new_status text) returns public.sos_events language plpgsql security definer as $$
declare v public.sos_events;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  select * into v from public.sos_events where id = p_sos_id for update;
  if not found then raise exception 'SOS not found'; end if;
  -- Only involved parties can update
  if auth.uid() <> v.triggered_by and auth.uid() <> v.parent_id and auth.uid() <> v.driver_id then raise exception 'Not authorized'; end if;
  update public.sos_events set status = p_new_status, updated_at = now() where id = p_sos_id returning * into v;
  return v;
end;
$$;
grant execute on function public.update_sos_status(uuid, text) to authenticated;
alter function public.update_sos_status(uuid, text) set row_security = on;

-- Invite Codes (Create & Redeem)
create or replace function public.create_junior_invite_code(p_run_id uuid, p_minutes_valid int default 30) returns public.junior_invite_codes language plpgsql security definer as $$
declare v_run public.junior_runs; v_code text; v_row public.junior_invite_codes;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  select * into v_run from public.junior_runs where id = p_run_id for update;
  if not found then raise exception 'Run not found'; end if;
  if v_run.parent_id <> auth.uid() then raise exception 'Not authorized'; end if;
  v_code := lpad((floor(random()*1000000))::int::text, 6, '0');
  insert into public.junior_invite_codes(parent_id, run_id, code, expires_at) values (auth.uid(), p_run_id, v_code, now() + (p_minutes_valid || ' minutes')::interval) on conflict (run_id) do update set code = excluded.code, expires_at = excluded.expires_at, is_used = false returning * into v_row;
  return v_row;
end;
$$;
grant execute on function public.create_junior_invite_code(uuid, int) to authenticated;
alter function public.create_junior_invite_code(uuid, int) set row_security = on;

create or replace function public.redeem_junior_invite_code(p_code text) returns public.junior_driver_grants language plpgsql security definer as $$
declare v_inv public.junior_invite_codes; v_run public.junior_runs; v_grant public.junior_driver_grants; v_start timestamptz; v_end timestamptz;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  select * into v_inv from public.junior_invite_codes where code = p_code for update;
  if not found then raise exception 'Invalid code'; end if;
  if v_inv.is_used then raise exception 'Code already used'; end if;
  if now() > v_inv.expires_at then raise exception 'Code expired'; end if;
  select * into v_run from public.junior_runs where id = v_inv.run_id for update;
  if not exists (select 1 from public.trusted_drivers td where td.parent_id = v_run.parent_id and td.driver_id = auth.uid() and td.is_active = true) then raise exception 'Driver not trusted by parent'; end if;
  v_start := v_run.pickup_time - interval '60 minutes'; v_end := v_run.pickup_time + interval '120 minutes';
  update public.junior_runs set assigned_driver_id = auth.uid(), status = 'driver_assigned', updated_at = now() where id = v_run.id;
  insert into public.junior_driver_grants(parent_id, driver_id, kid_id, run_id, starts_at, ends_at, is_active) values (v_run.parent_id, auth.uid(), v_run.kid_id, v_run.id, v_start, v_end, true) returning * into v_grant;
  update public.junior_invite_codes set is_used = true where id = v_inv.id;
  insert into public.junior_run_events(run_id, actor_id, actor_role, event_type, prev_status, new_status, meta) values (v_run.id, auth.uid(), 'parent', 'driver_assigned', v_run.status, 'driver_assigned', jsonb_build_object('method', 'invite_code', 'grant_id', v_grant.id));
  return v_grant;
end;
$$;
grant execute on function public.redeem_junior_invite_code(text) to authenticated;
alter function public.redeem_junior_invite_code(text) set row_security = on;

-- Push Junior Location
create or replace function public.driver_push_junior_location(p_run_id uuid, p_lat double precision, p_lng double precision, p_heading double precision default null, p_speed double precision default null, p_accuracy double precision default null) returns public.junior_run_locations language plpgsql security definer as $$
declare v_run public.junior_runs; v_row public.junior_run_locations;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  select * into v_run from public.junior_runs where id = p_run_id for update;
  if not found then raise exception 'Run not found'; end if;
  if auth.uid() <> v_run.assigned_driver_id then raise exception 'Not authorized'; end if;
  if not public.has_active_grant_for_run(p_run_id) then raise exception 'Not authorized (no active grant window)'; end if;
  if v_run.status not in ('driver_assigned','picked_up','arrived') then raise exception 'Run is not in a trackable state'; end if;
  insert into public.junior_run_locations(run_id, user_id, lat, lng, heading, speed, accuracy) values (p_run_id, auth.uid(), p_lat, p_lng, p_heading, p_speed, p_accuracy) returning * into v_row;
  return v_row;
end;
$$;
grant execute on function public.driver_push_junior_location(uuid, double precision, double precision, double precision, double precision, double precision) to authenticated;
alter function public.driver_push_junior_location(uuid, double precision, double precision, double precision, double precision, double precision) set row_security = on;

-- XP Awarding (Standard)
create or replace function public.award_trip_xp(p_trip_id uuid, p_user_id uuid, p_base_xp integer, p_trip_start timestamptz) returns public.xp_events language plpgsql security definer as $$
declare v_mult numeric := 1; v_bonus int := 0; v_total int; v_g public.user_gamification;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  insert into public.user_gamification(user_id) values (p_user_id) on conflict (user_id) do nothing;
  v_total := (p_base_xp * v_mult)::int + v_bonus;
  insert into public.xp_events(user_id, trip_id, source, base_xp, multiplier, bonus_xp, total_xp, meta) values (p_user_id, p_trip_id, 'trip_completed', p_base_xp, v_mult, v_bonus, v_total, jsonb_build_object('valid', true)) returning * into strict result;
  update public.profiles set total_xp = total_xp + v_total where id = p_user_id;
  return result;
  declare result public.xp_events;
end;
$$;
grant execute on function public.award_trip_xp(uuid, uuid, integer, timestamptz) to authenticated;
alter function public.award_trip_xp(uuid, uuid, integer, timestamptz) set row_security = on;

-- =========================
-- 9) Gamification Tables
-- =========================
create table if not exists public.xp_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  trip_id uuid references public.trips(id) on delete set null,
  source text not null check (source in ('trip_completed','request_accepted','referral','daily_login','bonus')),
  base_xp integer not null,
  multiplier numeric not null default 1,
  bonus_xp integer not null default 0,
  total_xp integer not null,
  meta jsonb,
  created_at timestamptz not null default now()
);
create table if not exists public.user_gamification (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  streak_days integer not null default 0,
  last_active_date date,
  trips_completed_total integer not null default 0,
  trips_completed_today integer not null default 0,
  trips_completed_today_date date,
  updated_at timestamptz not null default now()
);
create table if not exists public.xp_rules (
  id uuid primary key default gen_random_uuid(),
  rule_key text unique not null,
  is_active boolean not null default true,
  config jsonb not null,
  updated_at timestamptz not null default now()
);

-- =========================
-- 10) AI MODULES (Phase 3 Migration)
-- =========================

-- Module A: AI Match Ranking
create table if not exists public.match_scores (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  trip_id uuid not null references public.trips(id) on delete cascade,
  match_score double precision not null check (match_score >= 0 and match_score <= 100),
  accept_prob double precision check (accept_prob >= 0 and accept_prob <= 1),
  detour_minutes double precision,
  overlap_ratio double precision,
  explanation_tags text[], -- e.g. ['high_overlap', 'reliable_driver']
  computed_at timestamptz not null default now(),
  unique(user_id, trip_id)
);
create index if not exists idx_match_scores_user on public.match_scores(user_id);
alter table public.match_scores enable row level security;
create policy "match_scores_select_own" on public.match_scores for select using (auth.uid() = user_id);

-- Module C: Dynamic XP Incentives
create table if not exists public.area_incentives (
  id uuid primary key default gen_random_uuid(),
  area_id text not null, -- Geohash or Neighborhood ID
  time_bucket timestamptz not null, -- e.g. rounded to hour
  dynamic_xp_multiplier double precision not null default 1.0,
  reason_tag text, -- 'high_demand', 'rain'
  computed_at timestamptz not null default now()
);
create index if not exists idx_area_incentives on public.area_incentives(area_id, time_bucket);
alter table public.area_incentives enable row level security;
create policy "incentives_select_public" on public.area_incentives for select using (true);

-- Module D: Trust & Safety Scoring
create table if not exists public.trust_profiles (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  trust_score double precision not null default 50.0 check (trust_score >= 0 and trust_score <= 100),
  trust_badge text default 'bronze', -- bronze, silver, gold, junior_trusted
  junior_trusted boolean not null default false,
  computed_at timestamptz not null default now()
);
alter table public.trust_profiles enable row level security;
create policy "trust_profiles_select_public" on public.trust_profiles for select using (true);

-- Convenience view to fetch profile + trust in one query.
create or replace view public.profile_with_trust as
select
  p.*,
  t.trust_score,
  t.trust_badge,
  t.junior_trusted
from public.profiles p
left join public.trust_profiles t on t.user_id = p.id;
alter view public.profile_with_trust set (security_invoker = true);
grant select on public.profile_with_trust to authenticated, anon;
-- Note: RLS policies do not apply to views in all setups; security_invoker keeps
-- access aligned with underlying table policies.

-- Module E: Message Moderation
alter table public.trip_messages 
add column if not exists moderation_status text default 'pending' check (moderation_status in ('pending', 'approved', 'flagged', 'blocked')),
add column if not exists flagged_reason text;

create table if not exists public.moderation_events (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references public.trip_messages(id) on delete cascade,
  status text not null,
  reason_code text, -- 'profanity', 'harassment', 'spam'
  severity text, -- 'low', 'medium', 'high'
  model_version text,
  created_at timestamptz not null default now()
);
alter table public.moderation_events enable row level security;
create policy "mod_events_select_admin" on public.moderation_events for select using (false); -- Admin only

-- Module H: Fraud Detection
create table if not exists public.fraud_flags (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null, -- 'user', 'trip'
  entity_id uuid not null,
  flag_type text not null, -- 'xp_farming', 'looping'
  severity text default 'medium',
  evidence_json jsonb,
  created_at timestamptz not null default now(),
  resolved_at timestamptz
);
alter table public.fraud_flags enable row level security;
create policy "fraud_flags_select_admin" on public.fraud_flags for select using (false); -- Admin only
