-- 004_live_trip_chat_tracking.sql
-- Optional: trip_messages + trip_locations with participant-safe RLS
-- Run AFTER 001-003

create or replace function public.is_trip_participant(p_trip_id uuid)
returns boolean
language sql
stable
as $$
  select
    auth.uid() is not null
    and (
      exists (
        select 1
        from public.trips t
        where t.id = p_trip_id
          and t.driver_id = auth.uid()
      )
      or exists (
        select 1
        from public.trip_requests r
        where r.trip_id = p_trip_id
          and r.passenger_id = auth.uid()
          and r.status = 'accepted'
      )
    );
$$;

create or replace function public.is_trip_driver(p_trip_id uuid)
returns boolean
language sql
stable
as $$
  select
    auth.uid() is not null
    and exists (
      select 1 from public.trips t
      where t.id = p_trip_id
        and t.driver_id = auth.uid()
    );
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

drop policy if exists "trip_messages_select_participants" on public.trip_messages;
create policy "trip_messages_select_participants"
on public.trip_messages for select
using (public.is_trip_participant(trip_id));

drop policy if exists "trip_messages_insert_participants" on public.trip_messages;
create policy "trip_messages_insert_participants"
on public.trip_messages for insert
with check (sender_id = auth.uid() and public.is_trip_participant(trip_id));

drop policy if exists "trip_messages_update_none" on public.trip_messages;
create policy "trip_messages_update_none"
on public.trip_messages for update
using (false);

drop policy if exists "trip_messages_delete_none" on public.trip_messages;
create policy "trip_messages_delete_none"
on public.trip_messages for delete
using (false);

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

drop policy if exists "trip_locations_select_participants" on public.trip_locations;
create policy "trip_locations_select_participants"
on public.trip_locations for select
using (public.is_trip_participant(trip_id));

drop policy if exists "trip_locations_insert_driver_only" on public.trip_locations;
create policy "trip_locations_insert_driver_only"
on public.trip_locations for insert
with check (user_id = auth.uid() and public.is_trip_driver(trip_id));

drop policy if exists "trip_locations_update_none" on public.trip_locations;
create policy "trip_locations_update_none"
on public.trip_locations for update
using (false);

drop policy if exists "trip_locations_delete_none" on public.trip_locations;
create policy "trip_locations_delete_none"
on public.trip_locations for delete
using (false);
