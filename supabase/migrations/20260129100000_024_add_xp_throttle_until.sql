-- Migration: Add xp_throttle_until column to profiles
-- Required by: Profile.dart model, detect_fraud Edge Function

do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='profiles' and column_name='xp_throttle_until'
  ) then
    alter table public.profiles add column xp_throttle_until timestamptz;
  end if;
end$$;

-- Add comment for documentation
comment on column public.profiles.xp_throttle_until is 'Timestamp until which XP earning is throttled due to fraud detection';
