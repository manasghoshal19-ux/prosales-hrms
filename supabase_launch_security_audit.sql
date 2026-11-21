-- PROSALES HRMS launch readiness: READ-ONLY Supabase audit.
-- Run in Supabase SQL Editor. No rows, policies or functions are changed.
-- Confirm 100 metre office radius from the implementation of the GPS functions;
-- the website's displayed radius is not proof of server enforcement.

-- 1. Attendance/leave tables and RLS status.
select t.tablename, t.rowsecurity
from pg_tables t
where t.schemaname='public'
  and t.tablename in ('employees','office_attendance','attendance_requests','leave_requests')
order by t.tablename;

-- 2. Relevant security policies (review employee isolation and approver privileges).
select tablename, policyname, cmd, roles, qual, with_check
from pg_policies
where schemaname='public'
  and tablename in ('employees','office_attendance','attendance_requests','leave_requests')
order by tablename, policyname;

-- 3. RPC presence, authorization mode and source for manual security review.
-- Review SECURITY DEFINER functions carefully and verify caller checks.
select p.proname as function_name,
       pg_get_function_identity_arguments(p.oid) as arguments,
       case when p.prosecdef then 'SECURITY DEFINER' else 'SECURITY INVOKER' end as security_mode,
       pg_get_functiondef(p.oid) as definition
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public'
  and p.proname in (
    'verify_office_gps','office_check_in','office_check_out',
    'review_attendance_request','approval_review_leave','can_approve_requests'
  )
order by p.proname;

-- 4. Explicitly inspect EXECUTE permissions for public/anon/authenticated.
select p.proname as function_name,
       has_function_privilege('public',p.oid,'EXECUTE') as public_execute,
       has_function_privilege('anon',p.oid,'EXECUTE') as anon_execute,
       has_function_privilege('authenticated',p.oid,'EXECUTE') as authenticated_execute
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public'
  and p.proname in (
    'verify_office_gps','office_check_in','office_check_out',
    'review_attendance_request','approval_review_leave','can_approve_requests'
  )
order by p.proname;

-- 5. Required columns and types for approval and attendance workflows.
select table_name,column_name,data_type
from information_schema.columns
where table_schema='public'
  and table_name in ('office_attendance','attendance_requests','leave_requests')
order by table_name,ordinal_position;
