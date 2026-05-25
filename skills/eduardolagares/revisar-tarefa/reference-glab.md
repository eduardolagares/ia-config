# GitLab (`glab`) — `/revisar-tarefa`

Instância: **`https://gitlab.baladapp.com.br`**

## Setup (uma vez no Mac)

```bash
brew install glab
glab config set host gitlab.baladapp.com.br -g
glab auth login --hostname gitlab.baladapp.com.br
```

Validar no **seu Terminal** (não no agente):

```bash
glab config get host -g          # → gitlab.baladapp.com.br
glab auth status
glab repo list --member --per-page 5
scripts/glab-validate.sh
```

**Nota:** em `glab api`, a saída JSON é o padrão (`glab api user`). **Não** use `-F json` no subcomando `api` (essa flag é de formulário e quebra o teste). Em `glab mr list` / `glab repo list`, `-F json` está correto.

Token fica em `~/Library/Application Support/glab-cli/config.yml` (escopo **`api`**).

## Por que o shell do agente falha (e o seu Terminal não)

O subprocesso do **agente** roda em **sandbox** com proxy do Cursor (`HTTP_PROXY=127.0.0.1:…`). No agente, `glab` costuma retornar **403** ou falha de DNS. No **Terminal integrado**, o mesmo `glab auth status` funciona — exportar `HTTP_PROXY` manualmente **não** reproduz o sandbox.

**Automação (sem colar diff manualmente):**

1. **Hook** — ao enviar `/revisar-tarefa`, `~/.cursor/hooks/revisar-tarefa-prefetch-diff.sh` chama `prefetch-diff.sh` (**GitLab REST API** primeiro, `glab` fallback; VPN do Mac).
2. **Cache** — passo 3 lê `cache/last-diff-bundle.json` via `read-diff-bundle-cache.sh`.
3. **GitLab MCP** — `~/.cursor/mcp.json` → Settings → MCP → GitLab; ver [reference-gitlab-mcp.md](reference-gitlab-mcp.md).

Prefetch manual:

```bash
scripts/prefetch-diff.sh --titulo "Título exato da tarefa"
# ou
scripts/prefetch-diff.sh --branch dev-x --repo baladapp/assinaturas
```

Se o script imprimir `GLAB_RUN_IN_USER_TERMINAL=1`, rode o comando sugerido no Terminal integrado.

## Proibido: clones locais

O passo 3 **não** aceita fallback com repositório clonado na máquina:

- **Não** usar `git diff origin/master...branch` em `~/projetos/` ou worktrees
- **Não** montar a seção `## Diff` a partir de arquivos lidos no disco
- **Não** rotular diff como `compare (local)` ou similar

Se `glab` falhar no agente e o usuário não colar o JSON do bundle, a resposta deve listar **Erro:** por projeto — nunca substituir por diff local.

## Scripts

| Script | Uso |
|--------|-----|
| `glab-validate.sh` | Auth + host padrão |
| `glab-mr-find.sh` | `repo` + `branch` → JSON com MRs |
| `glab-mr-diff.sh` | `repo` + `iid` → diff (stdout ou arquivo) |
| `glab-phase2-bundle.sh` | `branch` + repos… → JSON agregado (só MRs) |
| `glab-compare-diff.sh` | `repo` + `branch` vs `master` → diff (compare API) |
| `glab-phase3-diff-bundle.sh` | `branch` + repos… → JSON + arquivos `.diff` (passo 3) |
| `prefetch-diff.sh` | Pré-busca glab → `cache/last-diff-bundle.json` (hook / manual) |
| `read-diff-bundle-cache.sh` | Valida cache para branch/título (passo 3) |
| `glab-mr-notes-list.sh` | Lista threads com `[bld:N.M]` |
| `glab-mr-note-create.sh` | Publica nota (mensagem em arquivo) |
| `glab-mr-discussion-resolve.sh` | Resolve discussion (re-run) |

### Exemplos

```bash
# MR por branch
scripts/glab-mr-find.sh baladapp/assinaturas-adm feature/minha-branch

# Vários projetos de uma vez
scripts/glab-phase2-bundle.sh feature/minha-branch \
  baladapp/assinaturas baladapp/ingressos-api

# Diff (passo 3 — branch vs master, vários repos)
scripts/glab-phase3-diff-bundle.sh dev-minha-branch \
  baladapp/assinaturas

# Diff de um MR específico
scripts/glab-mr-diff.sh baladapp/assinaturas-adm 42 /tmp/mr-42.diff

# Compare direto (sem MR)
scripts/glab-compare-diff.sh baladapp/assinaturas dev-minha-branch master /tmp/compare.diff

# Publicar achado
echo '[bld:1.1] app/models/x.rb:10 — problema. correção.' > /tmp/note.txt
scripts/glab-mr-note-create.sh baladapp/assinaturas-adm 42 /tmp/note.txt
```

## Comandos glab equivalentes (referência)

Host padrão já configurado — **não** usar `--host` (flag inválida no `glab mr`).

```bash
glab mr list -R baladapp/assinaturas-adm --source-branch "feature/x"
glab mr diff 42 -R baladapp/assinaturas-adm --color=never
glab mr note create 42 -R baladapp/assinaturas-adm -m "texto"
glab mr note list 42 -R baladapp/assinaturas-adm
glab mr note resolve <discussion_id> 42 -R baladapp/assinaturas-adm
```

## Códigos de saída dos scripts

| Código | Significado |
|--------|-------------|
| 0 | OK |
| 1 | Erro (auth, repo, comando) |
| 2 | Rodar no Terminal do usuário (`GLAB_RUN_IN_USER_TERMINAL=1`) |
| 3 | `glab-mr-find`: nenhum MR na branch |

## Relacionado

- [SKILL.md](SKILL.md) — fluxo completo
- [reference.md](reference.md) — Monday.com
