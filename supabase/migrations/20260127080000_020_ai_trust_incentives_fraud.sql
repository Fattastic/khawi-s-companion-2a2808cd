begin;

-- =========================
-- (Optional) event_log (safe if already exists)
-- =========================
create table if not exists public.event_log (
  id uuid not null default gen_random_uuid(),
  actor_id uuid null,
  event_type text not null,
  entity_type text not null,
  entity_id uuid null,
  payload jsonb null,
  created_at timestamptz not null default now(),
  constraint event_log_pkey primary key (id)
);

create index if not exists event_log_actor_idx on public.event_log (actor_id);
create index if not exists event_log_type_idx on public.event_log (event_type);


-- =========================
-- feature_flags (safe rollout)
-- =========================
create table if not exists public.feature_flags (
  name text primary key,
  enabled boolean not null default false,
  rollout_percentage integer not null default 0,
  segment_filter jsonb null,
  created_at timestamptz not null default now()
);

insert into public.feature_flags (name, enabled, rollout_percentage) values
  ('ai.trustscore', true, 100),
  ('ai.area_incentives', true, 100),
  ('ai.fraud', true, 100)
on conflict (name) do nothing;


-- =========================
-- Module D: trust_profiles
-- =========================
create table if not exists public.trust_profiles (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  trust_score integer not null check (trust_score between 0 and 100),
  trust_badge text not null check (trust_badge in ('bronze','silver','gold')),
  junior_trusted boolean not null default false,
  computed_at timestamptz not null default now(),
  model_version text not null default 'heuristic_v1'
);

create index if not exists trust_profiles_badge_idx on public.trust_profiles(trust_badge);
create index if not exists trust_profiles_score_idx on public.trust_profiles(trust_score desc);

alter table public.trust_profiles enable row level security;

drop policy if exists "trust_profiles_read_all" on public.trust_profiles;
create policy "trust_profiles_read_all"
on public.trust_profiles for select
using (true);

drop policy if exists "trust_profiles_write_service_only" on public.trust_profiles;
create policy "trust_profiles_write_service_only"
on public.trust_profiles for all
using (auth.role() = 'service_role')
with check (auth.role() = 'service_role');


-- =========================
-- Module C: area_incentives (neighborhood_id + time_bucket)
-- =========================
create table if not exists public.area_incentives (
  area_key text not null,               -- use trips.neighborhood_id
  time_bucket text not null,            -- e.g. "weekday_morning"
  dynamic_xp_multiplier numeric not null default 1.0,
  reason_tag text not null default 'balanced',
  computed_at timestamptz not null default now(),
  model_version text not null default 'heuristic_v1',
  constraint area_incentives_pkey primary key (area_key, time_bucket)
);

create index if not exists area_incentives_computed_idx on public.area_incentives(computed_at desc);

alter table public.area_incentives enable row level security;

drop policy if exists "area_incentives_read_all" on public.area_incentives;
create policy "area_incentives_read_all"
on public.area_incentives for select
using (true);

drop policy if exists "area_incentives_write_service_only" on public.area_incentives;
create policy "area_incentives_write_service_only"
on public.area_incentives for all
using (auth.role() = 'service_role')
with check (auth.role() = 'service_role');


-- =========================
-- Module H: fraud_flags
-- =========================
create table if not exists public.fraud_flags (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null check (entity_type in ('profile','trip','trip_request')),
  entity_id uuid not null,
  flag_type text not null,              -- e.g. "pair_collusion", "looping", "xp_spike"
  severity integer not null default 1 check (severity between 1 and 3),
  evidence_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  resolved_at timestamptz null
);

create index if not exists fraud_flags_entity_idx on public.fraud_flags(entity_type, entity_id, created_at desc);
create index if not exists fraud_flags_sev_idx on public.fraud_flags(severity desc, created_at desc);

alter table public.fraud_flags enable row level security;

-- users can read flags about themselves only if you want; safest is service-only.
drop policy if exists "fraud_flags_service_all" on public.fraud_flags;
create policy "fraud_flags_service_all"
on public.fraud_flags for all
using (auth.role() = 'service_role')
with check (auth.role() = 'service_role');


-- =========================
-- (Optional) throttle switch on profiles (safe if already exists)
-- =========================
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='profiles' and column_name='xp_throttle'
  ) then
    alter table public.profiles add column xp_throttle boolean not null default false;
  end if;
end$$;

commit;
