-- Add explicit non-permissive policies for edge_rate_limits.
-- Service-role-only access (service role bypasses RLS, but policies satisfy linter and document intent).

drop policy if exists edge_rate_limits_select_service on public.edge_rate_limits;
drop policy if exists edge_rate_limits_insert_service on public.edge_rate_limits;
drop policy if exists edge_rate_limits_update_service on public.edge_rate_limits;

create policy edge_rate_limits_select_service
on public.edge_rate_limits
for select
using (auth.role() = 'service_role');

create policy edge_rate_limits_insert_service
on public.edge_rate_limits
for insert
with check (auth.role() = 'service_role');

create policy edge_rate_limits_update_service
on public.edge_rate_limits
for update
using (auth.role() = 'service_role')
with check (auth.role() = 'service_role');
