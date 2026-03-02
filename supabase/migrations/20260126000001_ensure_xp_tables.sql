-- 20260131230000_ensure_xp_tables.sql
-- Ensure Gamification tables exist (originally in archive/005_gamification_xp.sql)
-- This guarantees reproducibility of the database schema for the Launch.

BEGIN;

-- 1. XP EVENTS (The Ledger)
CREATE TABLE IF NOT EXISTS public.xp_events (
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

CREATE INDEX IF NOT EXISTS xp_events_user_idx ON public.xp_events(user_id, created_at);

-- 2. USER GAMIFICATION (Streaks & Daily Stats)
CREATE TABLE IF NOT EXISTS public.user_gamification (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  streak_days integer not null default 0,
  last_active_date date,
  trips_completed_total integer not null default 0,
  trips_completed_today integer not null default 0,
  trips_completed_today_date date,
  updated_at timestamptz not null default now()
);

DROP TRIGGER IF EXISTS trg_user_gamification_updated_at ON public.user_gamification;
CREATE TRIGGER trg_user_gamification_updated_at
BEFORE UPDATE ON public.user_gamification
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 3. XP RULES (Calculated logic config)
CREATE TABLE IF NOT EXISTS public.xp_rules (
  id uuid primary key default gen_random_uuid(),
  rule_key text unique not null,
  is_active boolean not null default true,
  config jsonb not null,
  updated_at timestamptz not null default now()
);

DROP TRIGGER IF EXISTS trg_xp_rules_updated_at ON public.xp_rules;
CREATE TRIGGER trg_xp_rules_updated_at
BEFORE UPDATE ON public.xp_rules
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Default Rules (Insert if not exists)
INSERT INTO public.xp_rules(rule_key, config)
VALUES
('peak_hours', '{"timezone":"Asia/Riyadh","windows":[{"start":"07:00","end":"09:00","multiplier":3},{"start":"16:00","end":"18:00","multiplier":3}]}'::jsonb),
('first_5_trips_daily', '{"bonus_each":20,"cap":5}'::jsonb),
('streak_bonus', '{"milestones":[{"days":3,"bonus":50},{"days":7,"bonus":150},{"days":30,"bonus":1000}]}'::jsonb)
ON CONFLICT (rule_key) DO NOTHING;

-- 4. Enable RLS (Best Practice)
ALTER TABLE public.xp_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_gamification ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.xp_rules ENABLE ROW LEVEL SECURITY;

-- Policies (Service Role can do anything, Users read own)
DROP POLICY IF EXISTS "xp_events_read_own" ON public.xp_events;
CREATE POLICY "xp_events_read_own" ON public.xp_events FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "user_gamification_read_own" ON public.user_gamification;
CREATE POLICY "user_gamification_read_own" ON public.user_gamification FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "xp_rules_read_all" ON public.xp_rules;
CREATE POLICY "xp_rules_read_all" ON public.xp_rules FOR SELECT USING (true); -- Public rules? Or authenticated? authenticated is safer.
-- Actually, let's restrict rules to authenticated
DROP POLICY IF EXISTS "xp_rules_read_auth" ON public.xp_rules;
CREATE POLICY "xp_rules_read_auth" ON public.xp_rules FOR SELECT TO authenticated USING (true);


COMMIT;
