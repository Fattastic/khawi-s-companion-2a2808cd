# Supabase Remaining Console Actions (Non-SQL)

Project: `oxcustajfzeqibnkjthp`

This runbook covers the **last remaining advisor findings** that cannot be fully resolved via SQL migrations with the current DB role.

---

## 1) Auth: Enable leaked password protection

### Why
Advisor warning:
- `auth_leaked_password_protection`

### Steps (Supabase Dashboard)
1. Open Supabase project dashboard.
2. Go to **Authentication** → **Providers / Settings** (Auth configuration area).
3. Locate **Password security**.
4. Enable **Leaked password protection**.
5. Save changes.

### Verify
- Re-run Security Advisors (Dashboard or MCP).
- Expected: `auth_leaked_password_protection` warning disappears.

Reference:
- https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection

---

## 2) PostGIS-related findings (`spatial_ref_sys` + extension schema)

### Why these remain
Current findings:
- `rls_disabled_in_public` for `public.spatial_ref_sys`
- `extension_in_public` for `postgis`

`spatial_ref_sys` is a PostGIS-owned table in `public`. In this environment:
- The SQL role cannot alter ownership-controlled extension objects.
- `ALTER EXTENSION postgis SET SCHEMA ...` is not supported by PostGIS.

So this is **platform/extension-level technical debt**, not app-migration debt.

### Recommended handling
Choose one:

#### Option A (Pragmatic, recommended)
- Accept/ignore these two findings as extension-scoped exceptions.
- Document exception in your security review notes.

#### Option B (Advanced migration path)
- Provision a fresh environment where PostGIS is installed into a dedicated extension schema from the start (if supported by your provisioning workflow/version).
- Migrate app schema/data to that environment.

### Verify current state
Use SQL to confirm the source of the warning:

```sql
select e.extname, n.nspname as extension_schema
from pg_extension e
join pg_namespace n on n.oid = e.extnamespace
where e.extname = 'postgis';

select n.nspname as schemaname, c.relname as tablename, c.relrowsecurity
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname='public' and c.relname='spatial_ref_sys' and c.relkind='r';
```

---

## 3) Post-change validation checklist

After console changes:
1. Run Security Advisors.
2. Run Performance Advisors.
3. Confirm app telemetry views still query correctly:

```sql
select * from public.rating_funnel_daily order by day desc limit 5;
select * from public.rating_funnel_summary(30);
```

4. Confirm core app still passes static checks/tests in repo:
- `flutter analyze`
- `test/navigation_smoke_test.dart`

---

## Status Summary

All patchable DB findings were already addressed via migrations.
Remaining items are platform/extension/Auth-console scope.
