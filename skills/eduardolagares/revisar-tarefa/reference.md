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

## Subtarefa **Revisar código** (criar se ausente)

Sempre que um passo precisar desta subtarefa e ela **não** existir sob a tarefa:

1. `get_board_items_page` — `itemIds: [<tarefa>]`, `boardId: 4571892384`, `includeSubItems: true`.
2. Procurar subtarefa **`Revisar código`** ou **`Revisão de código`**.
3. Ausente → `create_item`:

| Campo | Valor |
|-------|-------|
| `boardId` | `4571892432` |
| `name` | `Revisar código` |
| `parentItemId` | `item_id` da tarefa principal |
| `columnValues` | `{"status": {"label": "A fazer"}}` (string JSON) |

4. Usar o `id` retornado no restante do fluxo.

**Não** criar outras subtarefas (Executar, Testar, Deploy) por esta regra — só **Revisar código**.

## Status consolidado → grupo (automação Monday)

**Regra:** alterar **só** `status_1` (status consolidado). A **automação do Monday** move a tarefa para o grupo. **Nunca** usar `move_item_to_group`.

| Label `status_1` | Grupo (automação) |
|------------------|-------------------|
| **Fazendo** | **Atribuídas** |
| **Revisão automática de código** | grupo de revisão automática |
| **Revisão manual de código** | grupo de revisão manual |

Usos no passo 8: `precisa_de_correcao` → **Fazendo**; `pode_avancar_para_revisao_manual` → **Revisão manual de código**.

## GitLab

Passo 3 (diff) e MRs (passo 8, **qualquer** veredito): **só** MCP GitLab da IDE — [reference-gitlab-mcp.md](reference-gitlab-mcp.md). Sem token, REST ou scripts de API.

## Cache

Só MCP **context-mode** — [SKILL.md](SKILL.md) § Cache. Sem context-mode → sem cache.
