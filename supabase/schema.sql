-- UMAT-101 LMS schema
create extension if not exists pgcrypto;

create type public.user_role as enum ('student','ta','instructor');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role public.user_role not null default 'student',
  created_at timestamptz not null default now()
);

create table public.courses (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  title text not null,
  instructor_name text not null,
  textbook text,
  created_at timestamptz not null default now()
);

create table public.course_members (
  course_id uuid references public.courses(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  role public.user_role not null,
  primary key(course_id,user_id)
);

create table public.modules (
  id uuid primary key default gen_random_uuid(),
  course_id uuid references public.courses(id) on delete cascade,
  position int not null,
  title text not null,
  description text,
  textbook_reference text,
  published boolean not null default true,
  unique(course_id,position)
);

create table public.topics (
  id uuid primary key default gen_random_uuid(),
  module_id uuid references public.modules(id) on delete cascade,
  position int not null,
  title text not null,
  textbook_section text,
  published boolean not null default true
);

create table public.lectures (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid references public.topics(id) on delete cascade,
  title text not null,
  storage_path text,
  published boolean not null default false,
  uploaded_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create table public.assignments (
  id uuid primary key default gen_random_uuid(),
  course_id uuid references public.courses(id) on delete cascade,
  module_id uuid references public.modules(id),
  title text not null,
  instructions text,
  storage_path text,
  max_marks numeric not null default 10,
  due_at timestamptz,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.submissions (
  id uuid primary key default gen_random_uuid(),
  assignment_id uuid references public.assignments(id) on delete cascade,
  student_id uuid references public.profiles(id) on delete cascade,
  storage_path text not null,
  submitted_at timestamptz not null default now(),
  feedback text,
  graded_by uuid references public.profiles(id),
  graded_at timestamptz,
  marks numeric,
  unique(assignment_id,student_id)
);

create table public.announcements (
  id uuid primary key default gen_random_uuid(),
  course_id uuid references public.courses(id) on delete cascade,
  title text not null,
  body text not null,
  published_by uuid references public.profiles(id),
  published_at timestamptz not null default now()
);

create table public.grades (
  id uuid primary key default gen_random_uuid(),
  course_id uuid references public.courses(id) on delete cascade,
  student_id uuid references public.profiles(id) on delete cascade,
  component text not null,
  marks numeric,
  max_marks numeric,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.courses enable row level security;
alter table public.course_members enable row level security;
alter table public.modules enable row level security;
alter table public.topics enable row level security;
alter table public.lectures enable row level security;
alter table public.assignments enable row level security;
alter table public.submissions enable row level security;
alter table public.announcements enable row level security;
alter table public.grades enable row level security;

-- Profile: users can read their own profile.
create policy "profiles_self_read" on public.profiles for select using (id=auth.uid());

-- Course content is readable to authenticated users.
create policy "courses_auth_read" on public.courses for select to authenticated using (true);
create policy "modules_auth_read" on public.modules for select to authenticated using (published=true);
create policy "topics_auth_read" on public.topics for select to authenticated using (published=true);
create policy "lectures_auth_read" on public.lectures for select to authenticated using (published=true);
create policy "assignments_auth_read" on public.assignments for select to authenticated using (published=true);
create policy "announcements_auth_read" on public.announcements for select to authenticated using (true);

-- Students can read their own submissions/grades.
create policy "submissions_self_read" on public.submissions for select using (student_id=auth.uid());
create policy "grades_self_read" on public.grades for select using (student_id=auth.uid());

-- Staff policies are deliberately added through helper functions below.
create or replace function public.is_staff()
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.profiles where id=auth.uid() and role in ('ta','instructor')); $$;

create policy "staff_manage_modules" on public.modules for all using (public.is_staff()) with check (public.is_staff());
create policy "staff_manage_topics" on public.topics for all using (public.is_staff()) with check (public.is_staff());
create policy "staff_manage_lectures" on public.lectures for all using (public.is_staff()) with check (public.is_staff());
create policy "staff_manage_assignments" on public.assignments for all using (public.is_staff()) with check (public.is_staff());
create policy "staff_manage_announcements" on public.announcements for all using (public.is_staff()) with check (public.is_staff());
create policy "staff_manage_submissions" on public.submissions for select using (public.is_staff()) ;
create policy "staff_grade_submissions" on public.submissions for update using (public.is_staff()) with check (public.is_staff());
create policy "staff_manage_grades" on public.grades for all using (public.is_staff()) with check (public.is_staff());

-- Seed course + provisional modules.
insert into public.courses(code,title,instructor_name,textbook)
values('UMAT-101','Differential Calculus','S. Balasubramanian','Thomas'' Calculus, 12th Edition')
on conflict(code) do nothing;

insert into public.modules(course_id,position,title,description,textbook_reference)
select id,1,'Functions','Functions and their graphs.','Thomas'' Calculus 12e · §§1.1–1.4' from public.courses where code='UMAT-101'
on conflict(course_id,position) do nothing;
insert into public.modules(course_id,position,title,description,textbook_reference)
select id,2,'Limits and Continuity','Limits, one-sided limits, continuity and asymptotes.','Thomas'' Calculus 12e · §§2.1–2.6' from public.courses where code='UMAT-101'
on conflict(course_id,position) do nothing;
insert into public.modules(course_id,position,title,description,textbook_reference)
select id,3,'Differentiation','The derivative, differentiation rules, chain rule, implicit differentiation, related rates, linearization.','Thomas'' Calculus 12e · §§3.1–3.9' from public.courses where code='UMAT-101'
on conflict(course_id,position) do nothing;
insert into public.modules(course_id,position,title,description,textbook_reference)
select id,4,'Applications of Derivatives','Extreme values, MVT, monotonicity, curve sketching, optimization and Newton''s method.','Thomas'' Calculus 12e · §§4.1–4.7' from public.courses where code='UMAT-101'
on conflict(course_id,position) do nothing;
insert into public.modules(course_id,position,title,description,textbook_reference,published)
select id,5,'Additional Differential Calculus Topics','Selected material to be confirmed by the teaching team.','Selected material · initially unpublished',false from public.courses where code='UMAT-101'
on conflict(course_id,position) do nothing;
