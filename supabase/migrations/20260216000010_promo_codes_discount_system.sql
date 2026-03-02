-- Batch 17: Promo codes & discount system (core)

create table if not exists public.promo_codes (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  title text not null,
  discount_type text not null check (discount_type in ('percent', 'fixed')),
  discount_value numeric(10,2) not null check (discount_value > 0),
  max_discount_sar numeric(10,2),
  min_fare_sar numeric(10,2) not null default 0,
  starts_at timestamptz,
  expires_at timestamptz,
  is_active boolean not null default true,
  usage_limit_total integer,
  usage_limit_per_user integer not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists promo_codes_is_active_idx
  on public.promo_codes(is_active);
create index if not exists promo_codes_expires_at_idx
  on public.promo_codes(expires_at);

alter table public.promo_codes enable row level security;

drop policy if exists promo_codes_select_authenticated on public.promo_codes;
create policy promo_codes_select_authenticated
  on public.promo_codes
  for select
  to authenticated
  using (is_active = true);

create table if not exists public.user_promo_codes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  promo_code_id uuid not null references public.promo_codes(id) on delete cascade,
  status text not null default 'active' check (status in ('active', 'applied', 'expired', 'cancelled')),
  discount_amount_sar numeric(10,2),
  trip_request_id uuid references public.trip_requests(id) on delete set null,
  claimed_at timestamptz not null default now(),
  used_at timestamptz,
  unique (user_id, promo_code_id)
);

create index if not exists user_promo_codes_user_status_idx
  on public.user_promo_codes(user_id, status);

alter table public.user_promo_codes enable row level security;

drop policy if exists user_promo_codes_select_own on public.user_promo_codes;
create policy user_promo_codes_select_own
  on public.user_promo_codes
  for select
  to authenticated
  using (user_id = auth.uid());

drop policy if exists user_promo_codes_insert_own on public.user_promo_codes;
create policy user_promo_codes_insert_own
  on public.user_promo_codes
  for insert
  to authenticated
  with check (user_id = auth.uid());

create or replace function public.get_my_active_promo_codes()
returns table (
  user_promo_id uuid,
  code text,
  title text,
  discount_type text,
  discount_value numeric,
  max_discount_sar numeric,
  min_fare_sar numeric,
  expires_at timestamptz,
  claimed_at timestamptz
)
language sql
security definer
set search_path = public
as $$
  select
    upc.id as user_promo_id,
    pc.code,
    pc.title,
    pc.discount_type,
    pc.discount_value,
    pc.max_discount_sar,
    pc.min_fare_sar,
    pc.expires_at,
    upc.claimed_at
  from public.user_promo_codes upc
  join public.promo_codes pc on pc.id = upc.promo_code_id
  where upc.user_id = auth.uid()
    and upc.status = 'active'
    and pc.is_active = true
    and (pc.starts_at is null or pc.starts_at <= now())
    and (pc.expires_at is null or pc.expires_at > now())
  order by upc.claimed_at desc;
$$;

grant execute on function public.get_my_active_promo_codes() to authenticated;

