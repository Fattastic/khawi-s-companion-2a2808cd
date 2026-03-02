-- 20260206000001_intelligent_profile_xp.sql
-- Implements Profile Enrichment and XP Multiplier tables

BEGIN;

-- 1. PROFILE EXTENSIONS
CREATE TABLE IF NOT EXISTS public.profile_extensions (
  user_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  roles text[] NOT NULL DEFAULT '{}'::text[],
  city text,
  neighborhood text,
  activity_windows jsonb NOT NULL DEFAULT '[]'::jsonb, -- e.g. [{"window": "morning", "days": [1,2,3,4,5]}]
  purposes text[] NOT NULL DEFAULT '{}'::text[],
  vehicle_info jsonb, -- e.g. {"owns_car": true, "type": "SUV", "has_ac": true, "has_child_seat": true}
  family_context jsonb, -- e.g. {"is_parent": true, "family_driver_willing": true}
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.profile_extensions ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view their own profile extensions"
ON public.profile_extensions FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile extensions"
ON public.profile_extensions FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own profile extensions"
ON public.profile_extensions FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Trigger for updated_at
CREATE TRIGGER trg_profile_extensions_updated_at
BEFORE UPDATE ON public.profile_extensions
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 2. STREAK STATS
CREATE TABLE IF NOT EXISTS public.streak_stats (
  user_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  passenger_streak integer NOT NULL DEFAULT 0,
  driver_streak integer NOT NULL DEFAULT 0,
  last_passenger_trip_at timestamptz,
  last_driver_trip_at timestamptz,
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.streak_stats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own streak stats"
ON public.streak_stats FOR SELECT
USING (auth.uid() = user_id);

-- Trigger for updated_at
CREATE TRIGGER trg_streak_stats_updated_at
BEFORE UPDATE ON public.streak_stats
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 3. INITIAL DATA POPULATION (Optional: Upsert existing users)
INSERT INTO public.profile_extensions (user_id)
SELECT id FROM public.profiles
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO public.streak_stats (user_id)
SELECT id FROM public.profiles
ON CONFLICT (user_id) DO NOTHING;

COMMIT;
