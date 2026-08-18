-- Migração: adiciona frequência semanal por hábito (Nx por semana).
--
-- Se seu banco já foi criado rodando supabase_schema.sql ANTES dessa
-- feature existir, rode só isso aqui no SQL Editor do seu projeto Supabase
-- (não precisa rodar o schema inteiro de novo, que erraria nas policies
-- que já existem). É seguro rodar mais de uma vez.

alter table habits add column if not exists target_per_week integer not null default 7;
