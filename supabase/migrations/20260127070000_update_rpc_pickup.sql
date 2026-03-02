-- 20260127070000_update_rpc_pickup.sql
-- Updates send_join_request RPC to accept pickup coordinates for Bundling (Module G)

begin;

create or replace function public.send_join_request(
  p_trip_id uuid,
  p_pickup_lat float8 default null,  -- Optional, new arguments
  p_pickup_lng float8 default null,
  p_pickup_label text default null
)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_passenger_id uuid;
  v_trip_info record;
  v_new_req record;
begin
  v_passenger_id := auth.uid();

  -- 1. Check trip exists & seats
  select * into v_trip_info from public.trips where id = p_trip_id;
  if not found then
    raise exception 'Trip not found';
  end if;
  
  if v_trip_info.seats_available <= 0 then
    raise exception 'No seats available';
  end if;

  -- 2. Check if already requested (active)
  if exists (
    select 1 from public.trip_requests
    where trip_id = p_trip_id
      and passenger_id = v_passenger_id
      and status in ('pending','accepted')
  ) then
    raise exception 'Request already sent';
  end if;

  -- 3. Insert Request (with pickup coords if provided)
  insert into public.trip_requests (
    trip_id,
    passenger_id,
    pickup_lat,
    pickup_lng,
    pickup_label,
    status
  )
  values (
    p_trip_id,
    v_passenger_id,
    p_pickup_lat,
    p_pickup_lng,
    p_pickup_label,
    'pending'
  )
  returning * into v_new_req;

  -- 4. Notify Driver (mock via realtime or push logic externally)
  -- The trigger `trg_fill_request_driver_id` usually handles driver_id fill.

  return to_jsonb(v_new_req);
end;
$$;

commit;
