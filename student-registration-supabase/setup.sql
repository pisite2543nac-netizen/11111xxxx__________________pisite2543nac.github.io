-- รันไฟล์นี้ใน Supabase Dashboard > SQL Editor เพียงครั้งเดียว
create extension if not exists pgcrypto;

create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) between 1 and 150),
  level text not null check (level in ('ปวช','ปวส')),
  student_id text not null check (student_id ~ '^[0-9]{2,20}$'),
  score integer not null default 0 check (score between 0 and 100),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(level, student_id)
);

create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.students enable row level security;
alter table public.admins enable row level security;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.admins where user_id = auth.uid()) $$;

create or replace function public.current_user_is_admin()
returns boolean language sql stable security definer set search_path=public
as $$ select public.is_admin() $$;

grant execute on function public.current_user_is_admin() to authenticated;

create policy "admins can read students" on public.students for select to authenticated using (public.is_admin());
create policy "admins can add students" on public.students for insert to authenticated with check (public.is_admin());
create policy "admins can update students" on public.students for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admins can delete students" on public.students for delete to authenticated using (public.is_admin());

create or replace function public.register_student(p_name text, p_level text, p_student_id text)
returns jsonb language plpgsql security definer set search_path=public
as $$
begin
  p_name := trim(p_name); p_student_id := trim(p_student_id);
  if p_name = '' or char_length(p_name) > 150 then raise exception 'กรุณากรอกชื่อให้ถูกต้อง'; end if;
  if p_level not in ('ปวช','ปวส') then raise exception 'ระดับชั้นไม่ถูกต้อง'; end if;
  if p_student_id !~ '^[0-9]{2,20}$' then raise exception 'เลขท้ายนักศึกษาต้องเป็นตัวเลข 2-20 หลัก'; end if;
  insert into public.students(name,level,student_id) values(p_name,p_level,p_student_id);
  return jsonb_build_object('message','ลงทะเบียนสำเร็จ');
exception when unique_violation then
  raise exception 'เลขท้ายนักศึกษานี้ลงทะเบียนแล้วในระดับชั้นดังกล่าว';
end $$;

grant execute on function public.register_student(text,text,text) to anon, authenticated;

create or replace function public.lookup_student_score(p_level text, p_student_id text)
returns table(name text, level text, student_id text, score integer)
language sql security definer set search_path=public
as $$
  select s.name,s.level,s.student_id,s.score from public.students s
  where s.level=p_level and s.student_id=trim(p_student_id) limit 1
$$;

grant execute on function public.lookup_student_score(text,text) to anon, authenticated;

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$ begin new.updated_at=now(); return new; end $$;
drop trigger if exists students_set_updated_at on public.students;
create trigger students_set_updated_at before update on public.students for each row execute function public.set_updated_at();

-- หลังจากสร้างผู้ใช้ Admin ใน Authentication > Users แล้ว
-- ให้นำ UUID มาแทน ADMIN_USER_UUID และรันคำสั่งบรรทัดถัดไปแยกต่างหาก
-- insert into public.admins(user_id) values ('ADMIN_USER_UUID');
