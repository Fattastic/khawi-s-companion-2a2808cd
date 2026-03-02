create or replace function public.get_global_xp_leaderboard(p_limit integer default 20)
returns table (
  user_id uuid,
  display_name text,
  total_xp integer,
  trust_badge text
)
language sql
stable
security definer
set search_path = public
as $$
  select
    p.id as user_id,
    case
      when p.full_name is null or btrim(p.full_name) = '' then 'Khawi User'
      else split_part(btrim(p.full_name), ' ', 1)
    end as display_name,
    coalesce(p.total_xp, 0)::integer as total_xp,
    tp.trust_badge
  from public.profiles p
  left join public.trust_profiles tp on tp.user_id = p.id
  where coalesce(p.total_xp, 0) > 0
  order by coalesce(p.total_xp, 0) desc, p.updated_at desc nulls last
  limit greatest(1, least(coalesce(p_limit, 20), 100));
$$;

grant execute on function public.get_global_xp_leaderboard(integer) to authenticated;
