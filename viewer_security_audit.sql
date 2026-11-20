-- Prosales HRMS: read-only access audit (does not change data or permissions)
select tablename, policyname, cmd,
       coalesce(qual,'') as using_rule,
       coalesce(with_check,'') as check_rule
from pg_policies
where schemaname='public'
  and tablename in ('employees','office_attendance','leave_requests','attendance_requests','daily_performance','monthly_performance')
order by tablename,cmd,policyname;

select routine_name,security_type
from information_schema.routines
where routine_schema='public' and routine_name like 'prosales_viewer_%'
order by routine_name;

select p.proname as function_name,
       has_function_privilege('anon',p.oid,'EXECUTE') as anonymous_can_execute,
       has_function_privilege('authenticated',p.oid,'EXECUTE') as signed_in_can_execute
from pg_proc p join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public' and p.proname like 'prosales_viewer_%'
order by p.proname;
