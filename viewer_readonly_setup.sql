-- Review and run in Supabase SQL Editor after checking the employees schema.
-- Read-only viewer endpoints; never expose these through the anonymous role.
create or replace function public.prosales_viewer_people()
returns table(id uuid, full_name text, employee_code text)
language sql stable security definer set search_path = ''
as $$
 select e.id, e.full_name::text, e.employee_code::text
 from public.employees e
 where exists(select 1 from public.employees me where me.id=auth.uid() and me.role='viewer')
$$;
revoke all on function public.prosales_viewer_people() from public, anon;
grant execute on function public.prosales_viewer_people() to authenticated;

create or replace function public.prosales_viewer_salary()
returns table(full_name text, employee_code text, designation text, gross_salary numeric)
language sql stable security definer set search_path = ''
as $$
 select e.full_name::text,e.employee_code::text,e.designation::text,e.gross_salary::numeric
 from public.employees e
 where e.role='employee'
 and exists(select 1 from public.employees me where me.id=auth.uid() and me.role='viewer')
 order by e.full_name
$$;
revoke all on function public.prosales_viewer_salary() from public, anon;
grant execute on function public.prosales_viewer_salary() to authenticated;

create or replace function public.prosales_viewer_targets()
returns table(employee_id uuid, month date, target_amount numeric, achieved_amount numeric, target_sales integer, achieved_sales integer)
language sql stable security definer set search_path = ''
as $$
 select p.employee_id,p.month,p.target_amount,p.achieved_amount,p.target_sales,p.achieved_sales
 from public.monthly_performance p
 where exists(select 1 from public.employees me where me.id=auth.uid() and me.role='viewer')
 and exists(select 1 from public.employees e where e.id=p.employee_id and e.role='employee')
 order by p.month desc
 limit 100
$$;
revoke all on function public.prosales_viewer_targets() from public, anon;
grant execute on function public.prosales_viewer_targets() to authenticated;
