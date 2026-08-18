# Hábitos — tracker pessoal

App de uma página só (HTML/CSS/JS puro), sem build, guardando os dados no
Supabase. Funciona como "app" no iPhone via Add to Home Screen.

## Arquivos

- `index.html` — o app inteiro
- `manifest.json`, `sw.js`, `icons/` — pra virar "app" instalável no iPhone
- `supabase_schema.sql` — schema pra rodar no seu projeto Supabase

## 1. Supabase

1. Crie um projeto em supabase.com (ou use um que você já tem).
2. Vá em **SQL Editor → New query**, cole o conteúdo de `supabase_schema.sql`
   e rode. Isso cria as tabelas `habits` e `habit_logs` com RLS liberado pra
   leitura/escrita pública (ver nota de segurança no próprio arquivo `.sql`).
3. Vá em **Project Settings → API** e copie a **Project URL** e a
   **anon public key**. Você vai colar isso dentro do app na primeira vez
   que abrir (fica salvo só no seu iPhone, não precisa editar código nem
   commitar segredo nenhum).

## 2. Publicar no GitHub Pages

```bash
# dentro da pasta habit-tracker/
git init
git add .
git commit -m "habit tracker"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/habitos.git
git push -u origin main
```

No GitHub: **Settings → Pages → Source: Deploy from a branch → main / (root)**.
Depois de ~1 minuto, seu app fica em:
`https://SEU_USUARIO.github.io/habitos/`

## 3. Instalar no iPhone

1. Abra a URL do GitHub Pages no **Safari** (tem que ser Safari, não Chrome).
2. Na primeira vez, cole a URL e a anon key do Supabase (passo 1.3).
3. Toque no ícone de **Compartilhar** (o quadrado com seta pra cima) →
   **Adicionar à Tela de Início**.
4. Pronto — abre em tela cheia, com ícone próprio, sem barra do Safari.

## Como usar

- Toque no **+** pra criar um hábito (emoji + nome + frequência).
- Na lista, toque no **círculo** à direita pra marcar/desmarcar hoje.
- Toque no **nome do hábito** (não no círculo) pra abrir o histórico: streak
  atual, progresso (dias ou semanas conforme a frequência), o heatmap das
  últimas 18 semanas e o gráfico de tendência semanal.
- No heatmap, toque em qualquer dia passado pra marcar/desmarcar (dá pra
  corrigir um dia que esqueceu de registrar).
- O lápis (✏️) edita nome/emoji/frequência, arquiva ou exclui o hábito.
- O ícone **↕️** no topo da lista entra em modo de reordenar (setas ▲▼ pra
  mudar a ordem dos hábitos); toque em **✓** pra sair do modo.
- **Frequência**: por padrão é "todos os dias", mas dá pra configurar um
  hábito como "3x por semana" etc. — nesse caso o streak conta semanas
  cumpridas em vez de dias, e o app mostra "X/N esta semana".
- **Arquivar** (no lápis) esconde o hábito da lista principal sem apagar o
  histórico; hábitos arquivados ficam listados em Configurações, com opção
  de restaurar ou excluir de vez.
- **Cor**: escolha uma das cores prontas ou toque no círculo colorido (ícone
  de "outra cor") pra abrir o seletor nativo e escolher qualquer cor — dá
  pra repetir a mesma cor em hábitos diferentes sem problema. A cor aparece
  na barrinha lateral do hábito na lista, no círculo de marcar, no heatmap
  e no gráfico de tendência.

## Atualizando um app já publicado

Se você já tinha rodado `supabase_schema.sql` antes dessas features
existirem, rode `supabase_migration_frequencia.sql` e
`supabase_migration_cor.sql` uma vez no SQL Editor do seu projeto (cada um
só adiciona uma coluna nova, é seguro rodar de novo). Depois é só dar
`git push` do `index.html` atualizado — GitHub Pages republica sozinho.

## Limitações conhecidas / próximos passos possíveis

- Sem login: quem tiver a URL do Supabase + anon key consegue ler/escrever
  nas suas tabelas. Pra um tracker pessoal isso costuma ser aceitável, mas
  se quiser travar de verdade, dá pra adicionar Supabase Auth depois.
- Offline: o "shell" do app fica em cache (abre rápido mesmo com internet
  ruim), mas marcar hábitos e ver histórico precisa de conexão, porque os
  dados vivem no Supabase.
- Sem lembretes/notificações push (fora do escopo por enquanto).
