# GitLab REST API — `/revisar-tarefa`

Instância: **`https://gitlab.baladapp.com.br/api/v4`**

**Canal único** para passo 3 (`executar-diff`). Sem GitLab MCP, sem `glab`.

Auth: **`GITLAB_TOKEN`** (env) — ver skill `gitlab-api` (`~/.agents/skills/gitlab-api/scripts/gitlab-api-env.sh`).

## Scripts

| Script | Função |
|--------|--------|
| `gitlab-api-env.sh` | delega para skill `gitlab-api` |
| `gitlab-api-mr-find.sh` | MR por `source_branch` |
| `gitlab-api-mr-diff.sh` | diff do MR (`/merge_requests/:iid/changes`) |
| `gitlab-api-compare-diff.sh` | compare `from..to` |
| `gitlab-api-phase3-diff-bundle.sh` | bundle passo 3 (`api_mr_diff` / `api_compare`) |
| `gitlab-api-mr-ensure.sh` | garante MR aberto `source_branch` → `master` |
| `gitlab-api-mr-ensure-bundle.sh` | MR por repo (passo 8, `precisa_de_correcao`) |
| `prefetch-diff.sh` | pré-busca via API + grava cache |
| `check-gitlab-ready.sh` | token, hook, cache, API |

## Prefetch / hook

`prefetch-diff.sh` usa **somente** `gitlab-api-phase3-diff-bundle.sh` (REST API).

```bash
scripts/prefetch-diff.sh \
  --branch dev-eventos-sugeridos \
  --repo baladapp/assinaturas
```

## Validar no Terminal (VPN on)

```bash
~/.agents/skills/gitlab-api/scripts/gitlab-api-check.sh

scripts/gitlab-api-mr-find.sh \
  baladapp/assinaturas dev-eventos-sugeridos

scripts/gitlab-api-phase3-diff-bundle.sh \
  dev-eventos-sugeridos baladapp/assinaturas
```

## Agente vs hook

| Ambiente | Ferramenta |
|----------|------------|
| Hook / Terminal integrado | scripts bash |
| Shell do agente (curl bloqueado) | `ctx_execute` + fetch + `GITLAB_TOKEN` |
| Output grande | `ctx_execute` + `ctx_search` |

- **Agente Cursor:** `gitlab_api_curl` → exit **2** no sandbox → usar `ctx_execute`
- **Hook `beforeSubmitPrompt`:** rede do Mac/VPN — scripts bash OK

## `method` no JSON do bundle

- `api_mr_diff` — MR encontrado, diff via changes API
- `api_compare` — sem MR (ou MR diff falhou), compare branch vs `GLAB_DIFF_BASE` (default `master`)

## MR para correção (passo 8)

Quando veredito = `precisa_de_correcao`:

```bash
scripts/gitlab-api-mr-ensure-bundle.sh \
  --branch "<branch>" --titulo "<título>" \
  baladapp/repo1 baladapp/repo2
```

## Proibido no passo 3

- GitLab MCP (`CallMcpTool`, `/api/v4/mcp`)
- `glab` e scripts `glab-*`
- `git diff` / clone local
