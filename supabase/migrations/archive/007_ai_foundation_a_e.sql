-- 007_ai_foundation_a_e_refined.sql
-- Refined to handle existing stubs in current schema

begin;

-- ================
-- 0) Cleanup existing stubs if they differ significantly
-- ================
drop table if exists public.match_scores cascade;
drop table if exists public.moderation_events cascade;
-- Remove old columns if they exist to recreate with correct constraints
alter table public.trip_messages drop column if exists moderation_status cascade;
alter table public.trip_messages drop column if exists flagged_reason cascade;
alter table public.trip_messages drop column if exists moderation_reason_code cascade;
alter table public.trip_messages drop column if exists moderation_model_version cascade;

-- ================
-- 1) Immutable event log
-- ================
create table public.event_log (
  id bigserial primary key,
  actor_id uuid references public.profiles(id) on delete set null,
  event_type text not null,
  entity_type text,
  entity_id uuid,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index event_log_type_time_idx on public.event_log(event_type, created_at desc);
create index event_log_actor_time_idx on public.event_log(actor_id, created_at desc);
create index event_log_entity_idx on public.event_log(entity_type, entity_id);

alter table public.event_log enable row level security;

create policy "event_log_insert_self"
on public.event_log for insert
with check (actor_id = auth.uid());

create policy "event_log_select_none"
on public.event_log for select
using (false);

-- ================
-- 2) Module A: match_scores
-- ================
create table public.match_scores (
  user_id uuid not null references public.profiles(id) on delete cascade,
  trip_id uuid not null references public.trips(id) on delete cascade,

  match_score integer not null check (match_score between 0 and 100),
  accept_prob double precision not null check (accept_prob >= 0 and accept_prob <= 1),

  detour_minutes integer not null default 0,
  overlap_ratio double precision not null default 0 check (overlap_ratio >= 0 and overlap_ratio <= 1),

  explanation_tags text[] not null default '{}'::text[],

  model_version text not null default 'heuristic_v1',
  computed_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  primary key (user_id, trip_id)
);

create index match_scores_trip_idx on public.match_scores(trip_id);
create index match_scores_user_score_idx on public.match_scores(user_id, match_score desc, computed_at desc);

create trigger trg_match_scores_updated_at
before update on public.match_scores
for each row execute function public.set_updated_at();

alter table public.match_scores enable row level security;

create policy "match_scores_select_own"
on public.match_scores for select
using (user_id = auth.uid());

create policy "match_scores_insert_service_or_self"
on public.match_scores for insert
with check (
  user_id = auth.uid()
  or auth.role() = 'service_role'
);

create policy "match_scores_update_service_or_self"
on public.match_scores for update
using (
  user_id = auth.uid()
  or auth.role() = 'service_role'
);

-- ================
-- 3) Module E: moderation_events + message fields
-- ================
alter table public.trip_messages
  add column moderation_status text not null default 'pending'
    check (moderation_status in ('pending','allowed','warned','blocked','escalated')),
  add column moderation_reason_code text,
  add column moderation_model_version text default 'rules_v1';

create index trip_messages_trip_time_idx on public.trip_messages(trip_id, created_at desc);
create index trip_messages_moderation_idx on public.trip_messages(moderation_status, created_at desc);

create table public.moderation_events (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references public.trip_messages(id) on delete cascade,
  trip_id uuid not null references public.trips(id) on delete cascade,
  actor_id uuid references public.profiles(id) on delete set null,

  status text not null check (status in ('allowed','warned','blocked','escalated')),
  reason_code text not null,
  severity integer not null check (severity between 0 and 3),

  model_version text not null,
  meta jsonb not null default '{}'::jsonb,

  created_at timestamptz not null default now()
);

create index moderation_events_trip_time_idx on public.moderation_events(trip_id, created_at desc);
create index moderation_events_message_idx on public.moderation_events(message_id);

alter table public.moderation_events enable row level security;

create policy "moderation_events_select_participants"
on public.moderation_events for select
using (public.is_trip_participant(trip_id));

create policy "moderation_events_insert_service_only"
on public.moderation_events for insert
with check (auth.role() = 'service_role');

-- ================
-- 4) Simple rate limiting storage (edge functions)
-- ================
create table public.edge_rate_limits (
  key text primary key,
  window_start timestamptz not null,
  count integer not null default 0,
  updated_at timestamptz not null default now()
);

create index edge_rate_limits_window_idx on public.edge_rate_limits(window_start desc);

commit;
