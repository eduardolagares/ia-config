# Monday.com — `/revisar-tarefa`

**Leitura da tarefa:** skill `monday-task-info` (passo 1 de `revisar-tarefa`). Este arquivo é referência legada (GraphQL, discovery, mutations). O fluxo atual altera status/owners no Monday apenas no **passo 8** (`pos-avaliacao`). GitLab (passo 3): **somente leitura** (REST API).

API GraphQL v2: `https://api.monday.com/v2`

Header em **todas** as requisições:

```http
Authorization: <MONDAY_API_TOKEN>
Content-Type: application/json
```

Não commitar token. Não colar token no chat.

## Variáveis de ambiente

| Variável | Obrigatório | Descrição |
|----------|-------------|-----------|
| `MONDAY_API_TOKEN` | Sim | Personal API Token (Monday → Avatar → Developers → API token) |
| `MONDAY_BOARD_ID` | Não* | Board **Dia a Dia**: `4571892384` — https://baladapp-company.monday.com/boards/4571892384 |
| `MONDAY_COL_BRANCH` | Não* | Dia a dia: `texto` (título Branch) |
| `MONDAY_COL_STATUS` | Não* | Dia a dia: `status_1` (Status consolidado) — **não** `espelho` (mirror) |
| `MONDAY_COL_STATUS_MIRROR` | Não | `espelho` — só leitura |
| `MONDAY_COL_STATUS_TITLE` | Não | `Status consolidado` |
| `MONDAY_SUBITEM_BOARD_ID` | Não* | Board filho das subtarefas (discovery seção 7) |
| `MONDAY_COL_SUBITEM_STATUS` | Não* | Coluna **Status** no board subtarefas |
| `MONDAY_COL_SUBITEM_STATUS_TITLE` | Não | Default: `Status` |
| `MONDAY_SUBITEM_STATUS_LABELS_FILE` | Não | `monday-subitem-status-labels.json` |

\* Sem IDs fixos, a skill resolve por `title` da coluna na resposta GraphQL.

## 1. Criar token

1. Monday → ícone perfil → **Developers** → **My access tokens** → **Generate**
2. Escopos: leitura + escrita em boards que você usa (mínimo: ler items/updates, alterar colunas do board **Dia a Dia**)
3. Copiar token (mostrado uma vez)

## 2. Exportar no shell (zsh)

```bash
# ~/.zshrc
export MONDAY_API_TOKEN="eyJhbGciOiJIUzI1NiJ9..."
# Preencher após scripts/monday-discover.sh
export MONDAY_BOARD_ID="1234567890"
export MONDAY_COL_BRANCH="texto_xxxxx"
export MONDAY_COL_STATUS="status"
```

```bash
source ~/.zshrc
```

## 3. Discovery (board + colunas)

```bash
# Token já no ~/.zshrc
scripts/monday-discover.sh

# Testar busca por título exato
MONDAY_TEST_TITLE="[RF-042] Nome da tarefa" \
  scripts/monday-discover.sh
```

**Saída no terminal:** tabela de todas as colunas; para **cada coluna `type=status`**, tabela de labels (`INDEX`, `ID`, `LABEL`, `COLOR`, `DONE`, origem `settings` ou `settings_str`). O campo GraphQL `settings` neste board é JSON escalar (sem fragment `StatusColumnSettings`); o script parseia `settings` e/ou `settings_str`.

**Arquivos gerados** (não versionar):

| Arquivo | Conteúdo |
|---------|----------|
| `~/.config/revisar-tarefa/monday.env` | `MONDAY_BOARD_ID`, `MONDAY_COL_*`, índices QA/Fazendo |
| `~/.config/revisar-tarefa/monday-status-labels.json` | colunas status do item principal |
| `~/.config/revisar-tarefa/monday-subitem-status-labels.json` | board subtarefas + labels |
| `~/.config/revisar-tarefa/monday-board.json` | snapshot do board |

**Seção 7 (subtarefas):** busca um item com `subitems` no board pai e lê `subitems[].board` (type `sub_items_board`). Override: `MONDAY_SUBITEM_BOARD_ID=<id>`.

Variáveis extras no `monday.env`:

