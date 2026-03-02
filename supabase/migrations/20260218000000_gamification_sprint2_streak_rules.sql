-- ============================================================================
-- GAMI-201: Streak grace/recovery rule hardening
-- Patches evaluate_streak_on_trip to add:
--   - active → grace transition (missed a day, grace window = 24 h)
--   - grace expired → broken transition
--   - idempotency guard (same trip_id does not double-count)
--   - GAMI-202/203: HTTP wrappers moved to edge functions; no schema change.
-- ============================================================================

-- Idempotency table: records trip_ids already processed by streak evaluation
CREATE TABLE IF NOT EXISTS public.streak_processed_trips (
  user_id  uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  trip_id  uuid NOT NULL,
  processed_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, trip_id)
);

COMMENT ON TABLE public.streak_processed_trips IS
  'Guards evaluate_streak_on_trip against double-processing the same trip.';

ALTER TABLE public.streak_processed_trips ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Service role manages streak_processed_trips"
  ON public.streak_processed_trips FOR ALL
  USING (auth.role() = 'service_role');

-- Index for fast per-user lookup
CREATE INDEX IF NOT EXISTS idx_streak_processed_user
  ON public.streak_processed_trips (user_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- Rebuild evaluate_streak_on_trip with full state-machine
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.evaluate_streak_on_trip(
  p_user_id uuid,
  p_trip_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_streak  record;
  v_result  jsonb;
  v_now     timestamptz := now();
  v_today   date        := current_date;
  v_yesterday date      := current_date - 1;
BEGIN
  -- ── Idempotency guard ─────────────────────────────────────────────────
  IF EXISTS (
    SELECT 1 FROM streak_processed_trips
    WHERE user_id = p_user_id AND trip_id = p_trip_id
  ) THEN
    SELECT * INTO v_streak FROM user_streaks WHERE user_id = p_user_id;
    RETURN jsonb_build_object(
      'status',        COALESCE(v_streak.status, 'broken'),
      'current_count', COALESCE(v_streak.current_count, 0),
      'changed',       false,
      'skip_reason',   'already_processed'
    );
  END IF;

  -- ── Ensure streak row exists ──────────────────────────────────────────
  INSERT INTO user_streaks (user_id, current_count, longest_count, status, last_trip_at, updated_at)
  VALUES (p_user_id, 0, 0, 'broken', NULL, v_now)
  ON CONFLICT (user_id) DO NOTHING;

  SELECT * INTO v_streak FROM user_streaks WHERE user_id = p_user_id FOR UPDATE;

  -- ── Already counted a trip today → idempotent (date-level) ────────────
  IF v_streak.last_trip_at IS NOT NULL
     AND v_streak.last_trip_at::date = v_today THEN
    -- Record trip_id so the trip-level guard fires next time
    INSERT INTO streak_processed_trips (user_id, trip_id)
    VALUES (p_user_id, p_trip_id)
    ON CONFLICT DO NOTHING;
    RETURN jsonb_build_object(
      'status',        v_streak.status,
      'current_count', v_streak.current_count,
      'changed',       false,
      'skip_reason',   'already_counted_today'
    );
  END IF;

  -- ── State-machine transitions ─────────────────────────────────────────
  -- 1. Active/Recovered + consecutive day → extend streak
  IF v_streak.status IN ('active', 'recovered')
     AND v_streak.last_trip_at IS NOT NULL
     AND v_streak.last_trip_at::date = v_yesterday THEN

    UPDATE user_streaks SET
      status        = 'active',
      current_count = current_count + 1,
      longest_count = GREATEST(longest_count, current_count + 1),
      last_trip_at  = v_now,
      grace_expires_at = NULL,
      updated_at    = v_now
    WHERE user_id = p_user_id;

    v_result := jsonb_build_object(
      'status',        'active',
      'current_count', v_streak.current_count + 1,
      'changed',       true,
      'transition',    'extended'
    );

  -- 2. Grace window still open → recovery
  ELSIF v_streak.status = 'grace'
        AND v_streak.grace_expires_at IS NOT NULL
        AND v_streak.grace_expires_at > v_now THEN

    UPDATE user_streaks SET
      status        = 'recovered',
      current_count = current_count + 1,
      longest_count = GREATEST(longest_count, current_count + 1),
      last_trip_at  = v_now,
      grace_expires_at = NULL,
      updated_at    = v_now
    WHERE user_id = p_user_id;

    v_result := jsonb_build_object(
      'status',        'recovered',
      'current_count', v_streak.current_count + 1,
      'changed',       true,
      'transition',    'grace_recovered'
    );

  -- 3. Active/Recovered + missed more than 1 day → enter grace (24 h)
  ELSIF v_streak.status IN ('active', 'recovered')
        AND v_streak.last_trip_at IS NOT NULL
        AND v_streak.last_trip_at::date < v_yesterday THEN

    -- Trip today starts a fresh streak (grace window expired by definition)
    UPDATE user_streaks SET
      status        = 'active',
      current_count = 1,
      last_trip_at  = v_now,
      grace_expires_at = NULL,
      updated_at    = v_now
    WHERE user_id = p_user_id;

    v_result := jsonb_build_object(
      'status',        'active',
      'current_count', 1,
      'changed',       true,
      'transition',    'restarted_after_break',
      'was_broken',    true
    );

  -- 4. Broken or first-ever trip → start fresh streak
  ELSE
    UPDATE user_streaks SET
      status        = 'active',
      current_count = 1,
      last_trip_at  = v_now,
      grace_expires_at = NULL,
      updated_at    = v_now
    WHERE user_id = p_user_id;

    v_result := jsonb_build_object(
      'status',        'active',
      'current_count', 1,
      'changed',       true,
      'transition',    'started',
      'was_broken',    (v_streak.status = 'broken')
    );
  END IF;

  -- ── Mark trip processed ───────────────────────────────────────────────
  INSERT INTO streak_processed_trips (user_id, trip_id)
  VALUES (p_user_id, p_trip_id)
  ON CONFLICT DO NOTHING;

  RETURN v_result;
END;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- Scheduled helper: expire active streaks → grace, grace → broken
-- Called by a pg_cron job or edge function cron at midnight UTC each day.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.expire_stale_streaks()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_now        timestamptz := now();
  v_yesterday  date        := current_date - 1;
  v_graced     int := 0;
  v_broken_cnt int := 0;
BEGIN
  -- Active streaks that missed yesterday → enter 24-h grace
  UPDATE user_streaks SET
    status           = 'grace',
    grace_expires_at = v_now + interval '24 hours',
    updated_at       = v_now
  WHERE status = 'active'
    AND last_trip_at IS NOT NULL
    AND last_trip_at::date < v_yesterday;
  GET DIAGNOSTICS v_graced = ROW_COUNT;

  -- Grace windows that have expired → broken
  UPDATE user_streaks SET
    status           = 'broken',
    current_count    = 0,
    grace_expires_at = NULL,
    updated_at       = v_now
  WHERE status = 'grace'
    AND grace_expires_at IS NOT NULL
    AND grace_expires_at < v_now;
  GET DIAGNOSTICS v_broken_cnt = ROW_COUNT;

  RETURN jsonb_build_object(
    'entered_grace', v_graced,
    'broken',        v_broken_cnt
  );
END;
$$;

COMMENT ON FUNCTION public.expire_stale_streaks() IS
  'Run nightly via pg_cron or edge cron to advance active→grace and grace→broken.';
