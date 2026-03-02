-- 022_profiles_insert_policy.sql
-- Fix: allow authenticated users to create their own profile row.
-- This is required because the app uses upsert() into public.profiles on login/role selection,
-- and some users may not yet have a profile row (e.g., legacy accounts).

alter table public.profiles enable row level security;

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
on public.profiles
for insert
with check (auth.uid() = id);
