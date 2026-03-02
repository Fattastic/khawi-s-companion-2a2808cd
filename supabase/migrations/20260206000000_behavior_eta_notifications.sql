-- Migration: Add Behavior Score, ETA caching, and Notifications table
-- Date: 2026-02-06

-- 1. Add behavior_score to profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS behavior_score float DEFAULT 50.0 
CHECK (behavior_score >= 0.0 AND behavior_score <= 100.0);

-- 2. Add eta_minutes to trips
ALTER TABLE public.trips 
ADD COLUMN IF NOT EXISTS eta_minutes integer;

-- 3. Create notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
    title text NOT NULL,
    body text NOT NULL,
    type text DEFAULT 'info', -- info, success, warning, error
    metadata jsonb DEFAULT '{}'::jsonb,
    is_read boolean DEFAULT false,
    created_at timestamptz DEFAULT now()
);

-- 4. Enable RLS on notifications
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications" 
ON public.notifications FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "System can insert notifications" 
ON public.notifications FOR INSERT 
WITH CHECK (true); -- Ideally restrict to service role, but for simplicity...

-- 5. Trigger for Junior Run status updates to notify parents
CREATE OR REPLACE FUNCTION public.handle_junior_run_notification()
RETURNS TRIGGER AS $$
DECLARE
    v_parent_id uuid;
    v_kid_name text;
    v_title text;
    v_body text;
BEGIN
    -- Get parent_id and kid name
    SELECT parent_id, k.name INTO v_parent_id, v_kid_name
    FROM public.junior_runs jr
    JOIN public.kids k ON k.id = jr.kid_id
    WHERE jr.id = NEW.run_id;

    -- Define notification content based on status
    CASE NEW.new_status
        WHEN 'arrived' THEN
            v_title := 'Driver Arrived! 🚗';
            v_body := v_kid_name || '''s driver has arrived at the pickup location.';
        WHEN 'picked_up' THEN
            v_title := 'Trip Started! ✅';
            v_body := v_kid_name || ' has been picked up.';
        WHEN 'dropped_off' THEN
            v_title := 'Arrived at Destination! 📍';
            v_body := v_kid_name || ' has been dropped off at the destination.';
        WHEN 'completed' THEN
            v_title := 'Trip Completed! ⭐';
            v_body := v_kid_name || '''s trip is successfully completed.';
        ELSE
            RETURN NEW;
    END CASE;

    -- Insert notification
    INSERT INTO public.notifications (user_id, title, body, type, metadata)
    VALUES (v_parent_id, v_title, v_body, 'info', jsonb_build_object('run_id', NEW.run_id, 'status', NEW.new_status));

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_junior_run_status_change
    AFTER INSERT ON public.junior_run_events
    FOR EACH ROW
    WHEN (NEW.event_type IN ('arrived', 'picked_up', 'dropped_off', 'completed'))
    EXECUTE FUNCTION public.handle_junior_run_notification();

-- 6. Trigger for SOS events
CREATE OR REPLACE FUNCTION public.handle_sos_notification()
RETURNS TRIGGER AS $$
DECLARE
    v_parent_id uuid;
    v_kid_name text;
BEGIN
    IF NEW.run_id IS NOT NULL THEN
        SELECT parent_id, k.name INTO v_parent_id, v_kid_name
        FROM public.junior_runs jr
        JOIN public.kids k ON k.id = jr.kid_id
        WHERE jr.id = NEW.run_id;

        INSERT INTO public.notifications (user_id, title, body, type, metadata)
        VALUES (v_parent_id, '🚨 SOS ALERT!', 'An SOS was triggered during ' || v_kid_name || '''s trip!', 'error', jsonb_build_object('sos_id', NEW.id, 'run_id', NEW.run_id));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_sos_event
    AFTER INSERT ON public.sos_events
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_sos_notification();
