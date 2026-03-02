-- Staging Seeds for QA Console Testing
-- Usage: Execute in Supabase SQL Editor or via psql

-- 1. Reset Staging Data (Optional, ensuring clean slate for specific test IDs)
-- DELETE FROM public.trips WHERE id LIKE 'test_%';
-- DELETE FROM public.profiles WHERE id LIKE 'test_%';

-- 2. Insert Test Users (Profiles)
-- Note: In real Supabase, auth.users entry is needed for login. 
-- These profiles are for 'simulation' or linking to existing test accounts.
-- We assume these IDs correspond to test accounts or are used for simulated lookups.

INSERT INTO public.profiles (id, full_name, role, is_verified, is_premium, total_xp, redeemable_xp, avatar_url)
VALUES
    ('test_passenger_std', 'Test Passenger (Standard)', 'passenger', true, false, 500, 200, 'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix'),
    ('test_passenger_prem', 'Test Passenger (Premium)', 'passenger', true, true, 5000, 4500, 'https://api.dicebear.com/7.x/avataaars/svg?seed=Aneka'),
    ('test_driver_verified', 'Test Driver (Verified)', 'driver', true, false, 8000, 1000, 'https://api.dicebear.com/7.x/avataaars/svg?seed=Bob'),
    ('test_driver_unverified', 'Test Driver (Unverified)', 'driver', false, false, 0, 0, null),
    ('test_junior_parent', 'Test Parent', 'parent', true, true, 12000, 500, 'https://api.dicebear.com/7.x/avataaars/svg?seed=Maria'),
    ('test_junior_child', 'Test Junior', 'junior', false, false, 300, 300, 'https://api.dicebear.com/7.x/avataaars/svg?seed=Timmy')
ON CONFLICT (id) DO UPDATE 
SET full_name = EXCLUDED.full_name, 
    role = EXCLUDED.role, 
    is_verified = EXCLUDED.is_verified, 
    is_premium = EXCLUDED.is_premium, 
    total_xp = EXCLUDED.total_xp, 
    redeemable_xp = EXCLUDED.redeemable_xp;

-- 3. Insert Rewards Catalog
INSERT INTO public.rewards (id, title, description, cost_xp, category, is_active)
VALUES
    ('reward_coffee_1', 'Free Coffee', 'Redeem for a free coffee at participating cafes.', 500, 'food_beverage', true),
    ('reward_discount_ride', '10% Off Next Ride', 'Get 10% discount on your next trip.', 1000, 'transport', true),
    ('reward_premium_month', '1 Month Premium', 'Upgrade to Premium status for 30 days.', 5000, 'subscription', true),
    ('reward_charity_donation', 'Donate to Charity', 'We donate 10 SAR to local charity on your behalf.', 2000, 'charity', true)
ON CONFLICT (id) DO NOTHING;

-- 4. Insert Trust Signals
-- Assuming a table 'trust_signals' or similar exists linked to profiles
-- INSERT INTO public.trust_signals (user_id, signal_type, score_impact, description) ... 
-- (Schema might vary, adjusting to hypothetical schema based on TrustPanel)

-- 5. Insert Active/Past Trips (Test Data)
INSERT INTO public.trips (id, passenger_id, driver_id, status, origin_lat, origin_lng, dest_lat, dest_lng, estimated_fare, created_at, scheduled_at)
VALUES
    ('test_trip_active_1', 'test_passenger_std', 'test_driver_verified', 'in_progress', 24.7136, 46.6753, 24.7236, 46.6853, 25.50, NOW(), NOW()),
    ('test_trip_completed_1', 'test_passenger_prem', 'test_driver_verified', 'completed', 24.7136, 46.6753, 24.8000, 46.7000, 45.00, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),
    ('test_trip_scheduled_1', 'test_junior_child', 'test_driver_verified', 'scheduled', 24.7136, 46.6753, 24.7500, 46.7200, 30.00, NOW(), NOW() + INTERVAL '2 hours')
ON CONFLICT (id) DO NOTHING;
