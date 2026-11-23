-- PROSALES HRMS: salary privacy READ-ONLY audit.
-- Requirement: HR and the specifically authorized Suprabhat account may view all salaries.
-- Every other employee may view only their own salary.
-- Run in Supabase SQL Editor; inspect results before making any permission changes.
-- IMPORTANT: A hidden UI element is NOT a security control.

-- 1. Review roles and user IDs; verify Suprabhat is the ONLY intended viewer.
select id, employee_code, full_name, role
from public.employees
order by role, full_name;

-- 2. RLS state: employees must have RLS enabled.
select n.nspname as schema_name, c.relname as table_name,
       c.relrowsecurity as rls_enabled, c.relforcerowsecurity as rls_forced
from pg_class c join pg_namespace n on n.oid=c.relnamespace
where n.nspname='public' and c.relname='employees';

-- 3. All SELECT policies on employees (and any other policies that might grant reads).
select schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
from pg_policies where schemaname='public' and tablename='employees'
order by policyname;

-- 4. Direct table and column grants (RLS must still be evaluated separately).
select grantee, privilege_type
from information_schema.role_table_grants
where table_schema='public' and table_name='employees'
order by grantee, privilege_type;
select grantee, column_name, privilege_type
from information_schema.column_privileges
where table_schema='public' and table_name='employees'
  and column_name='gross_salary'
order by grantee;

-- 5. Security-definer salary RPC: inspect source and grants.
-- This function currently checks role='viewer', not a specific user identity.
-- If any other account receives the viewer role, it may see team salaries.
select p.proname, pg_get_function_identity_arguments(p.oid) as arguments,
       p.prosecdef as security_definer,
       pg_get_functiondef(p.oid) as definition,
       p.proacl as acl
from pg_proc p join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public'
  and (p.proname ilike '%salary%' or p.proname='prosales_viewer_salary')
order by p.proname;

-- 6. Inspect other functions that might return employee salary data.
select p.proname, pg_get_function_identity_arguments(p.oid) as arguments,
       p.prosecdef as security_definer,
       pg_get_functiondef(p.oid) as definition
from pg_proc p join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public'
  and pg_get_functiondef(p.oid) ilike '%gross_salary%'
order by p.proname;

-- DO NOT conclude privacy is enforced from this audit alone.
-- Confirm as a normal employee account that querying another employee's
-- gross_salary is denied and that prosales_viewer_salary cannot be called
-- to retrieve other employees' salaries. Test HR and Suprabhat separately.
