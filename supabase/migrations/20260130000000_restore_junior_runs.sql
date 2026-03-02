-- 20260130000000_restore_junior_runs.sql
-- Restoration of Khawi Junior tables

begin;

-- Trusted drivers table (if not already created)
create table if not exists public.trusted_drivers (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid not null references public.profiles(id) on delete cascade,
  driver_id uuid not null references public.profiles(id) on delete cascade,
  label text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique(parent_id, driver_id)
);
create index if not exists trusted_drivers_parent_idx on public.trusted_drivers(parent_id);

alter table public.trusted_drivers enable row level security;

drop policy if exists trusted_select_parent on public.trusted_drivers;
create policy trusted_select_parent
on public.trusted_drivers for select
using (auth.uid() = parent_id);

drop policy if exists trusted_write_parent on public.trusted_drivers;
create policy trusted_write_parent
on public.trusted_drivers for insert
with check (auth.uid() = parent_id);

drop policy if exists trusted_update_parent on public.trusted_drivers;
create policy trusted_update_parent
on public.trusted_drivers for update
using (auth.uid() = parent_id)
with check (auth.uid() = parent_id);

-- Kids / Runs
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

create table if not exists public.junior_runs (
  id uuid primary key default gen_random_uuid(),
  kid_id uuid not null references public.kids(id) on delete cascade,
  parent_id uuid not null references public.profiles(id) on delete cascade,
  assigned_driver_id uuid references public.profiles(id) on delete set null,
  status text not null default 'planned'
    check (status in ('planned','driver_assigned','picked_up','arrived','completed','cancelled')),
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
create index if not exists junior_runs_kid_idx on public.junior_runs(kid_id);

drop trigger if exists trg_junior_runs_updated_at on public.junior_runs;
create trigger trg_junior_runs_updated_at
before update on public.junior_runs
for each row execute function public.set_updated_at();

-- Grants
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
create index if not exists jdg_parent_idx on public.junior_driver_grants(parent_id, created_at);
create index if not exists jdg_run_idx on public.junior_driver_grants(run_id);

-- Audit
create table if not exists public.junior_run_events (
  id uuid primary key default gen_random_uuid(),
  run_id uuid not null references public.junior_runs(id) on delete cascade,
  actor_id uuid not null references public.profiles(id) on delete cascade,
  actor_role text not null check (actor_role in ('parent','driver','system')),
  event_type text not null
    check (event_type in ('created','driver_assigned','picked_up','arrived','completed','cancelled','note')),
  prev_status text,
  new_status text,
  lat double precision,
  lng double precision,
  meta jsonb,
  created_at timestamptz not null default now()
);
create index if not exists junior_run_events_run_idx on public.junior_run_events(run_id, created_at);

-- SOS
create table if not exists public.sos_events (
  id uuid primary key default gen_random_uuid(),
  run_id uuid references public.junior_runs(id) on delete set null,
  trip_id uuid references public.trips(id) on delete set null,
  triggered_by uuid not null references public.profiles(id) on delete cascade,
  parent_id uuid references public.profiles(id) on delete set null,
  driver_id uuid references public.profiles(id) on delete set null,
  kind text not null default 'sos'
    check (kind in ('sos','panic','medical','traffic_accident','harassment','other')),
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
create index if not exists sos_events_driver_idx on public.sos_events(driver_id, created_at);

drop trigger if exists trg_sos_updated_at on public.sos_events;
create trigger trg_sos_updated_at
before update on public.sos_events
for each row execute function public.set_updated_at();

-- Junior live tracking
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

create or replace view public.junior_run_latest_location as
select distinct on (run_id)
  run_id, user_id, lat, lng, heading, speed, accuracy, created_at
from public.junior_run_locations
order by run_id, created_at desc;

-- Helpers
create or replace function public.has_active_grant_for_run(p_run_id uuid)
returns boolean
language sql
stable
as $$
  select auth.uid() is not null and exists (
    select 1
    from public.junior_driver_grants g
    where g.run_id = p_run_id
      and g.driver_id = auth.uid()
      and g.is_active = true
      and now() >= g.starts_at
      and now() <= g.ends_at
  );
$$;

create or replace function public.has_active_grant_for_kid(p_kid_id uuid)
returns boolean
language sql
stable
as $$
  select auth.uid() is not null and exists (
    select 1
    from public.junior_driver_grants g
    where g.kid_id = p_kid_id
      and g.driver_id = auth.uid()
      and g.is_active = true
      and now() >= g.starts_at
      and now() <= g.ends_at
  );
$$;

create or replace function public.is_run_parent(p_run_id uuid)
returns boolean
language sql
stable
as $$
  select auth.uid() is not null and exists (
    select 1 from public.junior_runs r
    where r.id = p_run_id and auth.uid() = r.parent_id
  );
$$;

create or replace function public.is_run_driver_with_grant(p_run_id uuid)
returns boolean
language sql
stable
as $$
  select auth.uid() is not null and exists (
    select 1
    from public.junior_runs r
    where r.id = p_run_id
      and auth.uid() = r.assigned_driver_id
      and public.has_active_grant_for_run(p_run_id)
  );
$$;

create or replace function public.is_run_party(p_run_id uuid)
returns boolean
language sql
stable
as $$
  select public.is_run_parent(p_run_id) or public.is_run_driver_with_grant(p_run_id);
$$;

-- RLS
alter table public.kids enable row level security;
alter table public.junior_runs enable row level security;
alter table public.junior_driver_grants enable row level security;
alter table public.junior_run_events enable row level security;
alter table public.sos_events enable row level security;
alter table public.junior_run_locations enable row level security;

drop policy if exists kids_select_safe on public.kids;
create policy kids_select_safe
on public.kids for select
using (auth.uid() = parent_id OR public.has_active_grant_for_kid(id));

drop policy if exists kids_insert_parent on public.kids;
create policy kids_insert_parent
on public.kids for insert
with check (auth.uid() = parent_id);

drop policy if exists kids_update_parent on public.kids;
create policy kids_update_parent
on public.kids for update
using (auth.uid() = parent_id)
with check (auth.uid() = parent_id);

drop policy if exists jr_select_safe on public.junior_runs;
create policy jr_select_safe
on public.junior_runs for select
using (auth.uid() = parent_id OR public.is_run_driver_with_grant(id));

drop policy if exists jr_insert_parent on public.junior_runs;
create policy jr_insert_parent
on public.junior_runs for insert
with check (auth.uid() = parent_id);

drop policy if exists jr_update_parent on public.junior_runs;
create policy jr_update_parent
on public.junior_runs for update
using (auth.uid() = parent_id)
with check (auth.uid() = parent_id);

drop policy if exists jr_update_driver_granted on public.junior_runs;
create policy jr_update_driver_granted
on public.junior_runs for update
using (public.is_run_driver_with_grant(id))
with check (public.is_run_driver_with_grant(id));

drop policy if exists jdg_parent_select on public.junior_driver_grants;
create policy jdg_parent_select
on public.junior_driver_grants for select
using (auth.uid() = parent_id);

drop policy if exists jdg_parent_insert on public.junior_driver_grants;
create policy jdg_parent_insert
on public.junior_driver_grants for insert
with check (auth.uid() = parent_id);

drop policy if exists jdg_parent_update on public.junior_driver_grants;
create policy jdg_parent_update
on public.junior_driver_grants for update
using (auth.uid() = parent_id)
with check (auth.uid() = parent_id);

drop policy if exists jdg_driver_select on public.junior_driver_grants;
create policy jdg_driver_select
on public.junior_driver_grants for select
using (auth.uid() = driver_id);

drop policy if exists jr_events_select_safe on public.junior_run_events;
create policy jr_events_select_safe
on public.junior_run_events for select
using (public.is_run_party(run_id));

drop policy if exists jr_events_insert_none on public.junior_run_events;
create policy jr_events_insert_none
on public.junior_run_events for insert
with check (false);

drop policy if exists sos_select_safe on public.sos_events;
create policy sos_select_safe
on public.sos_events for select
using (auth.uid() = triggered_by OR auth.uid() = parent_id OR auth.uid() = driver_id);

drop policy if exists sos_insert_none on public.sos_events;
create policy sos_insert_none
on public.sos_events for insert
with check (false);

drop policy if exists jrl_select_safe on public.junior_run_locations;
create policy jrl_select_safe
on public.junior_run_locations for select
using (public.is_run_party(run_id));

drop policy if exists jrl_insert_none on public.junior_run_locations;
create policy jrl_insert_none
on public.junior_run_locations for insert
with check (false);

-- RPCs
create or replace function public.create_run_grant_and_assign_driver(
  p_run_id uuid,
  p_driver_id uuid,
  p_starts_at timestamptz,
  p_ends_at timestamptz
)
returns public.junior_driver_grants
language plpgsql
security definer
as $$
declare
  v_run public.junior_runs;
  v_grant public.junior_driver_grants;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;

  select * into v_run
  from public.junior_runs
  where id = p_run_id
  for update;

  if not found then raise exception 'Run not found'; end if;
  if v_run.parent_id <> auth.uid() then raise exception 'Not authorized'; end if;

  if not exists (
    select 1 from public.trusted_drivers td
    where td.parent_id = auth.uid()
      and td.driver_id = p_driver_id
      and td.is_active = true
  ) then
    raise exception 'Driver is not trusted';
  end if;

  update public.junior_runs
  set assigned_driver_id = p_driver_id,
      status = case when status='planned' then 'driver_assigned' else status end,
      updated_at = now()
  where id = p_run_id;

  insert into public.junior_driver_grants(parent_id, driver_id, kid_id, run_id, starts_at, ends_at, is_active)
  values (auth.uid(), p_driver_id, v_run.kid_id, p_run_id, p_starts_at, p_ends_at, true)
  returning * into v_grant;

  insert into public.junior_run_events(
    run_id, actor_id, actor_role, event_type, prev_status, new_status, meta
  ) values (
    p_run_id, auth.uid(), 'parent', 'driver_assigned', v_run.status, 'driver_assigned',
    jsonb_build_object('assigned_driver_id', p_driver_id, 'grant_id', v_grant.id, 'starts_at', p_starts_at, 'ends_at', p_ends_at)
  );

  return v_grant;
end;
$$;

grant execute on function public.create_run_grant_and_assign_driver(uuid, uuid, timestamptz, timestamptz) to authenticated;
alter function public.create_run_grant_and_assign_driver(uuid, uuid, timestamptz, timestamptz) set row_security = on;

create or replace function public.revoke_driver_grant(p_grant_id uuid)
returns void
language plpgsql
security definer
as $$
declare
  v public.junior_driver_grants;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;

  select * into v from public.junior_driver_grants where id = p_grant_id for update;
  if not found then raise exception 'Grant not found'; end if;
  if v.parent_id <> auth.uid() then raise exception 'Not authorized'; end if;

  update public.junior_driver_grants set is_active = false where id = p_grant_id;
end;
$$;

grant execute on function public.revoke_driver_grant(uuid) to authenticated;
alter function public.revoke_driver_grant(uuid) set row_security = on;

create or replace function public.update_junior_run_status(
  p_run_id uuid,
  p_new_status text,
  p_lat double precision default null,
  p_lng double precision default null,
  p_meta jsonb default null
)
returns public.junior_runs
language plpgsql
security definer
as $$
declare
  v_run public.junior_runs;
  v_prev text;
  v_actor_role text;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;

  select * into v_run from public.junior_runs where id = p_run_id for update;
  if not found then raise exception 'Run not found'; end if;

  v_prev := v_run.status;

  if auth.uid() = v_run.parent_id then
    v_actor_role := 'parent';
  elsif auth.uid() = v_run.assigned_driver_id and public.has_active_grant_for_run(p_run_id) then
    v_actor_role := 'driver';
  else
    raise exception 'Not authorized';
  end if;

  if p_new_status not in ('planned','driver_assigned','picked_up','arrived','completed','cancelled') then
    raise exception 'Invalid status';
  end if;

  if p_new_status = 'picked_up' and (v_actor_role <> 'driver' or v_prev <> 'driver_assigned') then
    raise exception 'Invalid transition';
  end if;

  if p_new_status = 'arrived' and (v_actor_role <> 'driver' or v_prev <> 'picked_up') then
    raise exception 'Invalid transition';
  end if;

  if p_new_status = 'completed' and v_prev <> 'arrived' then
    raise exception 'Invalid transition';
  end if;

  if p_new_status = 'cancelled' and (v_actor_role <> 'parent' or v_prev = 'completed') then
    raise exception 'Invalid transition';
  end if;

  update public.junior_runs
  set status = p_new_status, updated_at = now()
  where id = p_run_id
  returning * into v_run;

  insert into public.junior_run_events(
    run_id, actor_id, actor_role, event_type, prev_status, new_status, lat, lng, meta
  )
  values (p_run_id, auth.uid(), v_actor_role, p_new_status, v_prev, p_new_status, p_lat, p_lng, p_meta);

  return v_run;
end;
$$;

grant execute on function public.update_junior_run_status(uuid, text, double precision, double precision, jsonb) to authenticated;
alter function public.update_junior_run_status(uuid, text, double precision, double precision, jsonb) set row_security = on;

create or replace function public.create_sos(
  p_lat double precision,
  p_lng double precision,
  p_run_id uuid default null,
  p_trip_id uuid default null,
  p_kind text default 'sos',
  p_severity int default 3,
  p_message text default null,
  p_meta jsonb default null
)
returns public.sos_events
language plpgsql
security definer
as $$
declare
  v_sos public.sos_events;
  v_parent uuid;
  v_driver uuid;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;

  if p_run_id is not null then
    if not public.is_run_party(p_run_id) then raise exception 'Not authorized for run'; end if;
    select parent_id, assigned_driver_id into v_parent, v_driver from public.junior_runs where id = p_run_id;
  else
    select driver_id into v_driver from public.trips where id = p_trip_id;
    v_parent := null;
  end if;

  insert into public.sos_events(run_id, trip_id, triggered_by, parent_id, driver_id, kind, severity, lat, lng, message, meta)
  values (p_run_id, p_trip_id, auth.uid(), v_parent, v_driver, p_kind, p_severity, p_lat, p_lng, p_message, p_meta)
  returning * into v_sos;

  return v_sos;
end;
$$;

grant execute on function public.create_sos(double precision, double precision, uuid, uuid, text, int, text, jsonb) to authenticated;
alter function public.create_sos(double precision, double precision, uuid, uuid, text, int, text, jsonb) set row_security = on;

create or replace function public.driver_push_junior_location(
  p_run_id uuid,
  p_lat double precision,
  p_lng double precision,
  p_heading double precision default null,
  p_speed double precision default null,
  p_accuracy double precision default null
)
returns public.junior_run_locations
language plpgsql
security definer
as $$
declare
  v_run public.junior_runs;
  v_row public.junior_run_locations;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;

  select * into v_run from public.junior_runs where id = p_run_id for update;
  if not found then raise exception 'Run not found'; end if;

  if auth.uid() <> v_run.assigned_driver_id then raise exception 'Not assigned driver'; end if;
  if not public.has_active_grant_for_run(p_run_id) then raise exception 'No active grant'; end if;

  insert into public.junior_run_locations(run_id, user_id, lat, lng, heading, speed, accuracy)
  values (p_run_id, auth.uid(), p_lat, p_lng, p_heading, p_speed, p_accuracy)
  returning * into v_row;

  return v_row;
end;
$$;

grant execute on function public.driver_push_junior_location(uuid, double precision, double precision, double precision, double precision, double precision) to authenticated;
alter function public.driver_push_junior_location(uuid, double precision, double precision, double precision, double precision, double precision) set row_security = on;

commit;
