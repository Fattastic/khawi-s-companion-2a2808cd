-- Rewrite RLS policies in public schema to use init-plan auth calls.
-- Transforms auth.uid()/auth.role() -> (select auth.uid())/(select auth.role()).

do $$
declare
  rec record;
  roles_sql text;
  create_sql text;
  new_qual text;
  new_with_check text;
begin
  for rec in
    select *
    from pg_policies
    where schemaname = 'public'
      and (
        coalesce(qual, '') like '%auth.uid()%'
        or coalesce(qual, '') like '%auth.role()%'
        or coalesce(with_check, '') like '%auth.uid()%'
        or coalesce(with_check, '') like '%auth.role()%'
      )
  loop
    new_qual := rec.qual;
    new_with_check := rec.with_check;

    if new_qual is not null then
      new_qual := replace(new_qual, '(select auth.uid())', '__AUTH_UID__');
      new_qual := replace(new_qual, '(select auth.role())', '__AUTH_ROLE__');
      new_qual := replace(new_qual, 'auth.uid()', '(select auth.uid())');
      new_qual := replace(new_qual, 'auth.role()', '(select auth.role())');
      new_qual := replace(new_qual, '__AUTH_UID__', '(select auth.uid())');
      new_qual := replace(new_qual, '__AUTH_ROLE__', '(select auth.role())');
    end if;

    if new_with_check is not null then
      new_with_check := replace(new_with_check, '(select auth.uid())', '__AUTH_UID__');
      new_with_check := replace(new_with_check, '(select auth.role())', '__AUTH_ROLE__');
      new_with_check := replace(new_with_check, 'auth.uid()', '(select auth.uid())');
      new_with_check := replace(new_with_check, 'auth.role()', '(select auth.role())');
      new_with_check := replace(new_with_check, '__AUTH_UID__', '(select auth.uid())');
      new_with_check := replace(new_with_check, '__AUTH_ROLE__', '(select auth.role())');
    end if;

    roles_sql := array_to_string(
      array(
        select case when r = 'public' then 'public' else quote_ident(r) end
        from unnest(rec.roles) as r
      ),
      ', '
    );

    execute format(
      'drop policy if exists %I on %I.%I',
      rec.policyname,
      rec.schemaname,
      rec.tablename
    );

    create_sql := format(
      'create policy %I on %I.%I as %s for %s to %s',
      rec.policyname,
      rec.schemaname,
      rec.tablename,
      rec.permissive,
      rec.cmd,
      roles_sql
    );

    if new_qual is not null then
      create_sql := create_sql || format(' using (%s)', new_qual);
    end if;

    if new_with_check is not null then
      create_sql := create_sql || format(' with check (%s)', new_with_check);
    end if;

    execute create_sql;
  end loop;
end $$;
