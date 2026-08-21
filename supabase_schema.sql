-- Habit tracker — schema para rodar no SQL Editor do Supabase
-- (Project > SQL Editor > New query > cole tudo isso > Run)
--
-- Este schema já assume login com Google (Supabase Auth): cada hábito e
-- cada log pertence a um user_id, e as policies só liberam acesso ao dono.
-- Se você está migrando um banco criado ANTES do login existir, use
-- supabase_migration_login.sql em vez de rodar este arquivo inteiro de novo
-- (ele preserva o histórico e evita mexer nas policies já em uso).

create extension if not exists "pgcrypto";

create table if not exists habits (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid references auth.users(id) on delete cascade,
  name             text not null,
  emoji            text not null default '✅',
  sort_order       integer not null default 0,
  target_per_week  integer not null default 7,
  color            text not null default '#2a78d6',
  archived         boolean not null default false,
  created_at       timestamptz not null default now()
);

-- garante as colunas em bancos que rodaram este schema antes dessas features
-- existirem (rodar de novo aqui é seguro, não faz nada se já existirem)
alter table habits add column if not exists target_per_week integer not null default 7;
alter table habits add column if not exists color text not null default '#2a78d6';
alter table habits add column if not exists user_id uuid references auth.users(id) on delete cascade;

create table if not exists habit_logs (
  id          uuid primary key default gen_random_uuid(),
  habit_id    uuid not null references habits(id) on delete cascade,
  user_id     uuid references auth.users(id) on delete cascade,
  log_date    date not null,
  created_at  timestamptz not null default now(),
  unique (habit_id, log_date)
);

alter table habit_logs add column if not exists user_id uuid references auth.users(id) on delete cascade;

create index if not exists habit_logs_habit_date_idx on habit_logs (habit_id, log_date);
create index if not exists habits_user_id_idx on habits (user_id);
create index if not exists habit_logs_user_id_idx on habit_logs (user_id);

-- Row Level Security -------------------------------------------------------
-- Cada hábito/log só é visível e editável pelo próprio dono (auth.uid()).

alter table habits enable row level security;
alter table habit_logs enable row level security;

drop policy if exists "habits_select_own" on habits;
create policy "habits_select_own" on habits
  for select using (user_id = auth.uid());
drop policy if exists "habits_insert_own" on habits;
create policy "habits_insert_own" on habits
  for insert with check (user_id = auth.uid());
drop policy if exists "habits_update_own" on habits;
create policy "habits_update_own" on habits
  for update using (user_id = auth.uid());
drop policy if exists "habits_delete_own" on habits;
create policy "habits_delete_own" on habits
  for delete using (user_id = auth.uid());

drop policy if exists "habit_logs_select_own" on habit_logs;
create policy "habit_logs_select_own" on habit_logs
  for select using (user_id = auth.uid());
drop policy if exists "habit_logs_insert_own" on habit_logs;
create policy "habit_logs_insert_own" on habit_logs
  for insert with check (user_id = auth.uid());
drop policy if exists "habit_logs_update_own" on habit_logs;
create policy "habit_logs_update_own" on habit_logs
  for update using (user_id = auth.uid());
drop policy if exists "habit_logs_delete_own" on habit_logs;
create policy "habit_logs_delete_own" on habit_logs
  for delete using (user_id = auth.uid());
