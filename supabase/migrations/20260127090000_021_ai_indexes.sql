-- Safe index creation for AI performance
begin;

-- Trust lookup speed
create index if not exists trust_profiles_user_idx
on public.trust_profiles (user_id);

-- Area incentive lookup speed (latest first)
-- Schema uses 'area_key'
do $$
begin
	if to_regclass('public.area_incentives') is not null
		 and exists (
			 select 1
			 from information_schema.columns
			 where table_schema = 'public'
				 and table_name = 'area_incentives'
				 and column_name = 'area_key'
		 )
		 and exists (
			 select 1
			 from information_schema.columns
			 where table_schema = 'public'
				 and table_name = 'area_incentives'
				 and column_name = 'time_bucket'
		 )
		 and exists (
			 select 1
			 from information_schema.columns
			 where table_schema = 'public'
				 and table_name = 'area_incentives'
				 and column_name = 'computed_at'
		 )
	then
		create index if not exists area_incentives_lookup_idx
		on public.area_incentives (area_key, time_bucket, computed_at desc);
	end if;
end$$;

-- Fraud severity filtering
create index if not exists fraud_flags_severity_idx
on public.fraud_flags (severity, created_at desc);

commit;
