-- 001_init_core.sql
-- Khawi! Core tables: profiles, trips, trip_requests (+ triggers/helpers)
-- Note: Assumes Supabase auth schema exists. Run in Supabase SQL editor.

-- Extensions (optional)
-- create extension if not exists "pgcrypto";
-- create extension if not exists postgis;

-- =========================
-- Helper: updated_at trigger
-- =========================
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- =========================
-- PROFILES
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

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', ''),
    new.raw_user_meta_data->>'avatar_url'
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- =========================
-- TRIPS
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
create index if not exists trips_women_only_idx on public.trips(women_only);

drop trigger if exists trg_trips_updated_at on public.trips;
create trigger trg_trips_updated_at
before update on public.trips
for each row execute function public.set_updated_at();

-- =========================
-- TRIP REQUESTS
-- =========================
create table if not exists public.trip_requests (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  passenger_id uuid not null references public.profiles(id) on delete cascade,
  driver_id uuid, -- denormalized for realtime + RLS, filled by trigger
  status text not null default 'pending'
    check (status in ('pending','accepted','declined','cancelled','expired')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint uniq_trip_passenger unique (trip_id, passenger_id)
);

create index if not exists trip_requests_trip_id_idx on public.trip_requests(trip_id);
create index if not exists trip_requests_passenger_id_idx on public.trip_requests(passenger_id);
create index if not exists trip_requests_driver_id_idx on public.trip_requests(driver_id);
create index if not exists trip_requests_status_idx on public.trip_requests(status);

drop trigger if exists trg_trip_requests_updated_at on public.trip_requests;
create trigger trg_trip_requests_updated_at
before update on public.trip_requests
for each row execute function public.set_updated_at();

-- Fill driver_id on insert
create or replace function public.fill_request_driver_id()
returns trigger language plpgsql as $$
begin
  select t.driver_id into new.driver_id
  from public.trips t
  where t.id = new.trip_id;

  if new.driver_id is null then
    raise exception 'Trip not found for request';
  end if;

  return new;
end;
$$;

drop trigger if exists trg_fill_request_driver_id on public.trip_requests;
create trigger trg_fill_request_driver_id
before insert on public.trip_requests
for each row execute function public.fill_request_driver_id();
