---
name: revisar-tarefa-executar-diff
description: >-
  Passo 3 de revisar-tarefa: obtém diff da branch vs master via GitLab MCP da IDE
  e entrega "## Diff". Use após gerar-requisitos-de-usuario ou com
  "executar diff da tarefa", "diff gitlab revisar".
disable-model-invocation: true
VERSION: "3.1.0"
---

# revisar-tarefa — executar DIFF (passo 3)

Sub-skill dedicada ao **passo 3** de `revisar-tarefa`. **Somente leitura** no GitLab.

**Canal obrigatório:** **GitLab MCP** instalado na IDE de quem executa — [reference-gitlab-mcp.md](../reference-gitlab-mcp.md).

**Proibido:** `GITLAB_TOKEN`, PAT, REST `/api/v4`, curl/`fetch` com Bearer, scripts de API.

**Rede:** GitLab só via **VPN**; assume-se VPN **já ativa** ([SKILL.md](../SKILL.md) § GitLab — rede). Não pedir para ligar VPN por defeito.

**Cache:** só MCP **context-mode** ([SKILL.md](../SKILL.md) § Cache). Sem context-mode → sem cache.

Invocação isolada (com passo 1 já no contexto):

```
/revisar-tarefa-executar-diff
```

Ou seguir automaticamente após o passo 2 no fluxo `/revisar-tarefa`.

## Pré-requisito

| Dado | Obrigatório |
|------|-------------|
| **Branch** | Sim — tabela do passo 1 (`monday-task-info`) |
| **Repos GitLab** | Sim — `namespace/project` (updates, doc, `impacto:` ou confirmados com usuário) |
| **GitLab MCP** | Sim — servidor ligado e `ready` (ou `mcp_auth`) na IDE |

Passo 2 (requisitos de usuário) não bloqueia a execução. Ordem completa: **1 → 2 → 3 → 4 → 5 → 6 → 7** ([avaliar-tarefa](../avaliar-tarefa/SKILL.md)) **→ 8** ([pos-avaliacao](../pos-avaliacao/SKILL.md)).

Sem branch → parar. Sem repo → inferir ou perguntar; não chutar path GitLab.

## Fontes válidas

Somente **GitLab MCP** (`CallMcpTool` → `gitlab_execute_action`). Não inferir alterações lendo arquivos do disco nem marcar `method` fora de `mcp_mr_diff` \| `mcp_compare`.

## Ordem de execução (obrigatória)

### 0. MCP GitLab ready (obrigatório)

No início do passo 3:

1. `GetMcpTools` (padrão `gitlab`) — confirmar servidor GitLab da IDE e `serverStatus` `ready`.
2. Se `needsAuth` → `mcp_auth` nesse servidor; se falhar → parar (`Status: indisponível`).
3. Reportar no chat qual `server` está a usar.

### 1. Diff por repo (MCP)

Para **cada** `namespace/project` em **Projetos alterados** / passo 1:

| Ordem | Ação | `method` |
|-------|------|----------|
| 1 | `merge_request.list` — `project_id`, `source_branch` = branch, MRs abertos | — |
| 2 | MR → `mr_review.raw_diffs` (ou `mr_review.changes_get`) | `mcp_mr_diff` |
| 3 | Senão → `repository.compare` — `from: master`, `to: <branch>` | `mcp_compare` |

`project_id` = path `namespace/project` (ex. `baladapp/ingressos`).

Usar `gitlab_find_action` se o schema de params for incerto. Diffs grandes → § Diffs grandes.

### 2. Falha total

Se o MCP falhar em todos os repos:

1. Informar bloqueio (MCP GitLab / auth / rede)
2. Entregar `## Diff` com **Erro:** por repo e **`Status: indisponível`** — sem inventar diff nem contornar com REST/token
3. **Não** seguir para passo 8 — passos 4–7 podem documentar o bloqueio; status/owners ficam intactos

## Status do diff (bloqueio do passo 8)

Na saída **`## Diff`**, linha obrigatória após **Branch/Base:**

| `Status` | Critério | Passo 8 |
|----------|----------|---------|
| **`ok`** | Cada repo de **Projetos alterados** (passo 1) tem subsecção com diff via MCP; sem **Erro:**; fence `diff` com ≥1 linha de hunk | Permitido |
| **`parcial`** | Pelo menos um repo **ok** e pelo menos um esperado falhou (ausente, **Erro:** ou diff vazio) | **Proibido** |
| **`indisponível`** | Nenhum repo com diff válido; ou passo 3 abortado antes de montar diff | **Proibido** |

## Resolver repositórios

1. Paths em doc/updates: `gitlab.baladapp.com.br/...`, `baladapp/repo`.
2. Update `impacto: <nome>` → `baladapp/<nome>`.
3. `baladapp-react-components` → `baladapp/baladapp-react-components`.
4. `ingressos-repo` → `baladapp/ingressos` (submodule do projeto ingressos).
5. Ambíguo → **uma** pergunta ao usuário.

## Diffs grandes

1. Resumir no chat (até **~400 linhas** por repo se truncado; avisar).
2. Se precisar **reconsultar** o diff completo depois: só via MCP **context-mode** (`ctx_index` + `ctx_search`, ou `ctx_execute` / `ctx_execute_file`).
3. Context-mode **ausente** / não `ready` → **não** cachear; seguir só com o resumo no chat. **Proibido** gravar `.diff` / JSON em disco como cache.

## Saída obrigatória

Entregar **somente** o bloco abaixo. **Não** repetir passos 1 ou 2.

```markdown
## Diff

**Branch:** `<branch>` · **Base:** `master` · **Status:** `ok` | `parcial` | `indisponível`

### `<namespace/project>`

| Campo | Valor |
|-------|-------|
| Método | `mcp_mr_diff` \| `mcp_compare` |
| MR | `<!iid> — <url>` ou — |
| Target | `<target_branch>` ou `master` |
| Tamanho | `<bytes ou linhas>` (+ nota *truncado* se aplicável) |

```diff
<diff>
```
```

(Repetir `###` por repo.)

### Regras de formato

- Título: **`## Diff`**
- Linha **`Status:`** obrigatória — recalcular após todos os repos (tabela § Status do diff)
- Erro em um repo: linha **Erro:** na tabela; seguir nos demais; tende a `parcial` ou `indisponível`
- Fence `diff` vazio proibido em repo marcado como obtido com sucesso

## Erros

| Situação | Ação |
|----------|------|
| Branch vazia no Monday | Parar |
| MCP GitLab ausente / auth falhou | Parar; pedir GitLab ligado em Settings → MCP |
| Diff falhou em todos os repos | `Status: indisponível`; não inventar diff; passo 8 proibido |
| `Status` ≠ `ok` | Passo 8 proibido — ver [pos-avaliacao](../pos-avaliacao/SKILL.md) |
| Tentação de REST/`GITLAB_TOKEN` | Recusar — só MCP da IDE |
| Repo ambíguo | Perguntar antes do MCP |

## Skills relacionadas

| Skill | Papel |
|-------|--------|
| `revisar-tarefa` | Orquestra passos 1–3 |
| `monday-task-info` | Branch, projetos (MCP Monday) |
| `revisar-tarefa-gerar-requisitos-de-usuario` | Passo 2 |
| `revisar-tarefa-code-review-diff` | Passo 4 — consome `## Diff` |
| [reference-gitlab-mcp.md](../reference-gitlab-mcp.md) | Canal GitLab MCP |
