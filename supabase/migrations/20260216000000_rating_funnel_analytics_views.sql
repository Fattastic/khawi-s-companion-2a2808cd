-- Rating telemetry analytics surfaces
-- Covers target resolution/missing and submission outcomes.

create index if not exists event_log_rating_telemetry_idx
on public.event_log (created_at desc, event_type)
where event_type in (
  'rating_target_selected',
  'rating_target_stale_cleared',
  'rating_target_reselect_clicked',
  'rating_target_resolved',
  'rating_target_missing',
  'rating_submitted',
  'rating_submission_failed'
);

create index if not exists event_log_rating_trip_idx
on public.event_log (entity_id, created_at desc)
where entity_type = 'trip'
  and event_type in (
    'rating_target_resolved',
    'rating_target_missing',
    'rating_submitted',
    'rating_submission_failed'
  );

create or replace view public.rating_funnel_daily as
with base as (
  select
    date_trunc('day', created_at)::date as day,
    event_type,
    entity_id as trip_id,
    payload
  from public.event_log
  where event_type in (
    'rating_target_resolved',
    'rating_target_missing',
    'rating_submitted',
    'rating_submission_failed'
  )
)
select
  day,
  count(*) filter (
    where event_type = 'rating_target_resolved'
      and (payload->>'resolution_source') = 'selected'
  ) as resolved_selected,
  count(*) filter (
    where event_type = 'rating_target_resolved'
      and (payload->>'resolution_source') = 'fallback'
  ) as resolved_fallback,
  count(*) filter (
    where event_type = 'rating_target_resolved'
      and (payload->>'resolution_source') = 'passenger_direct'
  ) as resolved_passenger_direct,
  count(*) filter (where event_type = 'rating_target_missing') as target_missing,
  count(*) filter (where event_type = 'rating_submitted') as submitted,
  count(*) filter (where event_type = 'rating_submission_failed') as submission_failed,
  case
    when count(*) filter (where event_type = 'rating_target_resolved') = 0 then 0
    else round(
      (count(*) filter (where event_type = 'rating_submitted')::numeric
      / nullif(count(*) filter (where event_type = 'rating_target_resolved'), 0)::numeric) * 100,
      2
    )
  end as submit_rate_pct,
  case
    when count(*) filter (where event_type in ('rating_submitted', 'rating_submission_failed')) = 0 then 0
    else round(
      (count(*) filter (where event_type = 'rating_submission_failed')::numeric
      / nullif(count(*) filter (where event_type in ('rating_submitted', 'rating_submission_failed')), 0)::numeric) * 100,
      2
    )
  end as submission_fail_rate_pct
from base
group by day
order by day desc;

create or replace view public.rating_funnel_by_role_daily as
with norm as (
  select
    date_trunc('day', created_at)::date as day,
    event_type,
    payload,
    case
      when event_type = 'rating_target_resolved' and (payload->>'resolution_source') = 'passenger_direct'
        then 'passenger'
      when (payload->>'source') in ('passenger_trip_completed')
        then 'passenger'
      when (payload->>'source') in ('end_trip_confirm', 'passenger_list_open', 'passenger_list', 'stale_selection_snackbar')
        then 'driver'
      else 'unknown'
    end as role
  from public.event_log
  where event_type in (
    'rating_target_resolved',
    'rating_target_missing',
    'rating_submitted',
    'rating_submission_failed'
  )
)
select
  day,
  role,
  count(*) filter (where event_type = 'rating_target_resolved') as targets_resolved,
  count(*) filter (where event_type = 'rating_target_missing') as targets_missing,
  count(*) filter (where event_type = 'rating_submitted') as submitted,
  count(*) filter (where event_type = 'rating_submission_failed') as submit_failed,
  case
    when count(*) filter (where event_type = 'rating_target_resolved') = 0 then 0
    else round(
      (count(*) filter (where event_type = 'rating_submitted')::numeric
      / nullif(count(*) filter (where event_type = 'rating_target_resolved'), 0)::numeric) * 100,
      2
    )
  end as submit_rate_pct
from norm
group by day, role
order by day desc, role asc;

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

grant select on public.rating_funnel_daily to authenticated;
grant select on public.rating_funnel_by_role_daily to authenticated;
grant execute on function public.rating_funnel_summary(integer) to authenticated;
