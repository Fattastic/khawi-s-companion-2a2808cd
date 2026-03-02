-- ============================================================================
-- Phase: Khawi Communities (حارة خاوي) + Event Rides
-- ============================================================================

-- --------------------------------------------------------------------------
-- COMMUNITIES
-- --------------------------------------------------------------------------

-- Community type enum
CREATE TYPE community_type AS ENUM (
  'neighborhood',   -- حارة — auto-joined by location
  'workplace',      -- مقر عمل — colleagues
  'school',         -- مدرسة / جامعة — students
  'custom'          -- مخصص — user-created group
);

-- Main communities table
CREATE TABLE IF NOT EXISTS communities (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT NOT NULL,
  name_ar      TEXT,                          -- Arabic display name
  description  TEXT,
  type         community_type NOT NULL DEFAULT 'custom',
  icon_url     TEXT,                          -- optional community icon
  cover_url    TEXT,                          -- optional cover image
  location     geography(Point, 4326),        -- center point for geo-matching
  radius_km    NUMERIC DEFAULT 5,             -- match radius in km
  creator_id   UUID REFERENCES profiles(id),
  member_count INT DEFAULT 0,
  is_verified  BOOLEAN DEFAULT false,         -- admin-verified community
  is_active    BOOLEAN DEFAULT true,
  metadata     JSONB DEFAULT '{}',            -- flexible extra data
  created_at   TIMESTAMPTZ DEFAULT now(),
  updated_at   TIMESTAMPTZ DEFAULT now()
);

-- Membership junction table
CREATE TABLE IF NOT EXISTS community_members (
  community_id UUID REFERENCES communities(id) ON DELETE CASCADE,
  user_id      UUID REFERENCES profiles(id) ON DELETE CASCADE,
  role         TEXT DEFAULT 'member' CHECK (role IN ('admin', 'moderator', 'member')),
  joined_at    TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (community_id, user_id)
);

-- Community ride board (rides shared to a community first)
CREATE TABLE IF NOT EXISTS community_rides (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id UUID REFERENCES communities(id) ON DELETE CASCADE,
  trip_id      UUID REFERENCES trips(id) ON DELETE CASCADE,
  posted_by    UUID REFERENCES profiles(id),
  message      TEXT,                          -- optional note
  created_at   TIMESTAMPTZ DEFAULT now(),
  UNIQUE (community_id, trip_id)
);

-- --------------------------------------------------------------------------
-- EVENTS
-- --------------------------------------------------------------------------

-- Event category enum
CREATE TYPE event_category AS ENUM (
  'entertainment',   -- حفلة / مهرجان — Riyadh Season, MDL Beast, etc.
  'sports',          -- رياضة — football matches, races
  'religious',       -- ديني — Hajj, Umrah, Eid prayers
  'education',       -- تعليمي — university events, exams
  'business',        -- أعمال — conferences, exhibitions
  'community',       -- مجتمعي — volunteering, meetups
  'other'
);

