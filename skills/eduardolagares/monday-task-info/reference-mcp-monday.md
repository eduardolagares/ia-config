# Monday — receitas MCP (`revisar-tarefa` / `monday-task-info`)

**Validado neste ambiente:** servidor `user-monday-mcp`, `serverStatus: ready`.

## Canal único

| Usar | Proibido |
|------|----------|
| `CallMcpTool` no Monday MCP da IDE | `MONDAY_API_TOKEN`, `monday.env` como auth |
| Tools nomeadas abaixo | GraphQL/REST manual fora do MCP; scripts de API |
| OAuth em **Settings → MCP → Monday** | Pedir token no chat; inventar dados se MCP falhar |

**Resolver `server`:** `GetMcpTools` padrão `monday` (ex. `user-monday-mcp`, `plugin-monday.com-monday`). Se `needsAuth` → `mcp_auth`.

**Forma fixa:**

```text
CallMcpTool
  server: <monday-mcp-da-ide>   # ex. user-monday-mcp
  toolName: <tool>
  arguments: { ... }
```

---

## IDs fixos (Dia a dia)

| Entidade | ID |
|----------|-----|
| Board **Dia a dia** (tarefas) | `4571892384` |
| Board subtarefas | `4571892432` |
| Workspace principal (típico) | `7278225` |
| Grupo **Revisão manual de código** | `group_mm5j20e` (confirmar via `get_board_info` se duvidar) |

### Colunas — tarefa (board `4571892384`)

| Título | `column_id` |
|--------|-------------|
| Branch | `texto` |
| Documento | `monday_doc` |
| Status consolidado | `status_1` |
| Subelementos | `subelementos` |

Labels úteis `status_1`: `Fazendo`, `Revisão manual de código`, `QA`, `Aguardando deploy`, …

### Colunas — subtarefa (board `4571892432`)

| Título | `column_id` |
|--------|-------------|
| Documento | `monday_doc` |
| Status | `status` |
| Owner | `person` |

Labels úteis `status`: `Aguardando correção`, `Concluída`, `Fazendo`, `A fazer`, …

---

## Descoberta / listagens

### Workspaces

```json
{ "toolName": "list_workspaces", "arguments": {} }
```

### Quadros por nome

```json
{
  "toolName": "search",
  "arguments": {
    "searchType": "BOARD",
    "searchTerm": "Dia a dia",
    "limit": 20
  }
}
```

`search` **exige** `searchTerm` não vazio. Para listar boards de um workspace sem frase → `workspace_info`.

### Metadados do board (grupos, colunas, labels)

```json
{
  "toolName": "get_board_info",
  "arguments": { "boardId": 4571892384 }
}
```

Usar para: resolver `groupId` por título; confirmar `column_id` / labels antes de `change_item_column_values`.

---

## Passo 1 — Ler tarefa (`monday-task-info`)

### 1) Item por título (+ subtarefas + colunas)

```json
{
  "toolName": "get_board_items_page",
  "arguments": {
    "boardId": 4571892384,
    "searchTerm": "<título exato>",
    "includeColumns": true,
    "includeSubItems": true,
    "limit": 25
  }
}
```

| Resultado | Ação |
|-----------|------|
| 0 itens | Erro |
| 2+ | Listar `id`+url; pedir qual |
| 1 | Seguir |

Branch = coluna `texto`. `doc_object_id` = valor da coluna `monday_doc` (object id do doc).

### 2) Item por id (owners merge, etc.)

```json
{
  "toolName": "get_board_items_page",
  "arguments": {
    "boardId": 4571892432,
    "itemIds": [12052260363, 12052260364],
    "includeColumns": true,
    "limit": 10
  }
}
```

### 3) Documento (markdown)

```json
{
  "toolName": "read_docs",
  "arguments": {
    "mode": "content",
    "type": "object_ids",
    "ids": ["<doc_object_id>"]
  }
}
```

### 4) Documento com blocos (passo 7 — marcar checkboxes)

```json
{
  "toolName": "read_docs",
  "arguments": {
    "mode": "content",
    "type": "object_ids",
    "ids": ["<doc_object_id>"],
    "include_blocks": true,
    "blocks_limit": 100
  }
}
```

