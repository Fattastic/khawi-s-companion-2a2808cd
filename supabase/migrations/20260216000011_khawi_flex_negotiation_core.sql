-- Batch 21: Khawi Flex non-payment negotiation core

alter table public.trip_requests
  add column if not exists flex_offer_sar numeric(10,2),
  add column if not exists flex_note text;

alter table public.trip_requests
  drop constraint if exists trip_requests_flex_offer_positive_check;

alter table public.trip_requests
  add constraint trip_requests_flex_offer_positive_check
  check (flex_offer_sar is null or (flex_offer_sar > 0 and flex_offer_sar <= 1000));

create or replace function public.send_join_request(
  p_trip_id uuid,
  p_pickup_lat float8 default null,
  p_pickup_lng float8 default null,
  p_pickup_label text default null,
  p_flex_offer_sar numeric default null,
  p_flex_note text default null
)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_passenger_id uuid;
  v_trip_info record;
  v_new_req record;
  v_offer numeric;
  v_note text;
begin
  v_passenger_id := auth.uid();

  select * into v_trip_info from public.trips where id = p_trip_id;
  if not found then
    raise exception 'Trip not found';
  end if;

  if v_trip_info.seats_available <= 0 then
    raise exception 'No seats available';
  end if;

  if exists (
    select 1 from public.trip_requests
    where trip_id = p_trip_id
      and passenger_id = v_passenger_id
      and status in ('pending','accepted')
  ) then
    raise exception 'Request already sent';
  end if;

  if p_flex_offer_sar is not null and p_flex_offer_sar <= 0 then
    raise exception 'Flex offer must be positive';
  end if;

  v_offer := case when p_flex_offer_sar is null then null else round(p_flex_offer_sar, 2) end;
  v_note := nullif(trim(coalesce(p_flex_note, '')), '');

  insert into public.trip_requests (
    trip_id,
    passenger_id,
    pickup_lat,
    pickup_lng,
    pickup_label,
    flex_offer_sar,
    flex_note,
    status
  )
  values (
    p_trip_id,
    v_passenger_id,
    p_pickup_lat,
    p_pickup_lng,
    p_pickup_label,
    v_offer,
    v_note,
    'pending'
  )
  returning * into v_new_req;

  return to_jsonb(v_new_req);
end;
$$;

grant execute on function public.send_join_request(uuid, float8, float8, text, numeric, text) to authenticated;
