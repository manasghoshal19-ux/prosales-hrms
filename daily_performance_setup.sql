-- Run once in Supabase SQL Editor
create table if not exists public.daily_performance (
 employee_id uuid not null references public.employees(id) on delete cascade,
 entry_date date not null,
 achieved_amount numeric(14,2) not null default 0 check(achieved_amount >= 0),
 achieved_sales integer not null default 0 check(achieved_sales >= 0),
 updated_at timestamptz not null default now(),
 primary key(employee_id,entry_date)
);
alter table public.daily_performance enable row level security;
grant select,insert,update on public.daily_performance to authenticated;
drop policy if exists "daily_read_self_or_hr" on public.daily_performance;
create policy "daily_read_self_or_hr" on public.daily_performance for select to authenticated using (
 employee_id=auth.uid() or exists(select 1 from public.employees e where e.id=auth.uid() and e.role='hr')
);
drop policy if exists "daily_insert_hr" on public.daily_performance;
create policy "daily_insert_hr" on public.daily_performance for insert to authenticated with check (
 exists(select 1 from public.employees e where e.id=auth.uid() and e.role='hr')
);
drop policy if exists "daily_update_hr" on public.daily_performance;
create policy "daily_update_hr" on public.daily_performance for update to authenticated using (
 exists(select 1 from public.employees e where e.id=auth.uid() and e.role='hr')
) with check (
 exists(select 1 from public.employees e where e.id=auth.uid() and e.role='hr')
);
-- Monthly totals are derived from daily rows in the website, not incremented twice.
