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

### Colunas — tarefa (board `4571892384`)

| Título | `column_id` |
|--------|-------------|
| Branch | `texto` |
| Documento | `monday_doc` |
| **Ação** | `color_mm5tr97v` (confirmar com `get_board_info` se o id mudar) |
| Subelementos | `subelementos` |

Labels úteis **Ação:** `Concluir`, `Rejeitar`.

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

### Metadados do board (colunas, labels)

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

### Criar subtarefa Revisar código (se ausente)

Títulos aceitos na busca (qualquer um = a subtarefa de revisão): `Revisar código`, `Revisar código automático`, `Revisar código auto`, `Revisar código automaticamente`. Se nenhum existir → criar:

```json
{
  "toolName": "create_item",
  "arguments": {
    "boardId": 4571892432,
    "name": "Revisar código automaticamente",
    "parentItemId": 12052222930,
    "columnValues": "{\"status\": {\"label\": \"A fazer\"}}"
  }
}
```

`parentItemId` = tarefa principal. Usar sempre que `/revisar-tarefa` precisar da subtarefa e nenhum título aceite existir.

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

Coluna **Ação** (tarefa — aprovar / reprovar):

```json
{
  "toolName": "change_item_column_values",
  "arguments": {
    "boardId": 4571892384,
    "itemId": 12052222930,
    "columnValues": "{\"color_mm5tr97v\": {\"label\": \"Concluir\"}}"
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

### Decisão da revisão (passo 8)

Na tarefa principal, **só** gravar coluna **Ação**: **`Concluir`** (aprovou) ou **`Rejeitar`** (reprovou). A automação do Monday faz o restante. Resolver o id por `title: Ação` via `get_board_info` se necessário.

```json
{
  "toolName": "change_item_column_values",
  "arguments": {
    "boardId": 4571892384,
    "itemId": 12052222930,
    "columnValues": "{\"color_mm5tr97v\": {\"label\": \"Concluir\"}}"
  }
}
```

---

## Mapa passo → tools

| Passo | Tools |
|-------|--------|
| 1 | `get_board_items_page`, `read_docs` (+ `get_updates` opcional) |
| 6 | `create_item` (subtarefa Revisar código se ausente), `read_docs`, `update_doc` / `create_doc` |
| 7 | `read_docs` (`include_blocks`), `update_doc` (`update_block` + `checked`); criar subtarefa se ausente |
| 8 | `create_item` (subtarefa se ausente), `change_item_column_values`, `update_doc` / `create_doc` (Merge requests / Resultado) |

## Checklist

1. Monday MCP `ready`?
2. Só `CallMcpTool` — zero token/REST.
3. Labels do board real (`get_board_info` se duvidar).
4. MCP falhou → **parar**; não simular escrita.
