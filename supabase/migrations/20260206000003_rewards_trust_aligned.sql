-- ============================================================================
-- XP → Rewards Economy + Trust Tiers + Badges (Aligned Schema)
-- Migration: 20260206000003_rewards_trust_aligned.sql
-- Additive-only, RLS-safe, compatible with existing XP ledger
-- ============================================================================

-- ============================================================================
-- 1) ENUMS
-- ============================================================================
do $$ begin
  create type reward_category as enum ('symbolic', 'functional', 'partner');
exception when duplicate_object then null; end $$;

do $$ begin
  create type reward_delivery_type as enum ('in_app', 'coupon_code', 'external_link', 'manual_fulfillment');
exception when duplicate_object then null; end $$;

do $$ begin
  create type redemption_status as enum ('requested', 'approved', 'delivered', 'rejected', 'canceled');
exception when duplicate_object then null; end $$;

do $$ begin
  create type trust_tier as enum ('bronze', 'silver', 'gold', 'platinum');
exception when duplicate_object then null; end $$;

do $$ begin
  create type badge_visibility as enum ('public', 'private', 'kids_only');
exception when duplicate_object then null; end $$;

-- ============================================================================
-- 2) REWARDS CATALOG
-- ============================================================================
create table if not exists rewards_catalog (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,                 -- stable identifier (e.g. "fuel_5sar", "profile_frame_gold")
  title_key text not null,                   -- localization key
  description_key text not null,             -- localization key
  category reward_category not null,
  delivery_type reward_delivery_type not null,
  xp_cost int not null check (xp_cost >= 0),
  is_active boolean not null default true,

  requires_khawi_plus boolean not null default false,
  min_trust_tier trust_tier not null default 'bronze',
  max_redemptions_per_user int null,         -- optional cap
  max_redemptions_total int null,            -- optional global cap
  redemption_window_start timestamptz null,
  redemption_window_end timestamptz null,

  meta jsonb not null default '{}'::jsonb,   -- partner info, coupon format, UI hints
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists rewards_catalog_active_idx on rewards_catalog (is_active);
create index if not exists rewards_catalog_category_idx on rewards_catalog (category);

-- ============================================================================
-- 3) REWARD REDEMPTIONS
-- ============================================================================
create table if not exists reward_redemptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  reward_id uuid not null references rewards_catalog(id) on delete restrict,
  xp_cost_snapshot int not null check (xp_cost_snapshot >= 0),
  status redemption_status not null default 'requested',

  fulfillment_payload jsonb not null default '{}'::jsonb,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists reward_redemptions_user_idx on reward_redemptions (user_id, created_at desc);
create index if not exists reward_redemptions_status_idx on reward_redemptions (status);

-- ============================================================================
-- 4) BADGES CATALOG
-- ============================================================================
create table if not exists badges_catalog (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,                 -- e.g. "safe_driver", "peak_hour_hero"
  title_key text not null,                   -- localization key
  description_key text not null,             -- localization key
  visibility badge_visibility not null default 'public',
  is_active boolean not null default true,

  criteria jsonb not null default '{}'::jsonb,  -- thresholds, windows, signals
  icon_asset text null,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists badges_catalog_active_idx on badges_catalog (is_active);
create index if not exists badges_catalog_visibility_idx on badges_catalog (visibility);

-- ============================================================================
-- 5) USER BADGES
-- ============================================================================
create table if not exists user_badges_v2 (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  badge_id uuid not null references badges_catalog(id) on delete restrict,

  status text not null default 'earned' check (status in ('earned', 'revoked')),
  earned_at timestamptz not null default now(),
  revoked_at timestamptz null,

  evidence jsonb not null default '{}'::jsonb,

  unique (user_id, badge_id)
);

create index if not exists user_badges_v2_user_idx on user_badges_v2 (user_id, earned_at desc);

-- ============================================================================
-- 6) USER TRUST STATE
-- ============================================================================
create table if not exists user_trust_state (
  user_id uuid primary key,
  tier trust_tier not null default 'bronze',
  score numeric not null default 0,          -- 0..100
  confidence numeric not null default 0.5,   -- 0..1

  explain jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create index if not exists user_trust_state_tier_idx on user_trust_state (tier);

-- ============================================================================
-- 7) TRUST EVENTS (Audit Trail)
-- ============================================================================
create table if not exists trust_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  actor text not null default 'system',      -- system / admin / edge_fn
  event_type text not null,                  -- tier_up, tier_down, safety_pause
  from_tier trust_tier null,
  to_tier trust_tier null,

  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists trust_events_user_idx on trust_events (user_id, created_at desc);

-- ============================================================================
-- 8) RLS POLICIES
-- ============================================================================
alter table rewards_catalog enable row level security;
alter table reward_redemptions enable row level security;
alter table badges_catalog enable row level security;
alter table user_badges_v2 enable row level security;
alter table user_trust_state enable row level security;
alter table trust_events enable row level security;

-- rewards_catalog: readable by all authenticated
drop policy if exists "rewards readable" on rewards_catalog;
create policy "rewards readable"
on rewards_catalog for select
to authenticated
using (true);

-- reward_redemptions: users read/write own
drop policy if exists "redemptions read own" on reward_redemptions;
create policy "redemptions read own"
on reward_redemptions for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "redemptions insert own" on reward_redemptions;
create policy "redemptions insert own"
on reward_redemptions for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "redemptions update own limited" on reward_redemptions;
create policy "redemptions update own limited"
on reward_redemptions for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid() and status in ('requested','canceled'));

