-- PROSALES HRMS — Suprabhat salary viewer: identity-bound deployment template
-- IMPORTANT: This is NOT deployed. User supplied the Suprabhat Auth UID; confirm
-- the employee profile is linked to this UID and the role is viewer before running.
-- This migration fails closed until an operator supplies the verified auth user UUID.
-- HR access and each employee's own salary access are managed by other RLS policies
-- and must be separately audited; this function does not grant either.
begin;
do $$
declare
  suprabhat_auth_uid uuid := 'eafbe941-b4c2-441f-bd00-c86459201e70'; -- Supabase Authentication > Users, Suprabhat account
  verified_name text;
  verified_role text;
begin
  if suprabhat_auth_uid is null then
    raise exception 'STOP: verify Suprabhat auth.users.id and set suprabhat_auth_uid before deployment';
  end if;
  select full_name,role into verified_name,verified_role
  from public.employees where id=suprabhat_auth_uid;
  if verified_name is distinct from 'Suprabhat Chakraborty' or verified_role is distinct from 'viewer' then
    raise exception 'STOP: UUID does not match the expected Suprabhat viewer account';
  end if;
  execute format($sql$
    create or replace function public.prosales_viewer_salary()
    returns table(full_name text, employee_code text, designation text, gross_salary numeric)
    language sql stable security definer set search_path = ''
    as $fn$
      select e.full_name::text,e.employee_code::text,e.designation::text,e.gross_salary::numeric
      from public.employees e
      where e.role='employee'
      and auth.uid() = %L::uuid
      and exists (
        select 1 from public.employees me
        where me.id=auth.uid() and me.role='viewer'
      )
      order by e.full_name
    $fn$;
  $sql$, suprabhat_auth_uid);
end $$;
revoke all on function public.prosales_viewer_salary() from public, anon;
grant execute on function public.prosales_viewer_salary() to authenticated;
commit;

-- AFTER deployment: verify Suprabhat can read team salaries, and an ordinary
-- employee cannot call prosales_viewer_salary to read any team salary.
-- Verify RLS separately: direct SELECT on employees must not reveal others'
-- gross_salary even if this RPC is correctly restricted.
