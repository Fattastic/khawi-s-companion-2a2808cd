-- Drop exact duplicate indexes (same table + same key order).
-- Keep canonical name area_incentives_computed_idx.

drop index if exists public.area_incentives_time_idx;
