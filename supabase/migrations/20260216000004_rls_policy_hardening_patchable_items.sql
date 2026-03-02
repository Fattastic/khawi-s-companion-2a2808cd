-- Resolve patchable security findings in public schema.

-- 1) Enable RLS on edge_rate_limits (owner-controlled app table)
alter table if exists public.edge_rate_limits enable row level security;

-- 2) Remove permissive always-true policies and keep constrained ones.
-- match_scores
DROP POLICY IF EXISTS "edge functions update match scores" ON public.match_scores;
DROP POLICY IF EXISTS "edge functions write match scores" ON public.match_scores;
DROP POLICY IF EXISTS "read own match scores" ON public.match_scores;

-- notifications
DROP POLICY IF EXISTS "System can insert notifications" ON public.notifications;
create policy notifications_insert_service_or_self
on public.notifications
for insert
with check (
  auth.role() = 'service_role'
  or auth.uid() = user_id
);