Paginar com `blocks_page` se houver mais blocos.

Updates do item (opcional): `get_updates` com o `item_id`.

Payload enorme → só context-mode (`ctx_index` / `ctx_search`). Sem cache em disco.

---

## Passos 6–8 — Escrita

### Append markdown no doc (passo 6 / Merge requests)

```json
{
  "toolName": "update_doc",
  "arguments": {
    "object_id": "<doc_object_id>",
    "operations": [
      {
        "operation_type": "add_markdown_content",
        "markdown": "## Revisão de código — 2026-07-29\n\n- [ ] **1.1** — …"
      }
    ]
  }
}
```

Preferir `object_id` (URL / coluna) ou `doc_id` (campo `id` de `read_docs`).

### Marcar checkbox cumprido (passo 7)

Após `read_docs` com `include_blocks: true`, achar `list_item` / CHECK_LIST com `checked: false`:

```json
{
  "toolName": "update_doc",
  "arguments": {
    "object_id": "<doc_object_id>",
    "operations": [
      {
        "operation_type": "update_block",
        "block_id": "<block_id>",
        "content": {
          "block_content_type": "list_item",
          "checked": true,
          "delta_format": [
            { "insert": { "text": "**1.1** — …" } },
            { "insert": { "text": "\n" } }
          ]
        }
      }
    ]
  }
}
```

(Manter o texto do bullet; só forçar `checked: true`. Último delta **obrigatório** `{text:"\\n"}`.)

### Criar doc na subtarefa Revisar código

```json
{
  "toolName": "create_doc",
  "arguments": {
    "location": "item",
    "item_id": 12052260363,
    "column_id": "monday_doc",
    "doc_name": "Revisar código",
    "markdown": "# Revisar código\n\nDocumento gerado por /revisar-tarefa.\n"
  }
}
```

### Status / owner (`change_item_column_values`)

Status subtarefa:

```json
{
  "toolName": "change_item_column_values",
  "arguments": {
    "boardId": 4571892432,
    "itemId": 12052260363,
    "columnValues": "{\"status\": {\"label\": \"Aguardando correção\"}}"
  }
}
```

Status consolidado (tarefa):

```json
{
  "toolName": "change_item_column_values",
  "arguments": {
    "boardId": 4571892384,
    "itemId": 12052222930,
    "columnValues": "{\"status_1\": {\"label\": \"Revisão manual de código\"}}"
  }
}
```

Owner merge (people):

```json
{
  "toolName": "change_item_column_values",
  "arguments": {
    "boardId": 4571892432,
    "itemId": 12052260363,
    "columnValues": "{\"person\": {\"personsAndTeams\": [{\"id\": 40775735, \"kind\": \"person\"}]}}"
  }
}
```

**Não** inventar labels — só as do `get_board_info`.

### Mover para grupo (passo 8 — revisão manual)

1. `get_board_info` → `groups[]` título **Revisão manual de código** → `id` (típico `group_mm5j20e`).
2. `all_api_write`:

```json
{
  "toolName": "all_api_write",
  "arguments": {
    "query": "mutation ($itemId: ID!, $groupId: String!) { move_item_to_group(item_id: $itemId, group_id: $groupId) { id } }",
    "variables": "{\"itemId\": \"12052222930\", \"groupId\": \"group_mm5j20e\"}"
  }
}
```

`variables` é **string JSON**. Grupo ausente → **parar** (não usar QA/Deploy).

---

## Mapa passo → tools

| Passo | Tools |
|-------|--------|
| 1 | `get_board_items_page`, `read_docs` (+ `get_updates` opcional) |
| 6 | `read_docs`, `update_doc` / `create_doc` |
| 7 | `read_docs` (`include_blocks`), `update_doc` (`update_block` + `checked`) |
| 8 | `change_item_column_values`, `get_board_info`, `all_api_write` (`move_item_to_group`), `update_doc` / `create_doc` (Merge requests) |

## Checklist

1. Monday MCP `ready`?
2. Só `CallMcpTool` — zero token/REST.
3. Labels e `groupId` do board real.
4. MCP falhou → **parar**; não simular escrita.
