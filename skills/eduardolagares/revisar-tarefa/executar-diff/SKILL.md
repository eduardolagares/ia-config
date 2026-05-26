---
name: revisar-tarefa-executar-diff
description: >-
  Passo 3 de revisar-tarefa: obtém diff da branch vs master via cache (hook)
  ou GitLab REST API (gitlab-api-phase3-diff-bundle) e entrega "## Diff".
  Use após gerar-requisitos-de-usuario ou com "executar diff da tarefa", "diff gitlab revisar".
disable-model-invocation: true
VERSION: "2.0.2"
---

# revisar-tarefa — executar DIFF (passo 3)

Sub-skill dedicada ao **passo 3** de `revisar-tarefa`. **Somente leitura** no GitLab.

**Canal obrigatório:** **REST API** (`GITLAB_TOKEN`). Skill `gitlab-api` para auth e padrões.

**Autenticação:** ler **`GITLAB_TOKEN` só das variáveis de ambiente da máquina de quem executa** (shell do utilizador, Terminal integrado, hook). Não colar token no chat; não inventar nem persistir em ficheiros. Ver secção **GitLab — autenticação** em [SKILL.md](../SKILL.md).

**Proibido:** GitLab MCP, `glab`, clone/`git diff` local.

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
| **Título** | Recomendado — validar cache (`--titulo`) |
| **GITLAB_TOKEN** | Sim — **env do executador** (hook/Terminal/`process.env` no `ctx_execute`); nunca no chat |

Passo 2 (requisitos de usuário) não bloqueia a execução. Ordem completa: **1 → 2 → 3 → 4 → 5 → 6 → 7** ([avaliar-tarefa](../avaliar-tarefa/SKILL.md)) **→ 8** ([pos-avaliacao](../pos-avaliacao/SKILL.md)).

Sem branch → parar. Sem repo → inferir ou perguntar; não chutar path GitLab.

## Proibido (sem fallback)

**Nunca** obter diff via clone local ou git no filesystem:

- `git diff` / `git log` em `~/projetos/`, worktrees ou qualquer path local
- inferir alterações lendo arquivos do disco
- marcar `method: compare (local)` ou equivalente na saída

**Nunca** usar:

- **GitLab MCP** (`CallMcpTool`, `/api/v4/mcp`)
- **`glab`** (CLI, scripts `glab-*`, config `glab-cli`)

Fontes válidas: **cache** (`last-diff-bundle.json`), **REST API** (scripts `gitlab-api-*` ou `ctx_execute`).

## Ordem de execução (obrigatória)

### 0. Check GitLab ready (obrigatório)

No início do passo 3, rodar e **mostrar no chat** a tabela:

```bash
scripts/check-gitlab-ready.sh \
  --branch "<branch>" --titulo "<título>"
```

| Check | Ação do agente |
|-------|----------------|
| `GITLAB_TOKEN` = ok | Prosseguir |
| `GITLAB_TOKEN` = missing | Parar; pedir `export` no shell local do executador (não no chat) |
| `cache` = HIT | Montar `## Diff` do cache |
| `api (shell)` = agent_shell_blocked | Normal — usar cache ou `ctx_execute` |

Detalhes: [reference-gitlab-api.md](../reference-gitlab-api.md), skill `gitlab-api`.

### 1. Cache (automático via hook)

Antes do agente rodar, o hook `beforeSubmitPrompt` tenta:

```bash
scripts/prefetch-diff.sh --titulo "<título>" --source hook
```

(grava cache via **REST API** — ambiente do hook / VPN do Mac)

**Validar no passo 3:**

```bash
scripts/read-diff-bundle-cache.sh \
  --branch "<branch>" --titulo "<título>"
```

- `CACHE_HIT` → montar `## Diff` a partir de `bundle.projects[]` e `diff_file` no JSON
- `CACHE_MISS` → seguir para §2

Prefetch manual:

```bash
scripts/prefetch-diff.sh \
  --branch "<branch>" --repo baladapp/repo1 --repo baladapp/repo2
```

TTL padrão: **120 min** (`REVISAR_TAREFA_DIFF_CACHE_TTL_MIN`).

### 2. GitLab REST API (obrigatório em cache miss)

Documentação: [reference-gitlab-api.md](../reference-gitlab-api.md).

**Script (Terminal integrado / hook):**

```bash
scripts/gitlab-api-phase3-diff-bundle.sh \
  <branch> baladapp/repo1 [baladapp/repo2 ...]
```

