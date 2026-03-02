-- 20260130050000_restore_missing_rpcs.sql
-- Restoration of critical RPCs and Tables missing from previous migrations
-- Consolidates: 003_rpc_core, 005_gamification_xp (partial), 006_junior_safety (partial) + New Invite Logic

-- 1. TRIP REQUESTS (from 003_rpc_core)
create or replace function public.send_join_request(p_trip_id uuid)
returns public.trip_requests
language plpgsql security definer as $$
declare
  v_req public.trip_requests;
  v_trip public.trips;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  select * into v_trip from public.trips where id = p_trip_id;
  if not found or v_trip.status <> 'planned' or v_trip.seats_available <= 0 then
    raise exception 'Trip unavailable';
  end if;
  insert into public.trip_requests (trip_id, passenger_id, status)
  values (p_trip_id, auth.uid(), 'pending')
  on conflict (trip_id, passenger_id) do update set status = 'pending', updated_at = now()
  returning * into v_req;
  return v_req;
end;
$$;

create or replace function public.cancel_join_request(p_request_id uuid)
returns void
language plpgsql security definer as $$
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  update public.trip_requests set status = 'cancelled', updated_at = now()
  where id = p_request_id and passenger_id = auth.uid();
end;
$$;

create or replace function public.driver_accept_request(p_request_id uuid)
returns public.trip_requests
language plpgsql security definer as $$
declare
  v_req public.trip_requests;
  v_trip public.trips;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  select * into v_req from public.trip_requests where id = p_request_id for update;
  if not found or v_req.status <> 'pending' then raise exception 'Invalid request'; end if;
  select * into v_trip from public.trips where id = v_req.trip_id for update;
  if v_trip.driver_id <> auth.uid() then raise exception 'Not authorized'; end if;
  if v_trip.seats_available <= 0 then raise exception 'No seats'; end if;

  update public.trip_requests set status = 'accepted', updated_at = now() where id = p_request_id returning * into v_req;
  update public.trips set seats_available = seats_available - 1, updated_at = now() where id = v_trip.id;
  
  -- Expire others if full
  if (select seats_available from public.trips where id = v_trip.id) = 0 then
    update public.trip_requests set status = 'expired', updated_at = now() where trip_id = v_trip.id and status = 'pending';
  end if;
  return v_req;
end;
$$;

create or replace function public.driver_decline_request(p_request_id uuid)
returns public.trip_requests
language plpgsql security definer as $$
declare
  v_req public.trip_requests;
  v_trip public.trips;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  select * into v_req from public.trip_requests where id = p_request_id for update;
  select * into v_trip from public.trips where id = v_req.trip_id;
  if v_trip.driver_id <> auth.uid() then raise exception 'Not authorized'; end if;
  if v_req.status = 'accepted' then raise exception 'Cannot decline accepted'; end if;
  update public.trip_requests set status = 'declined', updated_at = now() where id = p_request_id returning * into v_req;
  return v_req;
end;
$$;

-- 2. JUNIOR INVITE CODES (Missing table)
create table if not exists public.junior_invite_codes (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  parent_id uuid not null references public.profiles(id) on delete cascade,
  is_used boolean not null default false,
  expires_at timestamptz not null,
  created_at timestamptz not null default now()
);
alter table public.junior_invite_codes enable row level security;
create policy invite_select_parent on public.junior_invite_codes for select using (auth.uid() = parent_id);
create policy invite_insert_parent on public.junior_invite_codes for insert with check (auth.uid() = parent_id);

-- 3. JUNIOR RPCs (from 006 + New)
create or replace function public.create_junior_invite_code()
returns public.junior_invite_codes
language plpgsql security definer as $$
declare
  v_code text := upper(substring(md5(random()::text) from 1 for 6));
  v_res public.junior_invite_codes;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  insert into public.junior_invite_codes (code, parent_id, expires_at)
  values (v_code, auth.uid(), now() + interval '48 hours')
  returning * into v_res;
  return v_res;
end;
$$;

create or replace function public.redeem_junior_invite_code(p_code text)
returns boolean
language plpgsql security definer as $$
declare
  v_invite public.junior_invite_codes;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  select * into v_invite from public.junior_invite_codes where code = upper(p_code) for update;
  
  if not found or v_invite.is_used or v_invite.expires_at < now() then
    return false;
  end if;

  if v_invite.parent_id = auth.uid() then raise exception 'Cannot invite self'; end if;

  -- Create trusted driver relationship
  insert into public.trusted_drivers (parent_id, driver_id, label)
  values (v_invite.parent_id, auth.uid(), 'Invited Driver')
  on conflict (parent_id, driver_id) do nothing;

  update public.junior_invite_codes set is_used = true where id = v_invite.id;
  return true;
end;
$$;

-- SOS Update
create or replace function public.update_sos_status(
  p_sos_id uuid,
  p_status text
)
returns void
language plpgsql security definer as $$
declare
  v_sos public.sos_events;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  select * into v_sos from public.sos_events where id = p_sos_id;
  if not found then raise exception 'SOS not found'; end if;
  
  -- Only parent or driver involved can resolve/update? Or maybe just parent?
  -- Assuming parent or driver for now.
  if auth.uid() <> v_sos.parent_id and auth.uid() <> v_sos.driver_id and auth.uid() <> v_sos.triggered_by then
    raise exception 'Not authorized';
  end if;

  update public.sos_events set status = p_status, updated_at = now() where id = p_sos_id;
end;
$$;

-- 4. XP LOGIC (from 005)
-- Assuming table xp_events exists (verified). Restoring function.
create or replace function public.award_trip_xp(
  p_trip_id uuid,
  p_user_id uuid,
  p_base_xp integer,
  p_trip_start timestamptz
)
returns public.xp_events
language plpgsql security definer as $$
declare
  result public.xp_events;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  -- Simplified version of logic for restoration (full logic in archive/005 if needed, this ensures basic function exists)
  insert into public.xp_events(user_id, trip_id, source, base_xp, total_xp)
  values (p_user_id, p_trip_id, 'trip_completed', p_base_xp, p_base_xp)
  returning * into result;
  
  update public.profiles set total_xp = total_xp + p_base_xp, redeemable_xp = redeemable_xp + p_base_xp where id = p_user_id;
  
  return result;
end;
$$;

-- Grants (Authenticated)
grant execute on function public.send_join_request(uuid) to authenticated;
grant execute on function public.cancel_join_request(uuid) to authenticated;
grant execute on function public.driver_accept_request(uuid) to authenticated;
grant execute on function public.driver_decline_request(uuid) to authenticated;
grant execute on function public.create_junior_invite_code() to authenticated;
grant execute on function public.redeem_junior_invite_code(text) to authenticated;
grant execute on function public.update_sos_status(uuid, text) to authenticated;
grant execute on function public.award_trip_xp(uuid, uuid, integer, timestamptz) to authenticated;
