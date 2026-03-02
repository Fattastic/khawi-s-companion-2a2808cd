-- =========================
-- Driver Verification Enforcement
-- =========================
-- Ensures drivers can only post trips if they are verified.
-- This prevents unverified drivers from bypassing client-side checks.

-- Drop existing trips insert policy
DROP POLICY IF EXISTS "trips_insert_driver_only" ON public.trips;

-- Create new policy that enforces driver verification
CREATE POLICY "trips_insert_verified_driver_only"
ON public.trips FOR INSERT
WITH CHECK (
  auth.uid() = driver_id
  AND EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.id = auth.uid()
      AND p.role = 'driver'
      AND p.is_verified = true
  )
);

-- =========================
-- Documentation
-- =========================
COMMENT ON POLICY "trips_insert_verified_driver_only" ON public.trips IS 
'Enforces that only verified drivers can create trips.
Server-side enforcement prevents bypassing client-side verification gates.';

-- =========================
-- Helper RPC for Verification Check
-- =========================
-- Returns verification status for the current user (useful for debugging)
CREATE OR REPLACE FUNCTION public.get_driver_verification_status()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_profile public.profiles;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RETURN json_build_object('error', 'not_authenticated');
  END IF;

  SELECT * INTO v_profile FROM public.profiles WHERE id = v_user_id;
  IF NOT FOUND THEN
    RETURN json_build_object('error', 'profile_not_found');
  END IF;

  RETURN json_build_object(
    'user_id', v_user_id,
    'role', v_profile.role,
    'is_verified', v_profile.is_verified,
    'can_post_trips', (v_profile.role = 'driver' AND v_profile.is_verified)
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_driver_verification_status() TO authenticated;

COMMENT ON FUNCTION public.get_driver_verification_status() IS 
'Returns the driver verification status for the current user.
Useful for debugging and understanding why trip creation may be blocked.';