-- Events table
CREATE TABLE IF NOT EXISTS events (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title         TEXT NOT NULL,
  title_ar      TEXT,                         -- Arabic title
  description   TEXT,
  category      event_category NOT NULL DEFAULT 'entertainment',
  venue_name    TEXT,                         -- e.g. "Boulevard Riyadh City"
  venue_lat     DOUBLE PRECISION,
  venue_lng     DOUBLE PRECISION,
  start_time    TIMESTAMPTZ NOT NULL,
  end_time      TIMESTAMPTZ,
  image_url     TEXT,                         -- event poster/banner
  organizer     TEXT,                         -- e.g. "Riyadh Season"
  is_featured   BOOLEAN DEFAULT false,
  is_active     BOOLEAN DEFAULT true,
  expected_attendance INT,                    -- helps estimate demand
  ride_count    INT DEFAULT 0,                -- rides offered for this event
  metadata      JSONB DEFAULT '{}',
  created_by    UUID REFERENCES profiles(id),
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- Event rides — rides linked to a specific event
CREATE TABLE IF NOT EXISTS event_rides (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id   UUID REFERENCES events(id) ON DELETE CASCADE,
  trip_id    UUID REFERENCES trips(id) ON DELETE CASCADE,
  direction  TEXT DEFAULT 'to' CHECK (direction IN ('to', 'from')),
  posted_by  UUID REFERENCES profiles(id),
  seats_offered INT DEFAULT 1,
  message    TEXT,                             -- e.g. "Leaving from Al Olaya after the show"
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (event_id, trip_id)
);

-- Event interest — users interested / going to an event
CREATE TABLE IF NOT EXISTS event_interest (
  event_id   UUID REFERENCES events(id) ON DELETE CASCADE,
  user_id    UUID REFERENCES profiles(id) ON DELETE CASCADE,
  status     TEXT DEFAULT 'interested' CHECK (status IN ('interested', 'going')),
  needs_ride BOOLEAN DEFAULT true,            -- wants to find a ride
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (event_id, user_id)
);

-- --------------------------------------------------------------------------
-- TRIGGERS: member_count & ride_count auto-update
-- --------------------------------------------------------------------------

-- Community member count
CREATE OR REPLACE FUNCTION update_community_member_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE communities SET member_count = member_count + 1, updated_at = now()
    WHERE id = NEW.community_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE communities SET member_count = member_count - 1, updated_at = now()
    WHERE id = OLD.community_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_community_member_count
AFTER INSERT OR DELETE ON community_members
FOR EACH ROW EXECUTE FUNCTION update_community_member_count();

-- Event ride count
CREATE OR REPLACE FUNCTION update_event_ride_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE events SET ride_count = ride_count + 1, updated_at = now()
    WHERE id = NEW.event_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE events SET ride_count = ride_count - 1, updated_at = now()
    WHERE id = OLD.event_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_event_ride_count
AFTER INSERT OR DELETE ON event_rides
FOR EACH ROW EXECUTE FUNCTION update_event_ride_count();

-- --------------------------------------------------------------------------
-- RLS POLICIES
-- --------------------------------------------------------------------------

ALTER TABLE communities ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_rides ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_rides ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_interest ENABLE ROW LEVEL SECURITY;

-- Communities: anyone authenticated can read; creator can update
CREATE POLICY "communities_select" ON communities FOR SELECT TO authenticated USING (true);
CREATE POLICY "communities_insert" ON communities FOR INSERT TO authenticated WITH CHECK (auth.uid() = creator_id);
CREATE POLICY "communities_update" ON communities FOR UPDATE TO authenticated USING (auth.uid() = creator_id);

-- Members: read all; insert/delete own membership
CREATE POLICY "members_select" ON community_members FOR SELECT TO authenticated USING (true);
CREATE POLICY "members_insert" ON community_members FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "members_delete" ON community_members FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- Community rides: members can read; poster can insert/delete
CREATE POLICY "community_rides_select" ON community_rides FOR SELECT TO authenticated USING (true);
CREATE POLICY "community_rides_insert" ON community_rides FOR INSERT TO authenticated WITH CHECK (auth.uid() = posted_by);
CREATE POLICY "community_rides_delete" ON community_rides FOR DELETE TO authenticated USING (auth.uid() = posted_by);

-- Events: anyone authenticated can read; creator can update
CREATE POLICY "events_select" ON events FOR SELECT TO authenticated USING (true);
CREATE POLICY "events_insert" ON events FOR INSERT TO authenticated WITH CHECK (auth.uid() = created_by);
CREATE POLICY "events_update" ON events FOR UPDATE TO authenticated USING (auth.uid() = created_by);

-- Event rides: anyone can read; poster can insert/delete
CREATE POLICY "event_rides_select" ON event_rides FOR SELECT TO authenticated USING (true);
CREATE POLICY "event_rides_insert" ON event_rides FOR INSERT TO authenticated WITH CHECK (auth.uid() = posted_by);
CREATE POLICY "event_rides_delete" ON event_rides FOR DELETE TO authenticated USING (auth.uid() = posted_by);

-- Event interest: read all; own insert/update/delete
CREATE POLICY "interest_select" ON event_interest FOR SELECT TO authenticated USING (true);
CREATE POLICY "interest_insert" ON event_interest FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "interest_update" ON event_interest FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "interest_delete" ON event_interest FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- --------------------------------------------------------------------------
-- INDEXES for performance
-- --------------------------------------------------------------------------

CREATE INDEX idx_communities_type ON communities(type);
CREATE INDEX idx_communities_location ON communities USING GIST(location);
CREATE INDEX idx_community_members_user ON community_members(user_id);
CREATE INDEX idx_community_rides_community ON community_rides(community_id);
CREATE INDEX idx_events_start ON events(start_time);
CREATE INDEX idx_events_category ON events(category);
CREATE INDEX idx_event_rides_event ON event_rides(event_id);
CREATE INDEX idx_event_interest_event ON event_interest(event_id);
CREATE INDEX idx_event_interest_user ON event_interest(user_id);
