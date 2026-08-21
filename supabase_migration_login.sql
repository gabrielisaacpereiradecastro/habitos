-- Migração: login com Google + isolamento por usuário.
--
-- Rode isso no SQL Editor do projeto finplan. Depois de rodar, as tabelas
-- habits/habit_logs deixam de ser públicas e passam a exigir login — cada
-- pessoa só enxerga (e só consegue escrever) os próprios registros.
--
-- IMPORTANTE: depois de rodar isso, seus hábitos existentes (criados antes
-- do login existir) ficam com user_id nulo e temporariamente invisíveis pra
-- todo mundo, incluindo você. Depois de rodar, entre no app com Google e
-- rode o comando de backfill no final deste arquivo pra recuperar seu
-- histórico.

alter table habits add column if not exists user_id uuid references auth.users(id) on delete cascade;
alter table habit_logs add column if not exists user_id uuid references auth.users(id) on delete cascade;

create index if not exists habits_user_id_idx on habits (user_id);
create index if not exists habit_logs_user_id_idx on habit_logs (user_id);

-- remove as policies públicas antigas
drop policy if exists "public read habits" on habits;
drop policy if exists "public write habits" on habits;
drop policy if exists "public update habits" on habits;
drop policy if exists "public delete habits" on habits;
drop policy if exists "public read habit_logs" on habit_logs;
drop policy if exists "public write habit_logs" on habit_logs;
drop policy if exists "public update habit_logs" on habit_logs;
drop policy if exists "public delete habit_logs" on habit_logs;

-- policies por dono, no mesmo padrão já usado nas outras tabelas do finplan
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

-- ---------------------------------------------------------------------
-- BACKFILL (rode depois de entrar no app com Google pelo menos uma vez):
--
-- 1. Descubra seu user id:
--    select id, email from auth.users order by created_at desc;
--
-- 2. Cole o id encontrado no lugar de SEU-UUID-AQUI abaixo e rode:
--    update habits set user_id = 'SEU-UUID-AQUI' where user_id is null;
--    update habit_logs set user_id = 'SEU-UUID-AQUI' where user_id is null;
