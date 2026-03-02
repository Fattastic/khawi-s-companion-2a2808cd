-- =============================================================================
-- GAMI-305 addendum: nba_click_events table for NBA CTA click tracking
-- (Included here alongside GAMI-306 anti-fraud; applied as one migration
--  after the sprint 3 wallet migration.)
-- =============================================================================

CREATE TABLE IF NOT EXISTS nba_click_events (
  id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  action_type   text        NOT NULL,
  reason        text,
  potential_xp  integer     NOT NULL DEFAULT 0,
  deep_link     text,
  clicked_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_nba_clicks_user
  ON nba_click_events (user_id, clicked_at);

ALTER TABLE nba_click_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "nba_clicks_own_read" ON nba_click_events
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "nba_clicks_own_insert" ON nba_click_events
  FOR INSERT WITH CHECK (user_id = auth.uid());
