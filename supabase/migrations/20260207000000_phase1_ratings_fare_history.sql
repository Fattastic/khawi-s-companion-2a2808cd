-- ============================================================================
-- Phase 1: Ratings, Distance Tracking & Ride History
-- ============================================================================
-- Adds:
--   1. ride_ratings table for 5-star post-ride reviews
--   2. New columns on profiles (average_rating, total_ratings)
--   3. New columns on trips (distance_km, co2_saved_kg)
--   4. New columns on trip_requests (rating_given, rating_received)
-- ============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. RIDE RATINGS TABLE
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.ride_ratings (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id     uuid NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
  rater_id    uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  rated_id    uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  score       smallint NOT NULL CHECK (score >= 1 AND score <= 5),
  tags        text[] DEFAULT '{}',
  comment     text,
  created_at  timestamptz NOT NULL DEFAULT now(),

  -- One rating per rater per trip
  UNIQUE (trip_id, rater_id)
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_ride_ratings_rated_id ON public.ride_ratings(rated_id);
CREATE INDEX IF NOT EXISTS idx_ride_ratings_trip_id  ON public.ride_ratings(trip_id);
CREATE INDEX IF NOT EXISTS idx_ride_ratings_rater_id ON public.ride_ratings(rater_id);

-- RLS
ALTER TABLE public.ride_ratings ENABLE ROW LEVEL SECURITY;

-- Users can read ratings about them or that they gave
CREATE POLICY "Users can read own ratings"
  ON public.ride_ratings FOR SELECT
  USING (auth.uid() = rater_id OR auth.uid() = rated_id);

-- Users can insert their own ratings
CREATE POLICY "Users can insert own ratings"
  ON public.ride_ratings FOR INSERT
  WITH CHECK (auth.uid() = rater_id);

-- Users cannot update or delete ratings (immutable once submitted)
-- Service role can still manage via admin API

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. PROFILE COLUMNS FOR AGGREGATE RATINGS
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS average_rating double precision,
  ADD COLUMN IF NOT EXISTS total_ratings  integer NOT NULL DEFAULT 0;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. TRIP DISTANCE & ENVIRONMENTAL COLUMNS
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.trips
  ADD COLUMN IF NOT EXISTS distance_km            double precision,
  ADD COLUMN IF NOT EXISTS co2_saved_kg           double precision;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. TRIP REQUEST RATING COLUMNS
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.trip_requests
  ADD COLUMN IF NOT EXISTS rating_given     smallint CHECK (rating_given IS NULL OR (rating_given >= 1 AND rating_given <= 5)),
  ADD COLUMN IF NOT EXISTS rating_received  smallint CHECK (rating_received IS NULL OR (rating_received >= 1 AND rating_received <= 5));

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. HELPER RPC: RECALCULATE AVERAGE RATING
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.recalculate_average_rating(target_user_id uuid)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  UPDATE profiles
  SET average_rating = sub.avg_score,
      total_ratings  = sub.cnt
  FROM (
    SELECT
      AVG(score)::double precision AS avg_score,
      COUNT(*)::integer           AS cnt
    FROM ride_ratings
    WHERE rated_id = target_user_id
  ) sub
  WHERE id = target_user_id;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. TRIGGER: AUTO-UPDATE AVERAGE RATING ON NEW RATING
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.trg_update_avg_rating()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM recalculate_average_rating(NEW.rated_id);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_ride_rating_insert ON public.ride_ratings;
CREATE TRIGGER on_ride_rating_insert
  AFTER INSERT ON public.ride_ratings
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_update_avg_rating();
