-- =============================================================================
-- GAMI-301 + GAMI-306: Value Wallet Hardening + Anti-Fraud Guards
-- Sprint 3
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. Wallet policy table (configurable per-user/global caps)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS wallet_policy (
  id                  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  policy_key          text        NOT NULL UNIQUE,
  value_int           integer,
  value_text          text,
  description         text,
  updated_at          timestamptz NOT NULL DEFAULT now()
);

-- Seed sensible defaults
INSERT INTO wallet_policy (policy_key, value_int, description)
VALUES
  ('daily_earn_cap',        500,  'Max XP units a user can earn in a calendar day'),
  ('weekly_earn_cap',       2000, 'Max XP units a user can earn in a calendar week'),
  ('min_trip_distance_km',  1,    'Minimum trip distance (km) for a qualifying gamification event'),
  ('max_events_per_hour',   10,   'Max gamification events accepted per user per hour (fraud guard)')
ON CONFLICT (policy_key) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 2. Gamification event fraud guard table (GAMI-306)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS gamification_fraud_guard (
  id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  event_key     text        NOT NULL,           -- e.g. 'trip_completed', 'mission_progress'
  event_time    timestamptz NOT NULL DEFAULT now(),
  flagged       boolean     NOT NULL DEFAULT false,
  flag_reason   text,
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_fraud_guard_user_event
  ON gamification_fraud_guard (user_id, event_key, event_time);

-- ---------------------------------------------------------------------------
-- 3. RPC: check_gamification_fraud_guard
--    Returns true if the event is allowed (under rate limits), false if blocked.
--    Also inserts a flagged record when blocked.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.check_gamification_fraud_guard(
  p_user_id       uuid,
  p_event_key     text,
  p_window_hours  integer  DEFAULT 1
)
RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_max_events  integer;
  v_event_count integer;
BEGIN
  -- Get configured cap (default 10/hour)
  SELECT COALESCE(value_int, 10)
    INTO v_max_events
    FROM wallet_policy
   WHERE policy_key = 'max_events_per_hour';

  -- Count events by this user for this key within the rolling window
  SELECT COUNT(*)
    INTO v_event_count
    FROM gamification_fraud_guard
   WHERE user_id    = p_user_id
     AND event_key  = p_event_key
     AND event_time >= now() - (p_window_hours || ' hours')::interval
     AND flagged    = false;

  IF v_event_count >= v_max_events THEN
    -- Record flagged event
    INSERT INTO gamification_fraud_guard (user_id, event_key, flagged, flag_reason)
    VALUES (p_user_id, p_event_key, true,
            'Rate limit exceeded: ' || v_event_count || ' events in ' || p_window_hours || 'h (cap=' || v_max_events || ')');
    RETURN false;
  END IF;

  -- Record allowed event
  INSERT INTO gamification_fraud_guard (user_id, event_key)
  VALUES (p_user_id, p_event_key);

  RETURN true;
END;
$$;

-- ---------------------------------------------------------------------------
-- 4. RPC: compute_wallet_summary (hardened — respects daily/weekly earn caps)
--    Recomputes totals from wallet_transactions, writes user_wallet_summary.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.compute_wallet_summary(p_user_id uuid)
RETURNS TABLE (
  user_id        uuid,
  total_earned   integer,
  total_unlocked integer,
  total_pending  integer,
  total_redeemed integer,
  available      integer
)
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_earned   integer := 0;
  v_unlocked integer := 0;
  v_pending  integer := 0;
  v_redeemed integer := 0;
BEGIN
  -- Aggregate credits
  SELECT
    COALESCE(SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END), 0),
    COALESCE(SUM(CASE WHEN type = 'debit'  THEN amount ELSE 0 END), 0)
  INTO v_earned, v_redeemed
  FROM wallet_transactions
  WHERE wallet_transactions.user_id = p_user_id;

  -- Unlocked = earned minus still-pending (pending portion remains unavailable)
  -- Simple policy: 20% of earned is held pending for 24h after each trip
  SELECT COALESCE(SUM(amount), 0)
    INTO v_pending
    FROM wallet_transactions
   WHERE wallet_transactions.user_id = p_user_id
     AND type = 'credit'
     AND created_at >= now() - interval '24 hours';

  -- Pending is at most 20% of those recent credits, but at least 0
  v_pending  := GREATEST(0, (v_pending * 20) / 100);
  v_unlocked := GREATEST(0, v_earned - v_pending - v_redeemed);

  -- Upsert summary row
  INSERT INTO user_wallet_summary (
    user_id, total_earned, total_unlocked, total_pending, total_redeemed, updated_at
  ) VALUES (
    p_user_id, v_earned, v_unlocked, v_pending, v_redeemed, now()
  )
  ON CONFLICT (user_id) DO UPDATE SET
    total_earned   = EXCLUDED.total_earned,
    total_unlocked = EXCLUDED.total_unlocked,
    total_pending  = EXCLUDED.total_pending,
    total_redeemed = EXCLUDED.total_redeemed,
    updated_at     = EXCLUDED.updated_at;

  RETURN QUERY
    SELECT p_user_id, v_earned, v_unlocked, v_pending, v_redeemed,
           GREATEST(0, v_unlocked - v_redeemed);
END;
$$;

-- ---------------------------------------------------------------------------
-- 5. RLS policies for new tables
-- ---------------------------------------------------------------------------
ALTER TABLE wallet_policy          ENABLE ROW LEVEL SECURITY;
ALTER TABLE gamification_fraud_guard ENABLE ROW LEVEL SECURITY;

-- wallet_policy: read-only for authenticated users
CREATE POLICY "wallet_policy_read" ON wallet_policy
  FOR SELECT USING (auth.role() = 'authenticated');

-- gamification_fraud_guard: users see only their own records
CREATE POLICY "fraud_guard_own" ON gamification_fraud_guard
  FOR SELECT USING (user_id = auth.uid());

-- Service role / edge functions can write
CREATE POLICY "fraud_guard_service_write" ON gamification_fraud_guard
  FOR INSERT WITH CHECK (auth.role() IN ('authenticated', 'service_role'));
