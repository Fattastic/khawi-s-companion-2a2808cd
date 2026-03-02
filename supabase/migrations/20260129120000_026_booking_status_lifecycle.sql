-- =========================
-- Booking Status Lifecycle Validation
-- =========================

-- First, extend the trip_requests status check to include new statuses
ALTER TABLE public.trip_requests 
DROP CONSTRAINT IF EXISTS trip_requests_status_check;

ALTER TABLE public.trip_requests 
ADD CONSTRAINT trip_requests_status_check 
CHECK (status IN ('pending', 'accepted', 'declined', 'cancelled', 'expired', 'picked_up', 'dropped_off', 'completed'));

-- =========================
-- Transition Validation Trigger
-- =========================

-- Function to validate status transitions
CREATE OR REPLACE FUNCTION public.validate_request_status_transition()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  allowed_transitions text[];
BEGIN
  -- Skip if status hasn't changed
  IF OLD.status = NEW.status THEN
    RETURN NEW;
  END IF;

  -- Define allowed transitions for each status
  -- This mirrors the client-side allowedRequestTransitions map
  allowed_transitions := CASE OLD.status
    WHEN 'pending' THEN ARRAY['accepted', 'declined', 'cancelled', 'expired']
    WHEN 'accepted' THEN ARRAY['picked_up', 'cancelled']
    WHEN 'picked_up' THEN ARRAY['dropped_off']
    WHEN 'dropped_off' THEN ARRAY['completed']
    -- Terminal states - no transitions allowed
    WHEN 'declined' THEN ARRAY[]::text[]
    WHEN 'cancelled' THEN ARRAY[]::text[]
    WHEN 'expired' THEN ARRAY[]::text[]
    WHEN 'completed' THEN ARRAY[]::text[]
    ELSE ARRAY[]::text[]
  END;

  -- Check if transition is allowed
  IF NOT (NEW.status = ANY(allowed_transitions)) THEN
    RAISE EXCEPTION 'Invalid status transition: % → % is not allowed', OLD.status, NEW.status
      USING HINT = 'Allowed transitions from ' || OLD.status || ': ' || array_to_string(allowed_transitions, ', ');
  END IF;

  RETURN NEW;
END;
$$;

-- Create trigger on trip_requests
DROP TRIGGER IF EXISTS trg_validate_request_status ON public.trip_requests;
CREATE TRIGGER trg_validate_request_status
  BEFORE UPDATE OF status ON public.trip_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_request_status_transition();

-- =========================
-- Secure Status Update RPC
-- =========================

-- RPC for updating request status with proper authorization and transition validation
CREATE OR REPLACE FUNCTION public.update_request_status(
  p_request_id uuid,
  p_new_status text
)
RETURNS public.trip_requests
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_req public.trip_requests;
  v_trip public.trips;
  v_caller_id uuid;
  v_is_driver boolean;
  v_is_passenger boolean;
BEGIN
  v_caller_id := auth.uid();
  IF v_caller_id IS NULL THEN 
    RAISE EXCEPTION 'Not authenticated'; 
  END IF;

  -- Get request with lock
  SELECT * INTO v_req
  FROM public.trip_requests
  WHERE id = p_request_id
  FOR UPDATE;

  IF NOT FOUND THEN 
    RAISE EXCEPTION 'Request not found'; 
  END IF;

  -- Get trip
  SELECT * INTO v_trip
  FROM public.trips
  WHERE id = v_req.trip_id;

  -- Determine caller role
  v_is_driver := (v_trip.driver_id = v_caller_id);
  v_is_passenger := (v_req.passenger_id = v_caller_id);

  -- Authorization check based on action
  CASE p_new_status
    WHEN 'accepted', 'declined', 'expired' THEN
      IF NOT v_is_driver THEN
        RAISE EXCEPTION 'Only driver can accept/decline requests';
      END IF;
    WHEN 'cancelled' THEN
      IF NOT (v_is_driver OR v_is_passenger) THEN
        RAISE EXCEPTION 'Only driver or passenger can cancel';
      END IF;
    WHEN 'picked_up', 'dropped_off', 'completed' THEN
      IF NOT v_is_driver THEN
        RAISE EXCEPTION 'Only driver can update ride progress';
      END IF;
    ELSE
      RAISE EXCEPTION 'Unknown status: %', p_new_status;
  END CASE;

  -- Update status (trigger will validate transition)
  UPDATE public.trip_requests
  SET status = p_new_status,
      updated_at = now()
  WHERE id = p_request_id
  RETURNING * INTO v_req;

  RETURN v_req;
END;
$$;

GRANT EXECUTE ON FUNCTION public.update_request_status(uuid, text) TO authenticated;
ALTER FUNCTION public.update_request_status(uuid, text) SET row_security = on;

-- =========================
-- Documentation
-- =========================
COMMENT ON FUNCTION public.validate_request_status_transition() IS 
'Validates booking status transitions server-side. 
Allowed transitions:
  pending → accepted, declined, cancelled, expired
  accepted → picked_up, cancelled
  picked_up → dropped_off
  dropped_off → completed
  declined, cancelled, expired, completed → (terminal, no transitions)';

COMMENT ON FUNCTION public.update_request_status(uuid, text) IS 
'Updates trip request status with authorization and transition validation.
Authorization:
  - Driver: can accept, decline, expire, pick_up, drop_off, complete
  - Passenger: can cancel (from pending or accepted)
Transition validation is enforced by the trg_validate_request_status trigger.';