-- badges_catalog: readable by all
drop policy if exists "badges readable" on badges_catalog;
create policy "badges readable"
on badges_catalog for select
to authenticated
using (true);

-- user_badges_v2: users read own
drop policy if exists "user badges read own" on user_badges_v2;
create policy "user badges read own"
on user_badges_v2 for select
to authenticated
using (user_id = auth.uid());

-- user_trust_state: users read own
drop policy if exists "trust state read own" on user_trust_state;
create policy "trust state read own"
on user_trust_state for select
to authenticated
using (user_id = auth.uid());

-- trust_events: users read own
drop policy if exists "trust events read own" on trust_events;
create policy "trust events read own"
on trust_events for select
to authenticated
using (user_id = auth.uid());

-- ============================================================================
-- 9) UPDATED_AT TRIGGERS
-- ============================================================================
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger rewards_catalog_updated_at
  before update on rewards_catalog
  for each row execute function update_updated_at_column();

create trigger reward_redemptions_updated_at
  before update on reward_redemptions
  for each row execute function update_updated_at_column();

create trigger badges_catalog_updated_at
  before update on badges_catalog
  for each row execute function update_updated_at_column();

create trigger user_trust_state_updated_at
  before update on user_trust_state
  for each row execute function update_updated_at_column();

-- ============================================================================
-- 10) SEED DATA - Rewards Catalog
-- ============================================================================
insert into rewards_catalog (code, title_key, description_key, category, delivery_type, xp_cost, requires_khawi_plus, min_trust_tier, max_redemptions_per_user)
values
  -- Symbolic rewards (free tier)
  ('profile_frame_bronze', 'reward.profile_frame_bronze.title', 'reward.profile_frame_bronze.desc', 'symbolic', 'in_app', 100, false, 'bronze', null),
  ('profile_frame_silver', 'reward.profile_frame_silver.title', 'reward.profile_frame_silver.desc', 'symbolic', 'in_app', 250, false, 'silver', null),
  ('profile_frame_gold', 'reward.profile_frame_gold.title', 'reward.profile_frame_gold.desc', 'symbolic', 'in_app', 500, false, 'gold', null),
  ('custom_nickname', 'reward.custom_nickname.title', 'reward.custom_nickname.desc', 'symbolic', 'in_app', 150, false, 'bronze', 1),

  -- Functional rewards
  ('priority_match_1h', 'reward.priority_match.title', 'reward.priority_match.desc', 'functional', 'in_app', 200, false, 'silver', 3),
  ('xp_boost_24h', 'reward.xp_boost.title', 'reward.xp_boost.desc', 'functional', 'in_app', 300, false, 'bronze', 2),

  -- Partner rewards (Khawi+ only)
  ('fuel_5sar', 'reward.fuel_5sar.title', 'reward.fuel_5sar.desc', 'partner', 'coupon_code', 500, true, 'silver', 4),
  ('coffee_voucher', 'reward.coffee.title', 'reward.coffee.desc', 'partner', 'coupon_code', 400, true, 'bronze', 4),
  ('carwash_voucher', 'reward.carwash.title', 'reward.carwash.desc', 'partner', 'coupon_code', 600, true, 'gold', 2)
on conflict (code) do nothing;

-- ============================================================================
-- 11) SEED DATA - Badges Catalog
-- ============================================================================
insert into badges_catalog (code, title_key, description_key, visibility, criteria)
values
  -- Behavior badges
  ('safe_driver', 'badge.safe_driver.title', 'badge.safe_driver.desc', 'public', '{"min_behavior_score": 85, "min_trips": 10}'),
  ('calm_rider', 'badge.calm_rider.title', 'badge.calm_rider.desc', 'public', '{"min_rating": 4.8, "min_trips": 5}'),
  ('5_star_rated', 'badge.5_star.title', 'badge.5_star.desc', 'public', '{"min_rating": 5.0, "min_rated_trips": 10}'),

  -- Contribution badges
  ('first_trip', 'badge.first_trip.title', 'badge.first_trip.desc', 'public', '{"min_trips": 1}'),
  ('10_trips', 'badge.10_trips.title', 'badge.10_trips.desc', 'public', '{"min_trips": 10}'),
  ('50_trips', 'badge.50_trips.title', 'badge.50_trips.desc', 'public', '{"min_trips": 50}'),
  ('peak_hour_hero', 'badge.peak_hour_hero.title', 'badge.peak_hour_hero.desc', 'public', '{"min_peak_trips": 10}'),
  ('early_bird', 'badge.early_bird.title', 'badge.early_bird.desc', 'public', '{"min_early_trips": 5}'),

  -- Family/Trust badges
  ('kids_approved', 'badge.kids_approved.title', 'badge.kids_approved.desc', 'public', '{"min_kids_trips": 5, "min_rating": 4.5}'),
  ('parent_verified', 'badge.parent_verified.title', 'badge.parent_verified.desc', 'kids_only', '{"nafath_verified": true}'),
  ('family_driver', 'badge.family_driver.title', 'badge.family_driver.desc', 'public', '{"min_kids_trips": 20, "min_trust_tier": "gold"}')
on conflict (code) do nothing;
