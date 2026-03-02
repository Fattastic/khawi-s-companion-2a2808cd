-- Harden analytics objects to satisfy security lints.

alter view public.rating_funnel_daily set (security_invoker = true);
alter view public.rating_funnel_by_role_daily set (security_invoker = true);

create or replace function public.rating_funnel_summary(p_days integer default 30)
returns table (
  role text,
  targets_resolved bigint,
  targets_missing bigint,
  submitted bigint,
  submit_failed bigint,
  submit_rate_pct numeric,
  submit_fail_rate_pct numeric
)
language sql
stable
set search_path = public
as $$
  with scoped as (
    select *
    from public.rating_funnel_by_role_daily
    where day >= (current_date - greatest(p_days, 1))
  ),
  agg as (
    select
      role,
      sum(targets_resolved) as targets_resolved,
      sum(targets_missing) as targets_missing,
      sum(submitted) as submitted,
      sum(submit_failed) as submit_failed
    from scoped
    group by role
  )
  select
    role,
    targets_resolved,
    targets_missing,
    submitted,
    submit_failed,
    case
      when targets_resolved = 0 then 0
      else round((submitted::numeric / nullif(targets_resolved, 0)::numeric) * 100, 2)
    end as submit_rate_pct,
    case
      when (submitted + submit_failed) = 0 then 0
      else round((submit_failed::numeric / nullif((submitted + submit_failed), 0)::numeric) * 100, 2)
    end as submit_fail_rate_pct
  from agg
  order by role;
$$;