| Variável | Uso |
|----------|-----|
| `MONDAY_COL_NAME` | sempre `name` |
| `MONDAY_COL_DOCS` | ids de colunas file/doc/text (projetos) |
| `MONDAY_STATUS_LABEL_QA` / `_FAZENDO` | texto para `change_simple_column_value` |
| `MONDAY_STATUS_INDEX_*` | índice do label (referência / mutation JSON) |

## 4. Queries usadas pela skill

### 4.1 Board **Dia a Dia**

```graphql
query {
  boards(limit: 50) {
    id
    name
    columns { id title type }
  }
}
```

Filtrar `name == "Dia a Dia"`.

### 4.2 Item por título exato

```graphql
query ($boardId: ID!, $title: String!) {
  items_page_by_column_values(
    board_id: $boardId
    columns: [{ column_id: "name", column_values: [$title] }]
  ) {
    items {
      id
      name
      url
      column_values {
        id
        text
        value
        column { title type }
      }
      updates(limit: 50) {
        id
        body
        text_body
        created_at
      }
    }
  }
}
```

Variables: `{ "boardId": "MONDAY_BOARD_ID", "title": "título exato" }`

- 0 items → não encontrado
- 2+ items → ambíguo (listar `id` + `url`)

### 4.3 Ler Branch e Status

Das `column_values` do item, onde `column.title` é:

- **Branch** → `text` (branch Git)
- **Status** → `text` ou parse de `value` (labels: `Fazendo`, `QA`, `Aguardando deploy`)

### 4.4 Atualizar Status (Mon2)

Coluna tipo **status** — `value` é JSON com índice ou label do status. Exemplo (ajustar índice após discovery):

```graphql
mutation ($boardId: ID!, $itemId: ID!, $columnId: String!, $value: JSON!) {
  change_column_value(
    board_id: $boardId
    item_id: $itemId
    column_id: $columnId
    value: $value
  ) {
    id
  }
}
```

Labels acordados:

| Situação | Label |
|----------|--------|
| Sem itens 1/2 no review | **QA** |
| Com itens 1/2 | **Fazendo** |

O índice do label no JSON depende da ordem no board — obter com `change_simple_column_value` ou listar settings da coluna Status no discovery.

Alternativa suportada pela API:

```graphql
mutation {
  change_simple_column_value(
    board_id: $boardId
    item_id: $itemId
    column_id: $columnId
    value: "QA"
  ) { id }
}
```

(`value` = texto do label quando a API aceita label direto.)

## 5. Projetos (texto livre)

Ordem de leitura:

1. Colunas **documento** / files (texto e links)
2. **Descrição** do item
3. **updates** (mais recentes primeiro)

Regex úteis no agente:

- `gitlab.baladapp.com.br/([\w.-]+/[\w.-]+)`
- paths `baladapp/...` ou `grupo/repo`

Sempre passar pela confirmação **C1** antes do GitLab.

## 6. Teste manual rápido

```bash
curl -s -X POST https://api.monday.com/v2 \
  -H "Authorization: $MONDAY_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"query { me { id name } }"}' | jq .
```

## 7. Erros comuns

| Erro | Causa |
|------|--------|
| 401 | Token inválido ou revogado |
| Cannot query field | Query malformada ou versão API |
| Item não encontrado | Título não exato ou board errado |
| Status não muda | `column_id` errado ou `value`/label incorreto |

## Relacionado

- Skill principal: [SKILL.md](SKILL.md)
- Leitura item/doc: `~/.agents/skills/monday-task-info/SKILL.md`
- Requisitos de usuário: [gerar-requisitos-de-usuario/SKILL.md](gerar-requisitos-de-usuario/SKILL.md)
- Verificação de requisitos: [verificar-requisitos-usuario/SKILL.md](verificar-requisitos-usuario/SKILL.md)
- Publicação doc Revisar código: [gerar-requisitos-de-codigo/SKILL.md](gerar-requisitos-de-codigo/SKILL.md)
- Avaliação: [avaliar-tarefa/SKILL.md](avaliar-tarefa/SKILL.md)
- Pós avaliação (status): [pos-avaliacao/SKILL.md](pos-avaliacao/SKILL.md)
- GitLab / glab: [reference-glab.md](reference-glab.md)
- Fluxo Hermes legado: `~/projetos/ia-config/skills/agendar-revisao-tarefa/reference.md`
