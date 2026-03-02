-- ============================================================================
-- GAMIFICATION TIER-1: Streaks, Missions, Wallet, Experiments
-- ============================================================================
-- Tables: user_streaks, user_missions, user_wallet_summary,
--         wallet_transactions, experiment_cohorts
-- RPCs:   evaluate_streak_on_trip, evaluate_mission_progress,
--         assign_weekly_missions, compute_wallet_summary,
--         assign_experiment_cohort
-- ============================================================================

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  user_streaks — running streak state per user                          │
-- └──────────────────────────────────────────────────────────────────────────┘

CREATE TABLE IF NOT EXISTS public.user_streaks (
  user_id       uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  current_count int  NOT NULL DEFAULT 0,
  longest_count int  NOT NULL DEFAULT 0,
  status        text NOT NULL DEFAULT 'broken'
                CHECK (status IN ('active', 'grace', 'broken', 'recovered')),
  grace_expires_at timestamptz,
  last_trip_at     timestamptz,
  updated_at       timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE  public.user_streaks IS 'Running commute-streak state per user.';
COMMENT ON COLUMN public.user_streaks.status IS 'active | grace | broken | recovered';

ALTER TABLE public.user_streaks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own streak"
  ON public.user_streaks FOR SELECT
  USING (user_id = (select auth.uid()));

CREATE POLICY "Service role manages streaks"
  ON public.user_streaks FOR ALL
  USING (auth.role() = 'service_role');

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  user_missions — weekly mission instances                              │
-- └──────────────────────────────────────────────────────────────────────────┘

CREATE TABLE IF NOT EXISTS public.user_missions (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title_ar       text NOT NULL DEFAULT '',
  title_en       text NOT NULL DEFAULT '',
  description_ar text NOT NULL DEFAULT '',
  description_en text NOT NULL DEFAULT '',
  category       text NOT NULL DEFAULT 'general'
                 CHECK (category IN ('commute', 'social', 'safety', 'general')),
  current_count  int  NOT NULL DEFAULT 0,
  target_count   int  NOT NULL DEFAULT 1,
  reward_xp      int  NOT NULL DEFAULT 0,
  status         text NOT NULL DEFAULT 'active'
                 CHECK (status IN ('active', 'completed', 'expired', 'cancelled')),
  week_start     date NOT NULL DEFAULT (date_trunc('week', now())::date),
  expires_at     timestamptz NOT NULL DEFAULT (date_trunc('week', now()) + interval '7 days'),
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_user_missions_user_week
  ON public.user_missions (user_id, week_start);

CREATE INDEX idx_user_missions_status
  ON public.user_missions (status)
  WHERE status = 'active';

COMMENT ON TABLE public.user_missions IS 'Per-user weekly mission instances with progress tracking.';

ALTER TABLE public.user_missions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own missions"
  ON public.user_missions FOR SELECT
  USING (user_id = (select auth.uid()));

CREATE POLICY "Service role manages missions"
  ON public.user_missions FOR ALL
  USING (auth.role() = 'service_role');

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  user_wallet_summary — materialized XP balance per user                │
-- └──────────────────────────────────────────────────────────────────────────┘

CREATE TABLE IF NOT EXISTS public.user_wallet_summary (
  user_id        uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  total_earned   int  NOT NULL DEFAULT 0,
  total_unlocked int  NOT NULL DEFAULT 0,
  total_pending  int  NOT NULL DEFAULT 0,
  total_redeemed int  NOT NULL DEFAULT 0,
  updated_at     timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.user_wallet_summary IS 'Materialized XP wallet balances, recomputed on events.';

ALTER TABLE public.user_wallet_summary ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own wallet"
  ON public.user_wallet_summary FOR SELECT
  USING (user_id = (select auth.uid()));

CREATE POLICY "Service role manages wallet"
  ON public.user_wallet_summary FOR ALL
  USING (auth.role() = 'service_role');

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  wallet_transactions — XP debit/credit log                             │
-- └──────────────────────────────────────────────────────────────────────────┘

CREATE TABLE IF NOT EXISTS public.wallet_transactions (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount      int  NOT NULL,
  type        text NOT NULL CHECK (type IN ('credit', 'debit')),
  reason      text NOT NULL DEFAULT '',
  reference_id text,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_wallet_txn_user
  ON public.wallet_transactions (user_id, created_at DESC);

COMMENT ON TABLE public.wallet_transactions IS 'Immutable ledger of XP credits and debits.';

ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own transactions"
  ON public.wallet_transactions FOR SELECT
  USING (user_id = (select auth.uid()));

CREATE POLICY "Service role manages transactions"
  ON public.wallet_transactions FOR ALL
  USING (auth.role() = 'service_role');

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  experiment_cohorts — A/B test assignments                             │
-- └──────────────────────────────────────────────────────────────────────────┘

CREATE TABLE IF NOT EXISTS public.experiment_cohorts (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  experiment_id text NOT NULL,
  cohort        text NOT NULL,
  variant       text NOT NULL DEFAULT 'control',
  assigned_at   timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, experiment_id)
);

CREATE INDEX idx_experiment_user
  ON public.experiment_cohorts (user_id);

COMMENT ON TABLE public.experiment_cohorts IS 'Per-user A/B experiment cohort assignments.';

ALTER TABLE public.experiment_cohorts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own cohort"
  ON public.experiment_cohorts FOR SELECT
  USING (user_id = (select auth.uid()));

CREATE POLICY "Service role manages cohorts"
  ON public.experiment_cohorts FOR ALL
  USING (auth.role() = 'service_role');

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  RPCs                                                                  │
-- └──────────────────────────────────────────────────────────────────────────┘

-- evaluate_streak_on_trip: called after trip completion to update streak state
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
  v_today   date       := current_date;
BEGIN
  -- Upsert streak row
  INSERT INTO user_streaks (user_id, current_count, longest_count, status, last_trip_at, updated_at)
  VALUES (p_user_id, 0, 0, 'broken', NULL, v_now)
  ON CONFLICT (user_id) DO NOTHING;

  SELECT * INTO v_streak FROM user_streaks WHERE user_id = p_user_id FOR UPDATE;

  -- Already counted a trip today
  IF v_streak.last_trip_at IS NOT NULL AND v_streak.last_trip_at::date = v_today THEN
    RETURN jsonb_build_object('status', v_streak.status, 'current_count', v_streak.current_count, 'changed', false);
  END IF;

  -- Evaluate state transitions
  IF v_streak.status = 'grace' AND v_streak.grace_expires_at > v_now THEN
    -- Recovered during grace
    UPDATE user_streaks SET
      status = 'recovered',
      current_count = current_count + 1,
      longest_count = GREATEST(longest_count, current_count + 1),
      last_trip_at = v_now,
      grace_expires_at = NULL,
      updated_at = v_now
    WHERE user_id = p_user_id;
    v_result := jsonb_build_object('status', 'recovered', 'current_count', v_streak.current_count + 1, 'changed', true);

  ELSIF v_streak.status IN ('active', 'recovered') AND
        v_streak.last_trip_at IS NOT NULL AND
        v_streak.last_trip_at::date = v_today - 1 THEN
    -- Consecutive day continuation
    UPDATE user_streaks SET
      status = 'active',
      current_count = current_count + 1,
      longest_count = GREATEST(longest_count, current_count + 1),
      last_trip_at = v_now,
      updated_at = v_now
    WHERE user_id = p_user_id;
    v_result := jsonb_build_object('status', 'active', 'current_count', v_streak.current_count + 1, 'changed', true);

  ELSE
    -- New streak (broken or first-ever)
    UPDATE user_streaks SET
      status = 'active',
      current_count = 1,
      last_trip_at = v_now,
      grace_expires_at = NULL,
      updated_at = v_now
    WHERE user_id = p_user_id;
    v_result := jsonb_build_object('status', 'active', 'current_count', 1, 'changed', true, 'was_broken', true);
  END IF;

  RETURN v_result;
END;
$$;

-- evaluate_mission_progress: increment mission counter on qualifying action
CREATE OR REPLACE FUNCTION public.evaluate_mission_progress(
  p_user_id   uuid,
  p_category  text,
  p_increment int DEFAULT 1
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_mission  record;
  v_results  jsonb := '[]'::jsonb;
BEGIN
  FOR v_mission IN
    SELECT * FROM user_missions
    WHERE user_id = p_user_id
      AND status = 'active'
      AND (category = p_category OR category = 'general')
      AND expires_at > now()
    ORDER BY created_at
    FOR UPDATE
  LOOP
    UPDATE user_missions SET
      current_count = LEAST(current_count + p_increment, target_count),
      status = CASE
        WHEN current_count + p_increment >= target_count THEN 'completed'
        ELSE 'active'
      END,
      updated_at = now()
    WHERE id = v_mission.id;

    v_results := v_results || jsonb_build_object(
      'mission_id', v_mission.id,
      'category', v_mission.category,
      'new_count', LEAST(v_mission.current_count + p_increment, v_mission.target_count),
      'target', v_mission.target_count,
      'completed', (v_mission.current_count + p_increment >= v_mission.target_count)
    );
  END LOOP;

  RETURN jsonb_build_object('missions_updated', v_results);
END;
$$;

-- assign_weekly_missions: idempotent assignment of weekly missions
CREATE OR REPLACE FUNCTION public.assign_weekly_missions(
  p_user_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_week_start date := date_trunc('week', now())::date;
  v_existing   int;
BEGIN
  SELECT count(*) INTO v_existing
  FROM user_missions
  WHERE user_id = p_user_id AND week_start = v_week_start;

  IF v_existing > 0 THEN
    RETURN jsonb_build_object('assigned', false, 'reason', 'already_assigned', 'count', v_existing);
  END IF;

  -- Insert 3 starter missions (template-based expansion in Tier-2)
  INSERT INTO user_missions (user_id, title_ar, title_en, description_ar, description_en, category, target_count, reward_xp, week_start, expires_at)
  VALUES
    (p_user_id, 'أكمل 3 رحلات', 'Complete 3 trips', 'أكمل 3 رحلات هذا الأسبوع', 'Complete 3 trips this week', 'commute', 3, 100, v_week_start, v_week_start + interval '7 days'),
    (p_user_id, 'شارك رحلة', 'Share a trip', 'شارك رحلة واحدة مع مجتمعك', 'Share one trip with your community', 'social', 1, 50, v_week_start, v_week_start + interval '7 days'),
    (p_user_id, 'قيّم رحلة', 'Rate a trip', 'قيّم رحلة واحدة على الأقل', 'Rate at least one trip', 'safety', 1, 50, v_week_start, v_week_start + interval '7 days');

  RETURN jsonb_build_object('assigned', true, 'count', 3);
END;
$$;

-- compute_wallet_summary: recompute materialized wallet from ledger
CREATE OR REPLACE FUNCTION public.compute_wallet_summary(
  p_user_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_earned   int;
  v_redeemed int;
BEGIN
  SELECT
    COALESCE(SUM(amount) FILTER (WHERE type = 'credit'), 0),
    COALESCE(ABS(SUM(amount) FILTER (WHERE type = 'debit')), 0)
  INTO v_earned, v_redeemed
  FROM wallet_transactions
  WHERE user_id = p_user_id;

  INSERT INTO user_wallet_summary (user_id, total_earned, total_unlocked, total_pending, total_redeemed, updated_at)
  VALUES (p_user_id, v_earned, v_earned, 0, v_redeemed, now())
  ON CONFLICT (user_id) DO UPDATE SET
    total_earned   = v_earned,
    total_unlocked = v_earned,
    total_pending  = 0,
    total_redeemed = v_redeemed,
    updated_at     = now();

  RETURN jsonb_build_object(
    'total_earned', v_earned,
    'total_redeemed', v_redeemed,
    'available', v_earned - v_redeemed
  );
END;
$$;

-- assign_experiment_cohort: idempotent experiment cohort assignment
CREATE OR REPLACE FUNCTION public.assign_experiment_cohort(
  p_user_id       uuid,
  p_experiment_id text,
  p_cohort        text DEFAULT 'control',
  p_variant       text DEFAULT 'control'
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_existing record;
BEGIN
  SELECT * INTO v_existing
  FROM experiment_cohorts
  WHERE user_id = p_user_id AND experiment_id = p_experiment_id;

  IF v_existing IS NOT NULL THEN
    RETURN jsonb_build_object(
      'assigned', false,
      'cohort', v_existing.cohort,
      'variant', v_existing.variant
    );
  END IF;

  INSERT INTO experiment_cohorts (user_id, experiment_id, cohort, variant)
  VALUES (p_user_id, p_experiment_id, p_cohort, p_variant);

  RETURN jsonb_build_object('assigned', true, 'cohort', p_cohort, 'variant', p_variant);
END;
$$;
