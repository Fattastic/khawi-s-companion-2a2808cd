-- =========================
-- Premium-Gated Reward Redemptions
-- =========================

-- Table for tracking reward redemptions (requires premium)
CREATE TABLE IF NOT EXISTS public.reward_redemptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  reward_id text NOT NULL,
  xp_cost integer NOT NULL CHECK (xp_cost > 0),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'cancelled', 'failed')),
  created_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_reward_redemptions_user ON public.reward_redemptions(user_id, created_at);

-- Enable RLS
ALTER TABLE public.reward_redemptions ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Only premium users can INSERT, all users can SELECT their own
CREATE POLICY reward_redemptions_select_own ON public.reward_redemptions 
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY reward_redemptions_insert_premium_only ON public.reward_redemptions 
  FOR INSERT WITH CHECK (
    auth.uid() = user_id 
    AND EXISTS (
      SELECT 1 FROM public.profiles p 
      WHERE p.id = auth.uid() 
      AND p.is_premium = true
    )
  );

-- No direct updates or deletes allowed
CREATE POLICY reward_redemptions_update_none ON public.reward_redemptions 
  FOR UPDATE USING (false);

CREATE POLICY reward_redemptions_delete_none ON public.reward_redemptions 
  FOR DELETE USING (false);

-- =========================
-- Secure XP Redemption RPC
-- =========================
-- This RPC enforces premium requirement server-side and returns proper errors

CREATE OR REPLACE FUNCTION public.redeem_xp_premium(p_amount integer, p_reward_id text DEFAULT 'xp_cash_out')
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_profile public.profiles;
  v_redemption_id uuid;
BEGIN
  -- Authentication check
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'not_authenticated', 'message', 'Not authenticated');
  END IF;

  -- Validate amount
  IF p_amount <= 0 THEN
    RETURN json_build_object('success', false, 'error', 'invalid_amount', 'message', 'Amount must be positive');
  END IF;

  -- Get profile with lock
  SELECT * INTO v_profile FROM public.profiles WHERE id = v_user_id FOR UPDATE;
  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'error', 'profile_not_found', 'message', 'Profile not found');
  END IF;

  -- Premium check (server-side enforcement)
  IF NOT v_profile.is_premium THEN
    RETURN json_build_object('success', false, 'error', 'premium_required', 'message', 'Premium subscription required to redeem XP');
  END IF;

  -- Balance check
  IF p_amount > v_profile.redeemable_xp THEN
    RETURN json_build_object('success', false, 'error', 'insufficient_balance', 'message', 'Insufficient redeemable XP balance');
  END IF;

  -- Insert redemption record
  INSERT INTO public.reward_redemptions (user_id, reward_id, xp_cost, status, completed_at)
  VALUES (v_user_id, p_reward_id, p_amount, 'completed', now())
  RETURNING id INTO v_redemption_id;

  -- Deduct XP
  UPDATE public.profiles 
  SET redeemable_xp = redeemable_xp - p_amount, updated_at = now() 
  WHERE id = v_user_id;

  -- Record XP event
  INSERT INTO public.xp_events (user_id, source, base_xp, multiplier, bonus_xp, total_xp, meta)
  VALUES (v_user_id, 'bonus', 0, 1, -p_amount, -p_amount, jsonb_build_object('action', 'redeem', 'redemption_id', v_redemption_id, 'reward_id', p_reward_id));

  RETURN json_build_object(
    'success', true, 
    'redemption_id', v_redemption_id, 
    'amount', p_amount, 
    'new_balance', v_profile.redeemable_xp - p_amount
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.redeem_xp_premium(integer, text) TO authenticated;
ALTER FUNCTION public.redeem_xp_premium(integer, text) SET row_security = on;
