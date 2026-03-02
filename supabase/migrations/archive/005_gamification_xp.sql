-- 005_gamification_xp.sql
-- XP ledger + rules + awarding RPC (peak hours + first 5 trips/day + streak milestones)
-- Run after core tables

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

create index if not exists xp_events_user_idx on public.xp_events(user_id, created_at);

create table if not exists public.user_gamification (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  streak_days integer not null default 0,
  last_active_date date,
  trips_completed_total integer not null default 0,
  trips_completed_today integer not null default 0,
  trips_completed_today_date date,
  updated_at timestamptz not null default now()
);

drop trigger if exists trg_user_gamification_updated_at on public.user_gamification;
create trigger trg_user_gamification_updated_at
before update on public.user_gamification
for each row execute function public.set_updated_at();

create table if not exists public.xp_rules (
  id uuid primary key default gen_random_uuid(),
  rule_key text unique not null,
  is_active boolean not null default true,
  config jsonb not null,
  updated_at timestamptz not null default now()
);

drop trigger if exists trg_xp_rules_updated_at on public.xp_rules;
create trigger trg_xp_rules_updated_at
before update on public.xp_rules
for each row execute function public.set_updated_at();

insert into public.xp_rules(rule_key, config)
values
('peak_hours', '{"timezone":"Asia/Riyadh","windows":[{"start":"07:00","end":"09:00","multiplier":3},{"start":"16:00","end":"18:00","multiplier":3}]}'::jsonb),
('first_5_trips_daily', '{"bonus_each":20,"cap":5}'::jsonb),
('streak_bonus', '{"milestones":[{"days":3,"bonus":50},{"days":7,"bonus":150},{"days":30,"bonus":1000}]}'::jsonb)
on conflict (rule_key) do nothing;

create or replace function public.award_trip_xp(
  p_trip_id uuid,
  p_user_id uuid,
  p_base_xp integer,
  p_trip_start timestamptz
)
returns public.xp_events
language plpgsql
security definer
as $$
declare
  v_mult numeric := 1;
  v_bonus int := 0;
  v_total int;
  v_now date := (now() at time zone 'Asia/Riyadh')::date;
  v_peak jsonb;
  v_first5 jsonb;
  v_streak jsonb;
  v_g public.user_gamification;
  result public.xp_events;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  if auth.uid() <> p_user_id then raise exception 'Cannot award XP for other user'; end if;

  if p_base_xp < 0 then raise exception 'Invalid base_xp'; end if;
  if p_base_xp > 5000 then raise exception 'base_xp too high'; end if;

  select config into v_peak from public.xp_rules where rule_key='peak_hours' and is_active=true;
  select config into v_first5 from public.xp_rules where rule_key='first_5_trips_daily' and is_active=true;
  select config into v_streak from public.xp_rules where rule_key='streak_bonus' and is_active=true;

  insert into public.user_gamification(user_id) values (p_user_id)
  on conflict (user_id) do nothing;

  select * into v_g
  from public.user_gamification
  where user_id = p_user_id
  for update;

  if v_peak is not null then
    declare
      v_t time := (p_trip_start at time zone 'Asia/Riyadh')::time;
      v_w jsonb;
      v_start time;
      v_end time;
      v_m numeric;
    begin
      for v_w in select * from jsonb_array_elements(v_peak->'windows')
      loop
        v_start := (v_w->>'start')::time;
        v_end := (v_w->>'end')::time;
        v_m := (v_w->>'multiplier')::numeric;
        if v_t >= v_start and v_t <= v_end then
          v_mult := greatest(v_mult, v_m);
        end if;
      end loop;
    end;
  end if;

  if v_first5 is not null then
    if v_g.trips_completed_today_date is distinct from v_now then
      v_g.trips_completed_today := 0;
      v_g.trips_completed_today_date := v_now;
    end if;

    if v_g.trips_completed_today < ((v_first5->>'cap')::int) then
      v_bonus := v_bonus + ((v_first5->>'bonus_each')::int);
    end if;
  end if;

  if v_g.last_active_date is null then
    v_g.streak_days := 1;
  elsif v_g.last_active_date = v_now then
  elsif v_g.last_active_date = (v_now - 1) then
    v_g.streak_days := v_g.streak_days + 1;
  else
    v_g.streak_days := 1;
  end if;

  v_g.last_active_date := v_now;

  if v_streak is not null and v_g.trips_completed_today = 0 then
    declare
      v_ms jsonb;
      v_days int;
      v_b int;
    begin
      for v_ms in select * from jsonb_array_elements(v_streak->'milestones')
      loop
        v_days := (v_ms->>'days')::int;
        v_b := (v_ms->>'bonus')::int;
        if v_g.streak_days = v_days then
          v_bonus := v_bonus + v_b;
        end if;
      end loop;
    end;
  end if;

  v_g.trips_completed_today := v_g.trips_completed_today + 1;
  v_g.trips_completed_total := v_g.trips_completed_total + 1;

  update public.user_gamification
  set streak_days = v_g.streak_days,
      last_active_date = v_g.last_active_date,
      trips_completed_total = v_g.trips_completed_total,
      trips_completed_today = v_g.trips_completed_today,
      trips_completed_today_date = v_g.trips_completed_today_date,
      updated_at = now()
  where user_id = p_user_id;

  v_total := (p_base_xp * v_mult)::int + v_bonus;

  insert into public.xp_events(user_id, trip_id, source, base_xp, multiplier, bonus_xp, total_xp, meta)
  values (
    p_user_id, p_trip_id, 'trip_completed',
    p_base_xp, v_mult, v_bonus, v_total,
    jsonb_build_object('peak_multiplier', v_mult, 'streak_days', v_g.streak_days)
  )
  returning * into result;

  update public.profiles
  set total_xp = total_xp + v_total,
      redeemable_xp = redeemable_xp + v_total
  where id = p_user_id;

  return result;
end;
$$;

grant execute on function public.award_trip_xp(uuid, uuid, integer, timestamptz) to authenticated;
alter function public.award_trip_xp(uuid, uuid, integer, timestamptz) set row_security = on;
