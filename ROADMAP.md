# Autta.ONE - Roadmap de White-Label

> Baseado no Chatwoot v4.11.2 | Atualizado em 2026-03-09

---

## Estado Atual (Diagnóstico)

O script `replace_brand.rb` foi executado previamente e fez substituições de "Chatwoot" -> "Autta.ONE" nos locales e componentes Vue. Porém, ele **quebrou** partes do código JavaScript ao gerar nomes de variáveis inválidos (ex: `AUTTA.ONE_INBOX_TOKEN`, `isOnAutta.ONECloud`). O `installation_config.yml` ainda aponta para valores padrão do Chatwoot.

### Problemas Identificados

| Arquivo | Problema | Severidade |
|---------|----------|------------|
| `app/javascript/shared/store/globalConfig.js:10` | `AUTTA.ONE_INBOX_TOKEN` - variável JS inválida (ponto no nome) | **CRÍTICO** |
| `app/javascript/shared/store/globalConfig.js:56-58` | Getters com nomes inválidos: `isOnAutta.ONECloud`, `isAAutta.ONEInstance` | **CRÍTICO** |
| `app/javascript/shared/composables/useBranding.js:20` | Regex hardcoded `/Autta.ONE/g` - deveria ser `/Chatwoot/g` para funcionar como white-label | MÉDIO |
| `config/installation_config.yml` | Todos os valores de branding ainda são "Chatwoot" | MÉDIO |
| `app/javascript/sdk/` e `widget/` | ~651 ocorrências de "chatwoot" lowercase (variáveis, URLs, package refs) | BAIXO (muitas são internas) |

---

## Fase 1: Correções Críticas (JS Quebrado)

> **Objetivo:** Restaurar o código que o script de replace quebrou.

- [ ] **1.1** Corrigir `globalConfig.js` - reverter nomes de variáveis JS para usar `CHATWOOT_*` internamente
  - `AUTTA.ONE_INBOX_TOKEN` -> `CHATWOOT_INBOX_TOKEN` (nome da variável JS, não texto de UI)
  - `isOnAutta.ONECloud` -> `isOnChatwootCloud`
  - `isAAutta.ONEInstance` -> `isAChatwootInstance` (ou remover se não usado)
  - Manter a lógica de comparação com `installationName` (que vem do config)
- [ ] **1.2** Verificar e corrigir outros arquivos JS onde `AUTTA.ONE` foi inserido em nomes de variáveis/constantes
  - `dashboard/featureFlags.js`
  - `sdk/bubbleHelpers.js`
  - `sdk/IFrameHelper.js`
  - `dashboard/helper/scriptHelpers.js`
  - `widget/constants/sdkEvents.js`
- [ ] **1.3** Corrigir `useBranding.js` - a regex deve substituir "Chatwoot" pelo nome da instalação, não "Autta.ONE"
- [ ] **1.4** Testar que a aplicação compila sem erros (`pnpm dev`)

---

## Fase 2: Configuração de Branding (Forma Correta)

> **Objetivo:** Usar o sistema de white-label nativo do Chatwoot ao invés de find-and-replace.

- [ ] **2.1** Atualizar `config/installation_config.yml`:
  ```yaml
  INSTALLATION_NAME: 'Autta.ONE'
  BRAND_NAME: 'Autta.ONE'
  BRAND_URL: 'https://autta.one'          # URL da Autta
  WIDGET_BRAND_URL: 'https://autta.one'
  TERMS_URL: 'https://autta.one/termos'
  PRIVACY_URL: 'https://autta.one/privacidade'
  DISPLAY_MANIFEST: false                  # Desabilita metadados do Chatwoot
  ```
- [ ] **2.2** Substituir assets em `public/brand-assets/`:
  - `logo.svg` - Logo Autta.ONE para modo claro
  - `logo_dark.svg` - Logo Autta.ONE para modo escuro
  - `logo_thumbnail.svg` - Ícone Autta.ONE (favicon, 512x512)
- [ ] **2.3** Substituir demais assets públicos:
  - `public/favicon.ico`
  - `public/logo.png`
  - `public/apple-touch-icon*.png`
  - `public/android-chrome-*.png`
  - `public/mstile-*.png`
- [ ] **2.4** Atualizar design-system logos:
  - `app/javascript/design-system/images/logo.png`
  - `app/javascript/design-system/images/logo-dark.png`
  - `app/javascript/design-system/images/logo-thumbnail.svg`
- [ ] **2.5** Atualizar widget logo:
  - `app/javascript/widget/assets/images/logo.svg`

---

## Fase 3: Paleta de Cores

> **Objetivo:** Aplicar a identidade visual Autta.ONE.

**Cores definidas:**
- Principais: `#030303`, `#16ebf9`, `#157eb7`, `#18b2ee`, `#5b2dff`, `#ffffff`
- Secundárias: `#04070d`, `#0b0f1a`, `#253260`, `#32646a`
- Contraste: `#16ebf9`, `#bcff00`, `#ff7a00`

- [ ] **3.1** Atualizar `theme/colors.js` - substituir cor `woot` brand principal por `#157eb7` (ou a paleta completa)
- [ ] **3.2** Atualizar `tailwind.config.js` se houver cores customizadas adicionais
- [ ] **3.3** Verificar variáveis CSS em `:root` que definem cores do tema
- [ ] **3.4** Testar dark mode com as novas cores

---

