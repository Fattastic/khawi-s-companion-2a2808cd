-- Security + performance hardening

-- 1) Fix mutable search_path on high-impact public functions.
alter function public.me_profile() set search_path = public;
alter function public.is_run_driver_with_grant(uuid) set search_path = public;
alter function public.is_trip_driver(uuid) set search_path = public;
alter function public.complete_trip_v2(uuid) set search_path = public;
alter function public.update_junior_run_status(uuid, text, double precision, double precision, jsonb) set search_path = public;
alter function public.is_trip_participant(uuid) set search_path = public;
alter function public.driver_accept_request(uuid) set search_path = public;
alter function public.handle_new_user() set search_path = public;
alter function public.revoke_driver_grant(uuid) set search_path = public;

-- 2) Remove remaining security-definer view finding.
alter view public.junior_run_latest_location set (security_invoker = true);

-- 3) Add missing foreign-key covering indexes for ratings table.
create index if not exists ratings_trip_id_idx on public.ratings (trip_id);
create index if not exists ratings_rater_id_idx on public.ratings (rater_id);
create index if not exists ratings_ratee_id_idx on public.ratings (ratee_id);
