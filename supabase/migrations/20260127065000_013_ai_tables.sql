-- 20260127065000_013_ai_tables.sql
-- Adds match_scores, event_log, and feature_flags tables

begin;

-- ==========================================
-- 1. match_scores (Module A)
-- ==========================================
create table if not exists public.match_scores (
  user_id uuid not null,
  trip_id uuid not null,

  match_score integer not null check (match_score between 0 and 100),
  detour_minutes integer not null check (detour_minutes >= 0),
  overlap_ratio numeric not null check (overlap_ratio between 0 and 1),
  accept_prob numeric not null check (accept_prob between 0 and 1),

  explanation_tags text[] not null default '{}'::text[],

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint match_scores_pkey primary key (user_id, trip_id),
  constraint match_scores_user_fkey foreign key (user_id) references profiles(id) on delete cascade,
  constraint match_scores_trip_fkey foreign key (trip_id) references trips(id) on delete cascade
);

create index if not exists match_scores_trip_idx
  on public.match_scores (trip_id);

create index if not exists match_scores_score_idx
  on public.match_scores (match_score desc);

create or replace trigger trg_match_scores_updated_at
before update on public.match_scores
for each row execute function set_updated_at();

-- RLS
alter table public.match_scores enable row level security;

-- Policies
drop policy if exists "read own match scores" on public.match_scores;
create policy "read own match scores"
on public.match_scores
for select
using (auth.uid() = user_id);

drop policy if exists "edge functions write match scores" on public.match_scores;
create policy "edge functions write match scores"
on public.match_scores
for insert with check (true);

drop policy if exists "edge functions update match scores" on public.match_scores;
create policy "edge functions update match scores"
on public.match_scores
for update using (true);


-- ==========================================
-- 2. event_log (Optional/Audit)
-- ==========================================
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

create index if not exists event_log_actor_idx
  on public.event_log (actor_id);

create index if not exists event_log_type_idx
  on public.event_log (event_type);


-- ==========================================
-- 3. feature_flags
-- ==========================================
create table if not exists public.feature_flags (
  name text primary key,
  enabled boolean not null default false,
  rollout_percentage integer not null default 0,
  created_at timestamptz not null default now()
);

-- Initial flags
insert into public.feature_flags (name, enabled, rollout_percentage)
values
  ('ai.match_ranking', true, 100),
  ('ai.bundling', true, 100)
on conflict (name) do nothing;

commit;