## Fase 4: Localização (i18n)

> **Objetivo:** Garantir que textos visíveis ao usuário mostrem "Autta.ONE".

- [ ] **4.1** Atualizar `config/locales/en.yml` - substituir referências textuais a "Chatwoot" por `%{installation_name}` (usa interpolação dinâmica) ou "Autta.ONE" onde interpolação não é possível
- [ ] **4.2** Atualizar `app/javascript/dashboard/i18n/locale/en/` (JSON) - mesma abordagem
- [ ] **4.3** Atualizar `config/locales/pt_BR.yml` (se existir) ou criar tradução PT-BR
- [ ] **4.4** Atualizar templates de email em `app/views/` para refletir a marca

> **Nota:** Conforme CLAUDE.md, só atualizamos `en.yml` e `en.json`. Outras línguas são da comunidade.

---

## Fase 5: Limpeza de Referências Internas

> **Objetivo:** Remover referências "Chatwoot" visíveis ao usuário que o sistema de config não cobre.

- [ ] **5.1** Auditar textos hardcoded no frontend que mencionam "Chatwoot" (fora de i18n)
- [ ] **5.2** Substituir usando `replaceInstallationName()` do composable `useBranding` (forma recomendada pelo projeto)
- [ ] **5.3** Atualizar `<title>` e meta tags em layouts HTML (`app/views/layouts/`)
- [ ] **5.4** Atualizar `manifest.json` / `site.webmanifest` se aplicável

---

## Fase 6: Módulo Kanban (CRM Integrado)

> **Objetivo:** Criar sistema CRM visual com Kanban para gestão de leads/negociações.

### 6.1 Backend (Rails)

- [ ] **6.1.1** Criar migration e models:
  - `KanbanBoard` (belongs_to :account)
  - `KanbanColumn` (belongs_to :kanban_board, has position, color, name)
  - `KanbanDeal` (belongs_to :kanban_column, belongs_to :conversation/contact, deal_value decimal)
- [ ] **6.1.2** Criar seed para funil padrão:
  - Novo Lead > Contato Feito > Conversa em Andamento > Reunião Agendada > Proposta Enviada > Ganho > Perdido
- [ ] **6.1.3** Criar API controllers:
  - `Api::V1::Accounts::KanbanBoardsController` (CRUD)
  - `Api::V1::Accounts::KanbanColumnsController` (CRUD + reorder)
  - `Api::V1::Accounts::KanbanDealsController` (CRUD + move between columns)
- [ ] **6.1.4** Adicionar rotas em `config/routes.rb`
- [ ] **6.1.5** Adicionar policies (Pundit) para autorização

### 6.2 Frontend (Vue.js)

- [ ] **6.2.1** Criar rota `/app/accounts/:accountId/kanban`
- [ ] **6.2.2** Adicionar item no menu lateral (Sidebar) abaixo de "Caixas de Entrada"
- [ ] **6.2.3** Criar store Vuex para Kanban (boards, columns, deals)
- [ ] **6.2.4** Criar componentes:
  - `KanbanBoard.vue` - container do quadro
  - `KanbanColumn.vue` - coluna com header (nome + soma R$) + lista de cards
  - `KanbanDealCard.vue` - card individual (nome contato + valor)
  - `KanbanColumnForm.vue` - form para criar/editar coluna (nome + cor)
- [ ] **6.2.5** Implementar drag-and-drop (SortableJS/vuedraggable)
- [ ] **6.2.6** Ao clicar no card -> navegar para a conversa do cliente
- [ ] **6.2.7** Exibir soma financeira no header de cada coluna

---

## Fase 7: Preparação para Deploy (Docker)

- [ ] **7.1** Atualizar `.env` de produção com variáveis Autta.ONE
- [ ] **7.2** Ajustar `docker-compose.yml` para ambiente de produção
- [ ] **7.3** Configurar domínio e SSL
- [ ] **7.4** Testar build Docker completo
- [ ] **7.5** Documentar processo de deploy

---

## Ordem de Execução Recomendada

```
Fase 1 (Correções Críticas)  ← FAZER PRIMEIRO - app pode estar quebrada
  ↓
Fase 2 (Branding Config)     ← Usa sistema nativo, mais seguro
  ↓
Fase 3 (Cores)               ← Identidade visual
  ↓
Fase 4 (i18n)                ← Textos restantes
  ↓
Fase 5 (Limpeza)             ← Polimento final do white-label
  ↓
Fase 6 (Kanban)              ← Feature nova, maior esforço
  ↓
Fase 7 (Deploy)              ← Só após tudo testado
```

---

## Assets Disponíveis

| Asset | Caminho |
|-------|---------|
| Ícone Azul | `Autta Logo/Ícone - Azul.png` |
| Ícone Marinho | `Autta Logo/Ícone - Marinho.png` |
| Ícone Preto | `Autta Logo/Ícone - Preto.png` |
| Ícone Branco | `Autta Logo/Ícone - branco.png` |
| Logo Branco | `Autta Logo/Logo Branco.png` |
| Logo Preto | `Autta Logo/Logo Preto.png` |
| Wordmark Branco | `Autta Logo/Wordmark Branco.png` |
| Wordmark Preto | `Autta Logo/Wordmark Preto.png` |

> **Atenção:** Os logos estão em PNG. O Chatwoot usa SVG em vários lugares. Será necessário converter para SVG ou adaptar os componentes para aceitar PNG.
