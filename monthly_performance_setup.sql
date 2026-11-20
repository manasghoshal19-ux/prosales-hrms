-- Run in Supabase SQL Editor. HR authorization is checked against employees.role.
create table if not exists public.monthly_performance (
 employee_id uuid not null references public.employees(id) on delete cascade,
 month date not null,
 target_amount numeric(14,2) not null default 0 check(target_amount >= 0),
 achieved_amount numeric(14,2) not null default 0 check(achieved_amount >= 0),
 target_sales integer not null default 0 check(target_sales >= 0),
 achieved_sales integer not null default 0 check(achieved_sales >= 0),
 updated_at timestamptz not null default now(),
 primary key(employee_id,month),
 constraint month_first_day check(extract(day from month)=1)
);
alter table public.monthly_performance enable row level security;
drop policy if exists "performance_read_self_or_hr" on public.monthly_performance;
create policy "performance_read_self_or_hr" on public.monthly_performance for select to authenticated
using (employee_id=auth.uid() or exists(select 1 from public.employees e where e.id=auth.uid() and e.role='hr'));
drop policy if exists "performance_insert_hr" on public.monthly_performance;
create policy "performance_insert_hr" on public.monthly_performance for insert to authenticated
with check(exists(select 1 from public.employees e where e.id=auth.uid() and e.role='hr'));
drop policy if exists "performance_update_hr" on public.monthly_performance;
create policy "performance_update_hr" on public.monthly_performance for update to authenticated
using(exists(select 1 from public.employees e where e.id=auth.uid() and e.role='hr'))
with check(exists(select 1 from public.employees e where e.id=auth.uid() and e.role='hr'));
