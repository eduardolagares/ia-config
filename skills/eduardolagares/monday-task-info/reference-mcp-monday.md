# Monday — conexão MCP na IDE (`revisar-tarefa` / `monday-task-info`)

## Canal único

| Usar | Proibido |
|------|----------|
| `CallMcpTool` no **servidor Monday MCP** instalado na IDE de quem executa | `MONDAY_API_TOKEN`, `monday.env` como auth, curl/`fetch` contra `api.monday.com` |
| Tools do MCP (`get_board_items_page`, `read_docs`, `update_doc`, `change_item_column_values`, `all_api_write`, …) | GraphQL/REST manual fora do MCP; scripts que chamem a API Monday |
| OAuth / auth do MCP em **Cursor → Settings → MCP → Monday** | Pedir token/PAT no chat; inventar dados se o MCP falhar |

**Resolver o `server`:** usar o id do Monday MCP **desta** IDE (`GetMcpTools` com padrão `monday`, ou pasta `mcps/*monday*`). Exemplos comuns: `plugin-monday.com-monday`, `user-monday-mcp`. **Não** hardcodar um id se o da sessão for outro — usar o que estiver ligado e `ready`.

Se `serverStatus` for `needsAuth` → chamar `mcp_auth` nesse servidor (utilizador autoriza na IDE). Não pedir token no chat.

Schemas: pasta `mcps/<server-id>/tools/<tool>.json` do servidor resolvido — ler antes de cada tool pouco usada.

## Checklist do agente

1. Monday MCP existe e está `ready` (ou autenticar com `mcp_auth`)?
2. `GetMcpTools` / schema antes de executar tools pouco usadas.
3. Só `CallMcpTool` no servidor Monday da IDE — zero REST/GraphQL/token/script de API.
4. MCP indisponível → **parar**; não inventar contexto nem simular escrita.

## IDs fixos

| Entidade | ID |
|----------|-----|
| Board Dia a dia | `4571892384` |
| Board subtarefas | `4571892432` |

Colunas usuais: Branch `texto`, status pai `status_1`, doc `monday_doc`, subtarefa status `status`, owner `person`.

## Passo 1 — leitura (`monday-task-info`)

### 1. Item + subtarefas

`get_board_items_page`: `boardId` 4571892384, título exato, `includeColumns` + `includeSubItems` true.

### 2. Documento

`read_docs`: `mode` content, `type` object_ids, ids do doc principal (e Revisar código se necessário).

### 3. Projetos

Inferir `baladapp/<repo>` do texto retornado pelo MCP.

### 4. Contexto para passos seguintes

Entregar a saída markdown no chat. IDs (`item_id`, `doc_object_id`, subtarefas) ficam no contexto da conversa.

Documento / payload Monday **muito grande:** indexar só via MCP **context-mode** (`ctx_index` / `ctx_search`). Sem context-mode → sem cache; resumir no chat. **Proibido** cache em disco ou scripts.

## Passos 6–8 (`revisar-tarefa`) — escrita

Mesmo servidor Monday MCP da IDE: `update_doc`, `create_doc`, `change_item_column_values`, `all_api_write` (ex. `move_item_to_group`), etc. — **sempre** via `CallMcpTool`, nunca API direta.
