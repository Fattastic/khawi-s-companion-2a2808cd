-- XP Rewards Economy & Trust Tiers Schema
-- Additive migration: does NOT modify existing tables except adding trust_tier column

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. XP BUCKETS (Internal categorization)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS xp_buckets (
    user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    contribution_xp INT NOT NULL DEFAULT 0,
    safety_xp INT NOT NULL DEFAULT 0,
    community_xp INT NOT NULL DEFAULT 0,
    learning_xp INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE xp_buckets IS 'Internal XP categorization by source type. Users see total only.';
COMMENT ON COLUMN xp_buckets.contribution_xp IS 'XP from driving, carpooling, reliability';
COMMENT ON COLUMN xp_buckets.safety_xp IS 'XP from clean trips, kids safety, behavior';
COMMENT ON COLUMN xp_buckets.community_xp IS 'XP from helping new users, streaks';
COMMENT ON COLUMN xp_buckets.learning_xp IS 'XP from completing onboarding, safety tips';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. REWARD CATALOG
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TYPE reward_category AS ENUM ('symbolic', 'functional', 'partner');
CREATE TYPE trust_tier AS ENUM ('bronze', 'silver', 'gold', 'platinum');

CREATE TABLE IF NOT EXISTS reward_catalog (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category reward_category NOT NULL,
    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,
    description_en TEXT,
    description_ar TEXT,
    xp_cost INT NOT NULL CHECK (xp_cost > 0),
    trust_tier_required trust_tier NOT NULL DEFAULT 'bronze',
    subscription_required BOOLEAN NOT NULL DEFAULT FALSE,
    weekly_cap INT DEFAULT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE reward_catalog IS 'Available rewards for XP redemption';
COMMENT ON COLUMN reward_catalog.subscription_required IS 'Partner rewards require Khawi+';
COMMENT ON COLUMN reward_catalog.weekly_cap IS 'Max redemptions per user per week (anti-abuse)';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. BADGES
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TYPE badge_type AS ENUM ('behavior', 'contribution', 'family');

CREATE TABLE IF NOT EXISTS badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT UNIQUE NOT NULL,
    type badge_type NOT NULL,
    name_en TEXT NOT NULL,
    name_ar TEXT NOT NULL,
    description_en TEXT,
    description_ar TEXT,
    criteria JSONB NOT NULL DEFAULT '{}',
    is_visible BOOLEAN NOT NULL DEFAULT TRUE,
    icon_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE badges IS 'Badge definitions with earning criteria';
COMMENT ON COLUMN badges.is_visible IS 'Some badges are hidden for safety (e.g., kids-related)';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. USER BADGES
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS user_badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    badge_id UUID NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
    earned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    revoked_at TIMESTAMPTZ,
    UNIQUE(user_id, badge_id)
);

COMMENT ON TABLE user_badges IS 'Badges earned by users (can be revoked)';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. ADD TRUST TIER TO EXISTING TRUST PROFILES (ADDITIVE)
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE trust_profiles 
ADD COLUMN IF NOT EXISTS trust_tier trust_tier NOT NULL DEFAULT 'bronze';

COMMENT ON COLUMN trust_profiles.trust_tier IS 'Computed tier based on safety metrics';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 6. REDEMPTION TRACKING (for caps)
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS reward_redemption_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    reward_id UUID NOT NULL REFERENCES reward_catalog(id),
    xp_spent INT NOT NULL,
    redeemed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_redemption_user_week 
ON reward_redemption_log(user_id, redeemed_at);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 7. TRIGGERS
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION update_xp_buckets_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_xp_buckets_updated
BEFORE UPDATE ON xp_buckets
FOR EACH ROW EXECUTE FUNCTION update_xp_buckets_timestamp();

CREATE TRIGGER trg_reward_catalog_updated
BEFORE UPDATE ON reward_catalog
FOR EACH ROW EXECUTE FUNCTION update_xp_buckets_timestamp();

-- ═══════════════════════════════════════════════════════════════════════════════
-- 8. ROW LEVEL SECURITY
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE xp_buckets ENABLE ROW LEVEL SECURITY;
ALTER TABLE reward_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE reward_redemption_log ENABLE ROW LEVEL SECURITY;

-- XP Buckets: users can only see their own
CREATE POLICY xp_buckets_select ON xp_buckets
    FOR SELECT USING (auth.uid() = user_id);

-- Reward catalog: public read
CREATE POLICY reward_catalog_select ON reward_catalog
    FOR SELECT USING (is_active = TRUE);

-- Badges: public read for visible badges
CREATE POLICY badges_select ON badges
    FOR SELECT USING (is_visible = TRUE);

-- User badges: users can see their own
CREATE POLICY user_badges_select ON user_badges
    FOR SELECT USING (auth.uid() = user_id);

-- Redemption log: users can see their own
CREATE POLICY redemption_log_select ON reward_redemption_log
    FOR SELECT USING (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 9. SEED DATA: Initial Badges
-- ═══════════════════════════════════════════════════════════════════════════════

INSERT INTO badges (key, type, name_en, name_ar, description_en, description_ar, criteria, is_visible) VALUES
-- Behavior badges
('safe_driver', 'behavior', 'Safe Driver', 'سائق آمن', '10+ trips with zero safety incidents', '+10 رحلات بدون حوادث سلامة', '{"min_trips": 10, "max_safety_incidents": 0}', TRUE),
('calm_driver', 'behavior', 'Calm Driver', 'سائق هادئ', 'AI behavior score ≥ 85', 'تقييم السلوك الذكي ≥ 85', '{"min_behavior_score": 85}', TRUE),
('child_friendly', 'behavior', 'Child-Friendly', 'صديق للأطفال', '5+ kids trips with 5★ average', '+5 رحلات أطفال بتقييم 5 نجوم', '{"min_kids_trips": 5, "min_rating": 5}', TRUE),
('always_on_time', 'behavior', 'Always On Time', 'دائماً في الموعد', '95% on-time arrival rate', 'معدل وصول في الوقت 95%', '{"min_ontime_rate": 0.95}', TRUE),

-- Contribution badges
('trips_10', 'contribution', '10 Trips', '10 رحلات', 'Completed 10 trips', 'أكملت 10 رحلات', '{"min_trips": 10}', TRUE),
('trips_50', 'contribution', '50 Trips', '50 رحلة', 'Completed 50 trips', 'أكملت 50 رحلة', '{"min_trips": 50}', TRUE),
('community_helper', 'contribution', 'Community Helper', 'مساعد المجتمع', 'Referred 3+ new users', 'أحلت 3 مستخدمين جدد', '{"min_referrals": 3}', TRUE),
('peak_hour_hero', 'contribution', 'Peak-Hour Hero', 'بطل ساعات الذروة', '20+ peak-hour trips', '+20 رحلة في ساعات الذروة', '{"min_peak_trips": 20}', TRUE),

-- Family badges (some hidden for safety)
('trusted_family_driver', 'family', 'Trusted Family Driver', 'سائق عائلي موثوق', 'Gold tier + parent-verified', 'مستوى ذهبي + تحقق ولي أمر', '{"min_tier": "gold", "parent_verified": true}', TRUE),
('kids_approved', 'family', 'Kids-Approved', 'معتمد للأطفال', 'Gold tier + 10 successful kids trips', 'مستوى ذهبي + 10 رحلات أطفال ناجحة', '{"min_tier": "gold", "min_kids_trips": 10}', FALSE),
('parent_verified', 'family', 'Parent-Verified', 'ولي أمر موثق', 'Nafath verified + parent role', 'تحقق بنفاذ + دور ولي أمر', '{"nafath_verified": true, "role": "parent"}', TRUE)
ON CONFLICT (key) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 10. SEED DATA: Initial Rewards
-- ═══════════════════════════════════════════════════════════════════════════════

INSERT INTO reward_catalog (category, name_en, name_ar, description_en, description_ar, xp_cost, trust_tier_required, subscription_required, weekly_cap) VALUES
-- Symbolic rewards (low XP)
('symbolic', 'Profile Highlight', 'إبراز الملف', 'Highlight your profile for 24 hours', 'إبراز ملفك لمدة 24 ساعة', 100, 'bronze', FALSE, 3),
('symbolic', 'Community Contributor', 'مساهم في المجتمع', 'Display contributor badge', 'عرض شارة المساهم', 200, 'bronze', FALSE, 1),
('symbolic', 'Gold Frame', 'إطار ذهبي', 'Gold profile frame', 'إطار ذهبي للملف', 500, 'silver', FALSE, 1),

-- Functional rewards (medium XP)
('functional', 'Priority Matching', 'أولوية المطابقة', 'Priority in ride matching for 1 week', 'أولوية في مطابقة الرحلات لأسبوع', 300, 'silver', FALSE, 1),
('functional', 'XP Boost Week', 'أسبوع تعزيز النقاط', '1.5x XP multiplier for 1 week', 'مضاعف نقاط 1.5x لأسبوع', 500, 'silver', FALSE, 1),
('functional', 'Advanced Scheduling', 'الجدولة المتقدمة', 'Access to advanced trip scheduling', 'الوصول للجدولة المتقدمة', 400, 'gold', FALSE, 1),

-- Partner rewards (high XP, requires Khawi+)
('partner', 'Coffee Voucher', 'قسيمة قهوة', 'Free coffee at partner cafes', 'قهوة مجانية في المقاهي الشريكة', 1000, 'gold', TRUE, 2),
('partner', 'Fuel Discount', 'خصم وقود', '10% fuel discount voucher', 'قسيمة خصم وقود 10%', 1500, 'gold', TRUE, 1),
('partner', 'Car Wash', 'غسيل سيارة', 'Free car wash at partners', 'غسيل سيارة مجاني عند الشركاء', 800, 'silver', TRUE, 2)
ON CONFLICT DO NOTHING;
