# GitLab REST API — `/revisar-tarefa`

Instância: **`https://gitlab.baladapp.com.br/api/v4`**

**Canal único** para passo 3 (`executar-diff`): REST API com `GITLAB_TOKEN`. GitLab MCP: [reference-gitlab-mcp.md](reference-gitlab-mcp.md).

## Rede (VPN)

A instância **só** responde com **VPN ativa**. Assume-se que quem executa a skill (utilizador no Mac) **já tem a VPN ligada** — hook, scripts bash e `ctx_execute` usam a rede dessa máquina.

Não instruir “ativar VPN” por defeito. Falha de API → `GITLAB_TOKEN`, PAT, cache, sandbox; VPN só se o utilizador disser que está desligada.

## Autenticação (`GITLAB_TOKEN`)

Sempre que usar GitLab nesta skill:

- **Fonte única:** variável de ambiente **`GITLAB_TOKEN`** na máquina de **quem executa** (utilizador no Terminal, hook `beforeSubmitPrompt`, ou sessão do agente com env herdado).
- **Proibido:** pedir o PAT no chat, inventar token, gravar em ficheiros do repo ou confiar só no OAuth do plugin GitLab MCP para os scripts REST abaixo.
- **Validar:** `scripts/check-gitlab-ready.sh` ou `source scripts/gitlab-api-env.sh`.
- **Agente com curl bloqueado:** `ctx_execute` com `Authorization: Bearer ${process.env.GITLAB_TOKEN}` — o valor tem de vir do mesmo env da sessão.

Configurar no executador:

```bash
export GITLAB_TOKEN="glpat-..."   # PAT em gitlab.baladapp.com.br (escopo api)
```

Reiniciar Cursor ou Terminal integrado após alterar `~/.zshrc` / `~/.bashrc`.

## Scripts

| Script | Função |
|--------|--------|
| `gitlab-api-env.sh` | delega para skill **`gitlab-api`** (`GITLAB_TOKEN`, `gitlab_api_curl`) |
| `gitlab-api-mr-find.sh` | MR por `source_branch` |
| `gitlab-api-mr-diff.sh` | diff do MR (`/merge_requests/:iid/changes`) |
| `gitlab-api-compare-diff.sh` | compare `from..to` |
| `gitlab-api-phase3-diff-bundle.sh` | bundle passo 3 (`api_mr_diff` / `api_compare`) |
| `gitlab-api-mr-ensure.sh` | delega para **`gitlab-api`** — MR `source_branch` → `master` |
| `gitlab-api-mr-ensure-bundle.sh` | MR por repo (passo 8, `precisa_de_correcao`) |
| `prefetch-diff.sh` | pré-busca via API + grava cache |
| `gitlab-api-validate.sh` | `GITLAB_TOKEN` + GET `/user` |
| `check-gitlab-ready.sh` | token, hook, cache, API |

## Prefetch / hook

`prefetch-diff.sh` usa **somente** `gitlab-api-phase3-diff-bundle.sh` (REST API).

```bash
scripts/prefetch-diff.sh \
  --branch dev-eventos-sugeridos \
  --repo baladapp/assinaturas
```

## Validar no Terminal

```bash
scripts/gitlab-api-validate.sh

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
- **Hook `beforeSubmitPrompt`:** rede do Mac (VPN já ativa no executador) — scripts bash OK

## `method` no JSON do bundle

- `api_mr_diff` — MR encontrado, diff via changes API
- `api_compare` — sem MR (ou MR diff falhou), compare branch vs base (default `master`)

## MR para correção (passo 8)

Quando veredito = `precisa_de_correcao`:

```bash
scripts/gitlab-api-mr-ensure-bundle.sh \
  --branch "<branch>" --titulo "<título>" \
  baladapp/repo1 baladapp/repo2
```

## Proibido no passo 3

GitLab MCP — ver [reference-gitlab-mcp.md](reference-gitlab-mcp.md).
