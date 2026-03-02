-- 20260221000000_junior_family_driver_invites.sql
-- Strengthens Khawi Junior family-driver security:
-- - Invitation metadata (name/phone/relation)
-- - Redemption audit (redeemed_by/redeemed_at)
-- - Invite-only confirmation payloads for app UX

alter table public.junior_invite_codes
  add column if not exists invited_driver_name text,
  add column if not exists invited_driver_phone text,
  add column if not exists invited_driver_relation text,
  add column if not exists redeemed_by uuid references public.profiles(id) on delete set null,
  add column if not exists redeemed_at timestamptz;

create index if not exists junior_invite_codes_redeemed_by_idx
  on public.junior_invite_codes(redeemed_by);

drop policy if exists trusted_write_parent on public.trusted_drivers;
drop policy if exists trusted_insert_via_invite_only on public.trusted_drivers;
create policy trusted_insert_via_invite_only
on public.trusted_drivers for insert
with check (false);

drop policy if exists invite_update_parent on public.junior_invite_codes;
create policy invite_update_parent
on public.junior_invite_codes for update
using (auth.uid() = parent_id)
with check (auth.uid() = parent_id);

drop function if exists public.create_junior_invite_code();
create or replace function public.create_junior_invite_code(
  p_invited_driver_name text default null,
  p_invited_driver_phone text default null,
  p_invited_driver_relation text default null,
  p_minutes_valid integer default 2880
)
returns public.junior_invite_codes
language plpgsql
security definer
set search_path = public
as $$
declare
  v_code text;
  v_res public.junior_invite_codes;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  loop
    v_code := upper(
      substring(md5(random()::text || clock_timestamp()::text) from 1 for 6)
    );
    begin
      insert into public.junior_invite_codes (
        code,
        parent_id,
        expires_at,
        invited_driver_name,
        invited_driver_phone,
        invited_driver_relation
      )
      values (
        v_code,
        auth.uid(),
        now() + make_interval(mins => greatest(p_minutes_valid, 1)),
        nullif(trim(p_invited_driver_name), ''),
        nullif(trim(p_invited_driver_phone), ''),
        nullif(trim(p_invited_driver_relation), '')
      )
      returning * into v_res;
      exit;
    exception
      when unique_violation then
        -- Retry on random-code collision.
    end;
  end loop;

  return v_res;
end;
$$;

drop function if exists public.redeem_junior_invite_code(text);
create or replace function public.redeem_junior_invite_code(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_invite public.junior_invite_codes;
  v_trusted public.trusted_drivers;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  select *
  into v_invite
  from public.junior_invite_codes
  where code = upper(trim(p_code))
  for update;

  if not found then
    return jsonb_build_object('success', false, 'reason', 'not_found');
  end if;

  if v_invite.parent_id = auth.uid() then
    raise exception 'Cannot invite self';
  end if;

  if v_invite.is_used then
    return jsonb_build_object('success', false, 'reason', 'already_used');
  end if;

  if v_invite.expires_at < now() then
    return jsonb_build_object('success', false, 'reason', 'expired');
  end if;

  insert into public.trusted_drivers (parent_id, driver_id, label, is_active)
  values (
    v_invite.parent_id,
    auth.uid(),
    coalesce(nullif(v_invite.invited_driver_relation, ''), 'Invited Driver'),
    true
  )
  on conflict (parent_id, driver_id)
  do update set
    is_active = true,
    label = coalesce(excluded.label, public.trusted_drivers.label)
  returning * into v_trusted;

  update public.junior_invite_codes
  set is_used = true,
      redeemed_by = auth.uid(),
      redeemed_at = now()
  where id = v_invite.id;

  return jsonb_build_object(
    'success', true,
    'invite_id', v_invite.id,
    'parent_id', v_invite.parent_id,
    'driver_id', auth.uid(),
    'trusted_driver_id', v_trusted.id
  );
end;
$$;

grant execute on function public.create_junior_invite_code(text, text, text, integer) to authenticated;
grant execute on function public.redeem_junior_invite_code(text) to authenticated;
