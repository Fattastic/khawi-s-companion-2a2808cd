begin;

-- =========================
-- Reports (ties into Moderation + Safety)
-- =========================
create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  trip_id uuid references public.trips(id) on delete set null,
  message_id uuid references public.trip_messages(id) on delete set null,
  reported_user_id uuid references public.profiles(id) on delete set null,

  category text not null check (category in ('harassment','spam','safety','fraud','other')),
  details text,
  status text not null default 'open' check (status in ('open','triaged','resolved','closed')),
  severity int not null default 1 check (severity between 1 and 3),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists trg_reports_updated_at on public.reports;
create trigger trg_reports_updated_at
before update on public.reports
for each row execute function public.set_updated_at();

create index if not exists reports_reporter_idx on public.reports(reporter_id, created_at desc);
create index if not exists reports_status_idx on public.reports(status, severity, created_at desc);
create index if not exists reports_trip_idx on public.reports(trip_id);
create index if not exists reports_message_idx on public.reports(message_id);

alter table public.reports enable row level security;

-- reporter can insert + read own reports
drop policy if exists "reports_insert_own" on public.reports;
create policy "reports_insert_own"
on public.reports for insert
with check (reporter_id = auth.uid());

drop policy if exists "reports_select_own" on public.reports;
create policy "reports_select_own"
on public.reports for select
using (reporter_id = auth.uid());

-- service role for ops triage
drop policy if exists "reports_service_all" on public.reports;
create policy "reports_service_all"
on public.reports for all
using (auth.role() = 'service_role')
with check (auth.role() = 'service_role');


-- =========================
-- Module F: commute templates + daily suggestions
-- =========================
create table if not exists public.commute_templates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,

  name text,
  weekday_mask int not null default 62, -- bitmask (Sun..Sat). Default Sun-Thu = 0b0111110 = 62 if you use Mon=1 etc; adjust per your convention
  depart_time_local text not null,      -- "07:30"
  return_time_local text,               -- optional
  origin jsonb not null,                -- {lat,lng, label} or {neighborhood_id}
  destination jsonb not null,
  prefs jsonb not null default '{}'::jsonb, -- quiet_ride, women_only_pref, kids_allowed, etc

  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists trg_commute_templates_updated_at on public.commute_templates;
create trigger trg_commute_templates_updated_at
before update on public.commute_templates
for each row execute function public.set_updated_at();

create index if not exists commute_templates_user_idx on public.commute_templates(user_id, active);

alter table public.commute_templates enable row level security;

drop policy if exists "commute_templates_select_own" on public.commute_templates;
create policy "commute_templates_select_own"
on public.commute_templates for select
using (user_id = auth.uid());

drop policy if exists "commute_templates_write_own" on public.commute_templates;
create policy "commute_templates_write_own"
on public.commute_templates for all
using (user_id = auth.uid())
with check (user_id = auth.uid());


create table if not exists public.daily_suggestions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  suggestion_type text not null check (suggestion_type in ('tomorrow_commute','recommended_khawis','pref_nudge')),
  payload jsonb not null, -- structured suggestion(s)
  score int not null default 50 check (score between 0 and 100),
  reason_tags text[] not null default '{}'::text[],
  computed_at timestamptz not null default now(),
  model_version text not null default 'heuristic_v1',
  expires_at timestamptz
);

create index if not exists daily_suggestions_user_idx on public.daily_suggestions(user_id, computed_at desc);
create index if not exists daily_suggestions_expires_idx on public.daily_suggestions(expires_at);

alter table public.daily_suggestions enable row level security;

drop policy if exists "daily_suggestions_select_own" on public.daily_suggestions;
create policy "daily_suggestions_select_own"
on public.daily_suggestions for select
using (user_id = auth.uid());

drop policy if exists "daily_suggestions_write_service_only" on public.daily_suggestions;
create policy "daily_suggestions_write_service_only"
on public.daily_suggestions for all
using (auth.role() = 'service_role')
with check (auth.role() = 'service_role');


-- =========================
-- Module G: bundling suggestions
-- =========================
create table if not exists public.bundle_suggestions (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  driver_id uuid not null references public.profiles(id) on delete cascade,

  passenger_ids uuid[] not null default '{}'::uuid[],
  suggested_order jsonb not null,             -- array of stops with {passenger_id, pickup_point, eta_delta_min}
  detour_by_passenger jsonb not null default '{}'::jsonb,
  acceptability_score int not null default 50 check (acceptability_score between 0 and 100),

  model_version text not null default 'heuristic_v1',
  computed_at timestamptz not null default now()
);

create index if not exists bundle_suggestions_trip_idx on public.bundle_suggestions(trip_id, computed_at desc);
create index if not exists bundle_suggestions_driver_idx on public.bundle_suggestions(driver_id, computed_at desc);

alter table public.bundle_suggestions enable row level security;

-- driver can read for their trip; participants can read for their trip (optional)
drop policy if exists "bundle_suggestions_select_driver" on public.bundle_suggestions;
create policy "bundle_suggestions_select_driver"
on public.bundle_suggestions for select
using (driver_id = auth.uid());

drop policy if exists "bundle_suggestions_write_service_only" on public.bundle_suggestions;
create policy "bundle_suggestions_write_service_only"
on public.bundle_suggestions for all
using (auth.role() = 'service_role')
with check (auth.role() = 'service_role');


commit;
