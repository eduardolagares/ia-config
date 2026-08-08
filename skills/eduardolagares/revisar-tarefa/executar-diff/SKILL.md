---
name: revisar-tarefa-executar-diff
description: >-
  Passo 3 de revisar-tarefa: obtém diff da branch vs master via GitLab MCP da IDE
  e entrega "## Diff". Use após gerar-requisitos-de-usuario ou com
  "executar diff da tarefa", "diff gitlab revisar".
disable-model-invocation: true
VERSION: "3.4.0"
---

# revisar-tarefa — executar DIFF (passo 3)

Sub-skill dedicada ao **passo 3** de `revisar-tarefa`. Leitura no GitLab, com **uma** escrita permitida: abrir o MR da branch quando ele ainda não existe (§ Fonte dos hunks).

**Canal obrigatório:** **GitLab MCP** instalado na IDE de quem executa — [reference-gitlab-mcp.md](../reference-gitlab-mcp.md) (**receitas JSON completas**).

**Proibido:** `GITLAB_TOKEN`, PAT, REST `/api/v4`, curl/`fetch` com Bearer, scripts de API.

**Rede:** GitLab só via **VPN**; assume-se VPN **já ativa** ([SKILL.md](../SKILL.md) § GitLab — rede). Não pedir para ligar VPN por defeito.

**Cache:** metadados **só** via MCP context-mode ([SKILL.md](../SKILL.md) § Cache). **Nunca** indexar o conteúdo do diff; se precisar do patch completo, **re-obter** via GitLab MCP. Sem context-mode → sem cache de metadados.

## Fonte dos hunks

Neste GitLab MCP, **`mr_review.raw_diffs` é o único action que devolve patch com hunks**. `repository.compare`, `repository.commit_diff` e `mr_review.changes_get` devolvem só commits e lista de ficheiros — `unidiff: true` **não** resolve. Não gastar turnos a tentar.

Consequência: **sem MR não há diff revisável**. Se a branch não tiver MR aberto, o passo 3 **abre** o MR (`source` → `master`) e só então lê `raw_diffs`.

| Guarda | Regra |
|--------|-------|
| Antes de criar | `repository.compare` (`from: master`, `to: <branch>`) tem de mostrar **≥1 commit e ≥1 ficheiro** |
| Branch vazia vs `master` | **Não** criar MR; **Erro:** `branch sem diferenças vs master` nesse repo |
| Título do MR | Título da tarefa Monday (passo 1); sem título → nome da branch |
| Duplicação | Passo 8 reencontra o MR via `merge_request.list` e regista `existing` — **nunca** abrir um segundo |
| `method` | Sempre `mcp_mr_diff`. **`mcp_compare` foi removido** — compare é inventário, não diff |

## Diffs grandes

1. Resumir no chat (até **~400 linhas** por repo se truncado; avisar).
2. Metadados (`project_id`, MR `iid`/`web_url`, branch, método) → **só** `ctx_index` no context-mode (se `ready`). Sem context-mode → sem cache.
3. Se um passo seguinte precisar do diff completo ou o chat estiver truncado → **re-obter** via `mr_review.raw_diffs`, usando IDs do context-mode (`ctx_search`) ou da saída atual do passo 3. **Proibido** tratar patch antigo (chat/disco/índice de conteúdo) como fonte da comparação.
4. **Proibido** gravar `.diff` / JSON de patch em disco; **proibido** indexar o patch no context-mode.

## Receita rápida (copiar)

`CallMcpTool` → `server: <gitlab>` → `toolName: gitlab_execute_action`:

1. `merge_request.list` — `project_id`, `source_branch`, `state: opened`
2. Se MR → `mr_review.raw_diffs` — `project_id`, `merge_request_iid` → `method: mcp_mr_diff`
3. Senão → `repository.compare` (`from: master`, `to: <branch>`) para conferir conteúdo → `merge_request.create` (`target_branch: master`) → voltar ao ponto 2

Não chamar `gitlab_find_action` se estes actions bastarem.

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

Somente **GitLab MCP** (`CallMcpTool` → `gitlab_execute_action`). Não inferir alterações lendo arquivos do disco; `method` é sempre `mcp_mr_diff`.

## Ordem de execução (obrigatória)

### 0. MCP GitLab ready (obrigatório)

No início do passo 3:

1. `GetMcpTools` (padrão `gitlab`) — confirmar servidor GitLab da IDE e `serverStatus` `ready`.
2. Se `needsAuth` → `mcp_auth` nesse servidor; se falhar → parar (`Status: indisponível`).
3. Reportar no chat qual `server` está a usar.

### 1. Diff por repo (MCP)

Para **cada** `namespace/project` em **Projetos alterados** / passo 1:

| Ordem | Ação | Resultado |
|-------|------|-----------|
| 1 | `merge_request.list` — `project_id`, `source_branch` = branch, MRs abertos | `iid` ou nenhum |
| 2 | MR → `mr_review.raw_diffs` | hunks → `method: mcp_mr_diff` |
| 3 | Sem MR → `repository.compare` — `from: master`, `to: <branch>` | inventário (commits + ficheiros), **sem** hunks |
| 4 | Inventário vazio | **Erro:** `branch sem diferenças vs master`; não criar MR |
| 5 | Inventário com conteúdo → `merge_request.create` (`target_branch: master`) | `iid` → voltar à ordem 2 |

`project_id` = path `namespace/project` (ex. `baladapp/ingressos`).

Params JSON: [reference-gitlab-mcp.md](../reference-gitlab-mcp.md). Só usar `gitlab_find_action` se um action novo for necessário. Diffs grandes → § Diffs grandes.

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

## Saída obrigatória

Entregar **somente** o bloco abaixo. **Não** repetir passos 1 ou 2.

```markdown
## Diff

**Branch:** `<branch>` · **Base:** `master` · **Status:** `ok` | `parcial` | `indisponível`

### `<namespace/project>`

| Campo | Valor |
|-------|-------|
| Método | `mcp_mr_diff` |
| MR | `<!iid> — <url>` (+ *criado no passo 3* se aplicável) |
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
| Compare devolveu só commits/ficheiros | Esperado — não é erro do MCP; seguir para criar o MR e ler `raw_diffs` |
| Branch sem diferenças vs `master` | **Erro:** no repo; não criar MR; tende a `parcial` / `indisponível` |
| `merge_request.create` falhou | **Erro:** no repo; sem hunks não há `ok` |
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
