-- 023_profiles_rls_policies.sql
-- Fix: allow authenticated users to read/update/insert their own profile row.
-- Required because the app uses upsert() into public.profiles (e.g., verification, role selection).

alter table public.profiles enable row level security;

-- Read own profile
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
on public.profiles
for select
using (auth.uid() = id);

-- Create own profile (used by upsert when profile row is missing)
drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
on public.profiles
for insert
with check (auth.uid() = id);

-- Update own profile (used by upsert when profile row exists)
drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
on public.profiles
for update
using (auth.uid() = id)
with check (auth.uid() = id);
