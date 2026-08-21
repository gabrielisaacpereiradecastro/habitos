# Hábitos — tracker compartilhável

App de uma página só (HTML/CSS/JS puro), sem build, guardando os dados no
Supabase. Login com Google — cada pessoa só vê os próprios hábitos. Funciona
como "app" no iPhone via Add to Home Screen.

## Arquivos

- `index.html` — o app inteiro (URL e chave do Supabase já embutidas no
  código, não precisa configurar nada na primeira abertura)
- `manifest.json`, `sw.js`, `icons/` — pra virar "app" instalável no iPhone
- `supabase_schema.sql` — schema completo (tabelas + RLS por usuário)
- `supabase_migration_*.sql` — migrações incrementais pra bancos já existentes

## Como usar

- Na primeira vez que abrir, toque em **Continuar com Google** e entre com
  sua conta.
- Toque no **+** pra criar um hábito (emoji + nome + frequência + cor).
- Na lista, toque no **círculo** à direita pra marcar/desmarcar no dia
  selecionado.
- A **faixa de datas** no topo deixa navegar pra dias anteriores e marcar
  hábitos de qualquer dia, não só hoje.
- Toque no **nome do hábito** (não no círculo) pra abrir o histórico: streak
  atual, progresso (dias ou semanas conforme a frequência), o heatmap das
  últimas 18 semanas e o gráfico de tendência semanal.
- No heatmap, toque em qualquer dia passado pra marcar/desmarcar.
- O lápis (✏️) edita nome/emoji/frequência/cor, arquiva ou exclui o hábito.
- O ícone **↕️** no topo da lista entra em modo de reordenar (setas ▲▼ pra
  mudar a ordem dos hábitos); toque em **✓** pra sair do modo.
- **Frequência**: por padrão é "todos os dias", mas dá pra configurar um
  hábito como "3x por semana" etc. — nesse caso o streak conta semanas
  cumpridas em vez de dias, e o app mostra "X/N esta semana".
- **Arquivar** (no lápis) esconde o hábito da lista principal sem apagar o
  histórico; hábitos arquivados ficam listados em Configurações, com opção
  de restaurar ou excluir de vez.
- **Sair** (em Configurações) desconecta a conta Google desse dispositivo.

## Instalar no iPhone

1. Abra a URL do app no **Safari** (tem que ser Safari, não Chrome).
2. Entre com Google.
3. Toque no ícone de **Compartilhar** (o quadrado com seta pra cima) →
   **Adicionar à Tela de Início**.
4. Pronto — abre em tela cheia, com ícone próprio, sem barra do Safari.

## Convidar mais gente

Manda a URL do GitHub Pages pra quem quiser usar. Cada pessoa entra com a
própria conta Google e só vê os próprios hábitos — ninguém enxerga o de
ninguém, garantido por regra no banco (RLS), não só escondido na tela.

## Publicar mudanças de código

```bash
# dentro da pasta habit-tracker/
git add .
git commit -m "sua mensagem"
git push
```

GitHub Pages republica sozinho em cerca de 1 minuto.

## Segurança / arquitetura

- A URL e a chave **publishable** (anon) do Supabase ficam escritas no
  `index.html`, que é público no GitHub. Isso é seguro *desde que* toda
  tabela do projeto Supabase tenha RLS habilitada com policies restritas
  (nunca deixe uma tabela sem RLS nesse projeto) — é assim que apps 100%
  client-side com Supabase são desenhados pra funcionar.
- Cada linha de `habits`/`habit_logs` tem um `user_id`; as policies só
  liberam acesso quando `user_id = auth.uid()`. Sem estar logado, não dá
  pra ler nem escrever nada.

## Limitações conhecidas / próximos passos possíveis

- Offline: o "shell" do app fica em cache (abre rápido mesmo com internet
  ruim), mas marcar hábitos e ver histórico precisa de conexão, porque os
  dados vivem no Supabase.
- Sem lembretes/notificações push (fora do escopo por enquanto).
