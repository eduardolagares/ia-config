# Monday — conexão integrada ao Cursor

## Canal único

| Usar | Proibido |
|------|----------|
| `CallMcpTool`, `server`: **`plugin-monday.com-monday`** | Qualquer outro `server` |
| Tools do plugin (`get_board_items_page`, `read_docs`, `update_doc`, `change_item_column_values`, …) | Scripts ou ficheiros deste repo que chamem `api.monday.com` |
| OAuth em **Cursor → Settings → MCP → Monday** | `MONDAY_API_TOKEN`, `monday.env`, GraphQL manual |

Schemas: `mcps/plugin-monday.com-monday/tools/<tool>.json`.

## Checklist do agente

1. Pasta `mcps/plugin-monday.com-monday/tools/` existe?
2. Ler schema antes de cada chamada.
3. `server` exatamente `plugin-monday.com-monday`.
4. Erro de auth → utilizador reautoriza Monday no Cursor (não pedir PAT).

## IDs fixos

| Entidade | ID |
|----------|-----|
| Board Dia a dia | `4571892384` |
| Board subtarefas | `4571892432` |

Colunas usuais: Branch `texto`, status pai `status_1`, doc `monday_doc`, subtarefa status `status`, owner `person`.

## Fluxo passo 1 (leitura)

### 1. Item + subtarefas

`get_board_items_page`: `boardId` 4571892384, título exato, `includeColumns` + `includeSubItems` true.

### 2. Documento

`read_docs`: `mode` content, `type` object_ids, ids do doc principal (e Revisar código se necessário).

### 3. Projetos

Inferir `baladapp/<repo>` do texto retornado pelo MCP.

### 4. Cache

JSON mínimo:

```json
{
  "item_id": "...",
  "item_url": "...",
  "branch": "...",
  "status_consolidado": "...",
  "projetos_alterados": ["baladapp/repo"],
  "doc_object_id": "...",
  "blocks_as_markdown": "...",
  "subitems": {
    "Executar": { "item_id": "...", "status": "...", "doc_object_id": null },
    "Revisar código": { "item_id": "...", "status": "...", "doc_object_id": "..." },
    "Testar": { "item_id": "...", "status": "...", "doc_object_id": null }
  },
  "fetched_at": "YYYY-MM-DDTHH:MM:SSZ"
}
```

```bash
scripts/write-task-cache.sh "<título exato>" < payload.json
```

## Passos 6–8 (`revisar-tarefa`)

Mesmo `server`: `update_doc`, `create_doc`, `change_item_column_values`, etc.
