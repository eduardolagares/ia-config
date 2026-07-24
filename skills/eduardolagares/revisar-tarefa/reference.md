# Monday — referência MCP (`revisar-tarefa`)

**Único canal Monday:** `CallMcpTool` com **`server`: `plugin-monday.com-monday`** (plugin Monday ligado no Cursor).

Não existem scripts GraphQL nem `MONDAY_API_TOKEN` neste pacote. Leitura: skill **`monday-task-info`**. Escrita (passos 6–8): sub-skills de `revisar-tarefa`.

Detalhes: [../monday-task-info/reference-mcp-monday.md](../monday-task-info/reference-mcp-monday.md).

## IDs fixos (boards)

| Entidade | ID |
|----------|-----|
| Tarefa principal (Dia a dia) | `4571892384` |
| Subtarefas | `4571892432` |

## Colunas (títulos — confirmar com `get_board_info` se o board mudar)

| Uso | Coluna / id típico |
|-----|-------------------|
| Branch | `texto` |
| Status consolidado (tarefa) | `status_1` |
| Status subtarefa | `status` |
| Documento | `monday_doc` |
| Owner subtarefa | `person` |

## Grupos (board principal — confirmar com `get_board_info`)

| Título exato | Uso |
|--------------|-----|
| **Revisão manual de código** | Destino obrigatório quando veredito = `pode_avancar_para_revisao_manual` (`move_item_to_group`; `groupId` típico `group_mm5j20e`) |

## Cache local

`monday-task-info/cache/tasks-by-title.json` — preenchido no passo 1 via `write-task-cache.sh` após leitura MCP. Usado pelo hook `prefetch-diff` (passo 3).

## GitLab

Passo 3 e MRs (passo 8): [reference-gitlab-api.md](reference-gitlab-api.md). GitLab MCP proibido: [reference-gitlab-mcp.md](reference-gitlab-mcp.md).
