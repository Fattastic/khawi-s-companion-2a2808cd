-- Staging Reset Script
-- WARNING: This deletes data! Run ONLY in Staging/Test environments.

-- Delete Test Trips
DELETE FROM public.trips WHERE id LIKE 'test_%';

-- Delete Test Profiles
DELETE FROM public.profiles WHERE id LIKE 'test_%';

-- Delete specific test rewards (optional, usually catalog is static)
-- DELETE FROM public.rewards WHERE id LIKE 'reward_%'; 

-- Reset other related tables if cascading delete is not enabled
-- DELETE FROM public.xp_history WHERE user_id LIKE 'test_%';
-- DELETE FROM public.trust_signals WHERE user_id LIKE 'test_%';
