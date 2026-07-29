# Monday / GitLab — referências MCP (`revisar-tarefa`)

## Monday

**Canal único:** MCP Monday da IDE — [../monday-task-info/reference-mcp-monday.md](../monday-task-info/reference-mcp-monday.md).

Leitura: skill **`monday-task-info`**. Escrita (passos 6–8): sub-skills de `revisar-tarefa`. Sem token, GraphQL, REST ou scripts de API.

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
| **Revisão manual de código** | Destino obrigatório quando veredito = `pode_avancar_para_revisao_manual` (`move_item_to_group` via MCP; `groupId` típico `group_mm5j20e`) |

## GitLab

Passo 3 (diff) e MRs (passo 8, **qualquer** veredito): **só** MCP GitLab da IDE — [reference-gitlab-mcp.md](reference-gitlab-mcp.md). Sem token, REST ou scripts de API.

## Cache

Só MCP **context-mode** — [SKILL.md](SKILL.md) § Cache. Sem context-mode → sem cache.
