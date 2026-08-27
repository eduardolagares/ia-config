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
| **Ação** (decisão da revisão) | Resolver por `title: Ação` — id típico `color_mm5tr97v` |
| Status subtarefa | `status` |
| Documento | `monday_doc` |
| Owner subtarefa | `person` |

Labels da coluna **Ação:** **`Concluir`**, **`Rejeitar`** (a skill grava); **`Avaliar`** (repouso após automação — a skill **não** grava).

**Avanço ao aprovar = gravar Concluir uma vez → aguardar.** Resolver id: `get_board_info(4571892384)` → `title: Ação`. Depois de **Concluir**, **não** encerrar: reler até grupo **Revisão manual de código** e **Ação** **Avaliar**. **Não** repetir **Concluir**. **Não** gravar **Avaliar**. **Não** mover grupo.

## Subtarefa **Revisar código** (criar se ausente)

Sempre que um passo precisar da subtarefa de revisão de código e **nenhum** título aceite existir sob a tarefa:

1. `get_board_items_page` — `itemIds: [<tarefa>]`, `boardId: 4571892384`, `includeSubItems: true`.
2. Procurar subtarefa com título **`Revisar código`**, **`Revisar código automático`**, **`Revisar código auto`** ou **`Revisar código automaticamente`**. Qualquer um = a subtarefa de revisão.
3. Nenhum → `create_item`:

| Campo | Valor |
|-------|-------|
| `boardId` | `4571892432` |
| `name` | `Revisar código automaticamente` |
| `parentItemId` | `item_id` da tarefa principal |
| `columnValues` | `{"status": {"label": "A fazer"}}` (string JSON) |

4. Usar o `id` retornado no restante do fluxo.

**Não** criar outras subtarefas (Executar, Testar, Deploy) por esta regra — só a de revisão de código.

## Decisão da revisão → coluna **Ação** (passo 8)

**Contrato:** na tarefa principal, gravar **Ação** = **`Concluir`** (aprovou) ou **`Rejeitar`** (reprovou) — **uma vez**. Id da coluna: `get_board_info` → `title: Ação` (típico `color_mm5tr97v`).

**Aprovar:** **Concluir** → **aguardar** a automação (grupo **Revisão manual de código** + **Ação** **Avaliar**). A mutation sozinha **não** encerra o passo. **Não** repetir **Concluir**. **Não** gravar **Avaliar**. **Não** mover o grupo.

| Veredito | Label **Ação** |
|----------|----------------|
| `pode_avancar_para_revisao_manual` (aprovou) | **`Concluir`** |
| `precisa_de_correcao` (reprovou) | **`Rejeitar`** |

Exemplo MCP (id típico; substituir se `get_board_info` devolver outro):

```json
{
  "boardId": 4571892384,
  "itemId": 12052222930,
  "columnValues": "{\"color_mm5tr97v\": {\"label\": \"Concluir\"}}"
}
```

## GitLab

Passo 3 (diff) e MRs (passo 8, **qualquer** veredito): **só** MCP GitLab da IDE — [reference-gitlab-mcp.md](reference-gitlab-mcp.md). Sem token, REST ou scripts de API.

## Cache

**Só** MCP **context-mode** — metadados (IDs, títulos, URLs, branch); **nunca** documentos nem diffs. Sem context-mode → sem cache. Comparações sempre sobre a versão mais recente (re-fetch via Monday/GitLab MCP). Detalhe: [SKILL.md](SKILL.md) § Cache.
