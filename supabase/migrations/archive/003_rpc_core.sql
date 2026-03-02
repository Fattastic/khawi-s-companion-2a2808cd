-- 003_rpc_core.sql
-- Core RPCs: send_join_request, cancel_join_request, driver_accept_request, driver_decline_request
-- Run AFTER 001 + 002

create or replace function public.send_join_request(p_trip_id uuid)
returns public.trip_requests
language plpgsql
security definer
as $$
declare
  v_req public.trip_requests;
  v_trip public.trips;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  select * into v_trip
  from public.trips
  where id = p_trip_id;

  if not found then
    raise exception 'Trip not accessible (privacy) or does not exist';
  end if;

  if v_trip.status <> 'planned' then
    raise exception 'Trip is not available';
  end if;

  if v_trip.seats_available <= 0 then
    raise exception 'No seats available';
  end if;

  insert into public.trip_requests (trip_id, passenger_id, status)
  values (p_trip_id, auth.uid(), 'pending')
  on conflict (trip_id, passenger_id)
  do update set
    status = case
      when public.trip_requests.status in ('cancelled','declined','expired') then 'pending'
      else public.trip_requests.status
    end,
    updated_at = now()
  returning * into v_req;

  return v_req;
end;
$$;

grant execute on function public.send_join_request(uuid) to authenticated;
alter function public.send_join_request(uuid) set row_security = on;

create or replace function public.cancel_join_request(p_request_id uuid)
returns void
language plpgsql
security definer
as $$
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;

  update public.trip_requests
  set status = 'cancelled',
      updated_at = now()
  where id = p_request_id
    and passenger_id = auth.uid();

  if not found then raise exception 'Request not found'; end if;
end;
$$;

grant execute on function public.cancel_join_request(uuid) to authenticated;
alter function public.cancel_join_request(uuid) set row_security = on;

create or replace function public.driver_accept_request(p_request_id uuid)
returns public.trip_requests
language plpgsql
security definer
as $$
declare
  v_req public.trip_requests;
  v_trip public.trips;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;

  select * into v_req
  from public.trip_requests
  where id = p_request_id
  for update;

  if not found then raise exception 'Request not found'; end if;
  if v_req.status <> 'pending' then raise exception 'Request is not pending'; end if;

  select * into v_trip
  from public.trips
  where id = v_req.trip_id
  for update;

  if not found then raise exception 'Trip not found'; end if;
  if v_trip.driver_id <> auth.uid() then raise exception 'Not authorized (not trip driver)'; end if;
  if v_trip.status <> 'planned' then raise exception 'Trip not available'; end if;
  if v_trip.seats_available <= 0 then raise exception 'No seats available'; end if;

  update public.trip_requests
  set status = 'accepted',
      updated_at = now()
  where id = p_request_id
  returning * into v_req;

  update public.trips
  set seats_available = seats_available - 1,
      updated_at = now()
  where id = v_trip.id;

  if (select seats_available from public.trips where id = v_trip.id) = 0 then
    update public.trip_requests
    set status = 'expired',
        updated_at = now()
    where trip_id = v_trip.id
      and status = 'pending';
  end if;

  return v_req;
end;
$$;

grant execute on function public.driver_accept_request(uuid) to authenticated;
alter function public.driver_accept_request(uuid) set row_security = on;

create or replace function public.driver_decline_request(p_request_id uuid)
returns public.trip_requests
language plpgsql
security definer
as $$
declare
  v_req public.trip_requests;
  v_trip public.trips;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;

  select * into v_req
  from public.trip_requests
  where id = p_request_id
  for update;

  if not found then raise exception 'Request not found'; end if;

  select * into v_trip
  from public.trips
  where id = v_req.trip_id
  for update;

  if not found then raise exception 'Trip not found'; end if;
  if v_trip.driver_id <> auth.uid() then raise exception 'Not authorized (not trip driver)'; end if;

  if v_req.status = 'accepted' then
    raise exception 'Cannot decline an accepted request';
  end if;

  update public.trip_requests
  set status = 'declined',
      updated_at = now()
  where id = p_request_id
  returning * into v_req;

  return v_req;
end;
$$;

grant execute on function public.driver_decline_request(uuid) to authenticated;
alter function public.driver_decline_request(uuid) set row_security = on;
