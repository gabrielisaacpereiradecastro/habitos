-- Habit tracker — schema para rodar no SQL Editor do Supabase
-- (Project > SQL Editor > New query > cole tudo isso > Run)

create extension if not exists "pgcrypto";

create table if not exists habits (
  id               uuid primary key default gen_random_uuid(),
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

create table if not exists habit_logs (
  id          uuid primary key default gen_random_uuid(),
  habit_id    uuid not null references habits(id) on delete cascade,
  log_date    date not null,
  created_at  timestamptz not null default now(),
  unique (habit_id, log_date)
);

create index if not exists habit_logs_habit_date_idx on habit_logs (habit_id, log_date);

-- Row Level Security -------------------------------------------------------
-- Este app usa a "anon key" pública do Supabase direto no navegador, sem
-- login. Isso é OK para um tracker pessoal (ninguém vai adivinhar a URL do
-- seu projeto), mas tecnicamente qualquer pessoa com a URL + anon key
-- consegue ler/escrever nessas duas tabelas. Se um dia você quiser travar
-- isso de verdade, o próximo passo é adicionar Supabase Auth (login por
-- e-mail) e trocar as policies abaixo para `using (auth.uid() = user_id)`.

alter table habits enable row level security;
alter table habit_logs enable row level security;

-- drop antes de criar deixa o script seguro de rodar mais de uma vez
-- (create policy sozinho não suporta "if not exists")
drop policy if exists "public read habits" on habits;
create policy "public read habits" on habits
  for select using (true);
drop policy if exists "public write habits" on habits;
create policy "public write habits" on habits
  for insert with check (true);
drop policy if exists "public update habits" on habits;
create policy "public update habits" on habits
  for update using (true);
drop policy if exists "public delete habits" on habits;
create policy "public delete habits" on habits
  for delete using (true);

drop policy if exists "public read habit_logs" on habit_logs;
create policy "public read habit_logs" on habit_logs
  for select using (true);
drop policy if exists "public write habit_logs" on habit_logs;
create policy "public write habit_logs" on habit_logs
  for insert with check (true);
drop policy if exists "public update habit_logs" on habit_logs;
create policy "public update habit_logs" on habit_logs
  for update using (true);
drop policy if exists "public delete habit_logs" on habit_logs;
create policy "public delete habit_logs" on habit_logs
  for delete using (true);