| Ordem | Ação | `method` no JSON |
|-------|------|------------------|
| 1 | `gitlab-api-mr-find.sh` | — |
| 2 | MR → `gitlab-api-mr-diff.sh` | `api_mr_diff` |
| 3 | Senão → `gitlab-api-compare-diff.sh` | `api_compare` |

**Agente (shell bloqueado):** `ctx_execute` (javascript + `fetch`) com `GITLAB_TOKEN` — mesmo fluxo MR → changes ou compare. Imprimir só resumo; diffs grandes → arquivo ou `ctx_index` + `ctx_search`.

**VPN:** obrigatória — API não contorna rede.

Variáveis: `GLAB_DIFF_BASE` (default `master`), `GLAB_DIFF_PREVIEW_LINES`, `GLAB_DIFF_TMP`.

### 3. Falha total

Se cache e API falharem:

1. Informar que o hook pode não ter encontrado Monday cache na **1ª** revisão da tarefa
2. Sugerir `prefetch-diff.sh --branch … --repo …` no **Terminal integrado** (VPN + `GITLAB_TOKEN`)
3. Entregar `## Diff` com **Erro:** por repo e **`Status: indisponível`** — **não** usar clone local, MCP ou glab
4. **Não** seguir para passo 8 (decisão final no Monday) — passos 4–7 podem documentar o bloqueio; status/owners ficam intactos

## Status do diff (bloqueio do passo 8)

Na saída **`## Diff`**, linha obrigatória após **Branch/Base:**

| `Status` | Critério | Passo 8 |
|----------|----------|---------|
| **`ok`** | Cada repo de **Projetos alterados** (passo 1) tem subsecção com diff via cache/API; sem **Erro:**; fence `diff` com ≥1 linha de hunk | Permitido |
| **`parcial`** | Pelo menos um repo **ok** e pelo menos um esperado falhou (ausente, **Erro:** ou diff vazio) | **Proibido** |
| **`indisponível`** | Nenhum repo com diff válido; ou passo 3 abortado antes de montar diff | **Proibido** |

## Resolver repositórios

1. Paths em doc/updates: `gitlab.baladapp.com.br/...`, `baladapp/repo`.
2. Update `impacto: <nome>` → `baladapp/<nome>`.
3. `baladapp-react-components` → `baladapp/baladapp-react-components`.
4. Ambíguo → **uma** pergunta ao usuário.

## Diffs grandes

- Ler `diff_file` do bundle/cache.
- No chat: até **400 linhas** por repo se truncado; avisar path completo.
- Usar **context-mode** (`ctx_execute`, `ctx_search`) se não couber no contexto.

## Saída obrigatória

Entregar **somente** o bloco abaixo. **Não** repetir passos 1 ou 2.

```markdown
## Diff

**Branch:** `<branch>` · **Base:** `master` · **Status:** `ok` | `parcial` | `indisponível`

### `<namespace/project>`

| Campo | Valor |
|-------|-------|
| Método | `cache` \| `api_mr_diff` \| `api_compare` |
| MR | `<!iid> — <url>` ou — |
| Target | `<target_branch>` ou `master` |
| Arquivo | `<caminho .diff>` ou — |
| Tamanho | `<bytes>` (+ nota *truncado* se aplicável) |

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
| `GITLAB_TOKEN` ausente no env do executador | Parar; pedir `export` no shell local |
| CACHE_MISS na 1ª revisão | REST API (§2) via `ctx_execute` ou prefetch |
| Bundle exit 2 no agente | Cache/hook ou `ctx_execute`; senão prefetch manual |
| Bundle exit 1 em todos | Reportar JSON; `Status: indisponível`; não inventar diff; passo 8 proibido |
| `Status` ≠ `ok` | Passo 8 proibido — ver [pos-avaliacao](../pos-avaliacao/SKILL.md) |
| Tentação de MCP/glab/clone local | Recusar § Proibido |
| Repo ambíguo | Perguntar antes do bundle |

## Skills relacionadas

| Skill | Papel |
|-------|--------|
| `revisar-tarefa` | Orquestra passos 1–3 |
| `monday-task-info` | Branch, projetos, cache Monday |
| `revisar-tarefa-gerar-requisitos-de-usuario` | Passo 2 |
| `revisar-tarefa-code-review-diff` | Passo 4 — consome `## Diff` |
| `gitlab-api` | Auth, REST API, padrões |
| `scripts/check-gitlab-ready.sh` | Diagnóstico token/hook/cache/API |
| [reference-gitlab-api.md](../reference-gitlab-api.md) | REST API |