create or replace function public.claim_promo_code(p_code text)
returns table (
  user_promo_id uuid,
  code text,
  title text,
  discount_type text,
  discount_value numeric,
  max_discount_sar numeric,
  min_fare_sar numeric,
  expires_at timestamptz,
  claimed_at timestamptz
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_promo public.promo_codes%rowtype;
  v_user_claims integer;
  v_total_claims integer;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  select *
  into v_promo
  from public.promo_codes
  where upper(code) = upper(trim(p_code))
    and is_active = true
    and (starts_at is null or starts_at <= now())
    and (expires_at is null or expires_at > now())
  limit 1;

  if not found then
    raise exception 'Promo code is invalid or expired';
  end if;

  select count(*)::int
  into v_user_claims
  from public.user_promo_codes upc
  where upc.user_id = v_user_id
    and upc.promo_code_id = v_promo.id;

  if v_user_claims >= v_promo.usage_limit_per_user then
    raise exception 'Promo code usage limit reached for this account';
  end if;

  if v_promo.usage_limit_total is not null then
    select count(*)::int
    into v_total_claims
    from public.user_promo_codes upc
    where upc.promo_code_id = v_promo.id;

    if v_total_claims >= v_promo.usage_limit_total then
      raise exception 'Promo code usage limit reached';
    end if;
  end if;

  insert into public.user_promo_codes (user_id, promo_code_id)
  values (v_user_id, v_promo.id);

  return query
  select
    upc.id as user_promo_id,
    v_promo.code,
    v_promo.title,
    v_promo.discount_type,
    v_promo.discount_value,
    v_promo.max_discount_sar,
    v_promo.min_fare_sar,
    v_promo.expires_at,
    upc.claimed_at
  from public.user_promo_codes upc
  where upc.user_id = v_user_id
    and upc.promo_code_id = v_promo.id
  order by upc.claimed_at desc
  limit 1;
end;
$$;

grant execute on function public.claim_promo_code(text) to authenticated;

create or replace function public.preview_promo_discount(
  p_code text,
  p_fare_sar numeric
)
returns table (
  applied boolean,
  message text,
  discount_sar numeric,
  final_fare_sar numeric
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_promo public.promo_codes%rowtype;
  v_discount numeric := 0;
  v_final numeric := greatest(coalesce(p_fare_sar, 0), 0);
begin
  if p_fare_sar is null or p_fare_sar <= 0 then
    return query
    select false, 'Fare must be greater than zero', 0::numeric, v_final;
    return;
  end if;

  select *
  into v_promo
  from public.promo_codes
  where upper(code) = upper(trim(p_code))
    and is_active = true
    and (starts_at is null or starts_at <= now())
    and (expires_at is null or expires_at > now())
  limit 1;

  if not found then
    return query
    select false, 'Promo code is invalid or expired', 0::numeric, v_final;
    return;
  end if;

  if p_fare_sar < coalesce(v_promo.min_fare_sar, 0) then
    return query
    select false,
      format('Minimum fare for this promo is %s SAR', v_promo.min_fare_sar),
      0::numeric,
      p_fare_sar;
    return;
  end if;

  if v_promo.discount_type = 'percent' then
    v_discount := p_fare_sar * (v_promo.discount_value / 100.0);
  else
    v_discount := v_promo.discount_value;
  end if;

  if v_promo.max_discount_sar is not null then
    v_discount := least(v_discount, v_promo.max_discount_sar);
  end if;

  v_discount := least(v_discount, p_fare_sar);
  v_final := greatest(p_fare_sar - v_discount, 0);

  return query
  select true, 'Promo applied', round(v_discount, 2), round(v_final, 2);
end;
$$;

grant execute on function public.preview_promo_discount(text, numeric) to authenticated;

insert into public.promo_codes (
  code,
  title,
  discount_type,
  discount_value,
  max_discount_sar,
  min_fare_sar,
  expires_at,
  usage_limit_total,
  usage_limit_per_user,
  is_active
)
values
  ('KHAWI10', '10% off your next ride', 'percent', 10, 12, 15, now() + interval '90 days', 50000, 1, true),
  ('KHAWI20', '20 SAR off your next ride', 'fixed', 20, null, 40, now() + interval '45 days', 15000, 1, true)
on conflict (code) do update
set
  title = excluded.title,
  discount_type = excluded.discount_type,
  discount_value = excluded.discount_value,
  max_discount_sar = excluded.max_discount_sar,
  min_fare_sar = excluded.min_fare_sar,
  expires_at = excluded.expires_at,
  usage_limit_total = excluded.usage_limit_total,
  usage_limit_per_user = excluded.usage_limit_per_user,
  is_active = excluded.is_active,
  updated_at = now();
