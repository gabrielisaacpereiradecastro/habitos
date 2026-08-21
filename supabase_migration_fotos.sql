-- Migração: fotos de progresso (frente/costas/esquerda/direita) + peso/% gordura.
-- Rode no SQL Editor do projeto finplan.

-- bucket privado pras fotos (não fica acessível por URL pública, só via signed URL)
insert into storage.buckets (id, name, public)
values ('body-photos', 'body-photos', false)
on conflict (id) do nothing;

create table if not exists body_checkins (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid references auth.users(id) on delete cascade,
  checkin_date   date not null,
  weight_kg      numeric,
  body_fat_pct   numeric,
  photo_front    text,
  photo_back     text,
  photo_left     text,
  photo_right    text,
  created_at     timestamptz not null default now(),
  unique (user_id, checkin_date)
);

create index if not exists body_checkins_user_date_idx on body_checkins (user_id, checkin_date);

alter table body_checkins enable row level security;

drop policy if exists "body_checkins_select_own" on body_checkins;
create policy "body_checkins_select_own" on body_checkins
  for select using (user_id = auth.uid());
drop policy if exists "body_checkins_insert_own" on body_checkins;
create policy "body_checkins_insert_own" on body_checkins
  for insert with check (user_id = auth.uid());
drop policy if exists "body_checkins_update_own" on body_checkins;
create policy "body_checkins_update_own" on body_checkins
  for update using (user_id = auth.uid());
drop policy if exists "body_checkins_delete_own" on body_checkins;
create policy "body_checkins_delete_own" on body_checkins
  for delete using (user_id = auth.uid());

-- Storage: cada usuário só acessa objetos dentro da própria pasta
-- (caminho é sempre "<user_id>/<data>/<angulo>.jpg")
drop policy if exists "body_photos_select_own" on storage.objects;
create policy "body_photos_select_own" on storage.objects
  for select using (bucket_id = 'body-photos' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "body_photos_insert_own" on storage.objects;
create policy "body_photos_insert_own" on storage.objects
  for insert with check (bucket_id = 'body-photos' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "body_photos_update_own" on storage.objects;
create policy "body_photos_update_own" on storage.objects
  for update using (bucket_id = 'body-photos' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "body_photos_delete_own" on storage.objects;
create policy "body_photos_delete_own" on storage.objects
  for delete using (bucket_id = 'body-photos' and (storage.foldername(name))[1] = auth.uid()::text);
