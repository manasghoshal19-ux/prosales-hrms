-- PROSALES HRMS: read-only attendance backend preflight
-- Run in Supabase SQL Editor. This script does not change data or permissions.
select table_name from information_schema.tables where table_schema='public' and table_name in ('employees','office_attendance','attendance_requests','leave_requests') order by table_name;
select table_name,column_name,data_type from information_schema.columns where table_schema='public' and table_name in ('office_attendance','attendance_requests') order by table_name,ordinal_position;
select routine_name,security_type from information_schema.routines where routine_schema='public' and (routine_name ilike '%attendance%' or routine_name ilike '%office%' or routine_name ilike '%remote%') order by routine_name;
select tablename,policyname,cmd,roles,qual,with_check from pg_policies where schemaname='public' and tablename in ('office_attendance','attendance_requests') order by tablename,policyname;
select tablename,rowsecurity from pg_tables where schemaname='public' and tablename in ('office_attendance','attendance_requests');
