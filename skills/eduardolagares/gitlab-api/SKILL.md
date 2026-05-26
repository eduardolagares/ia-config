---
name: gitlab-api
description: >-
  GitLab REST API com GITLAB_TOKEN (gitlab.baladapp.com.br): validar token, helpers curl
  e garantir merge requests (source → master). Usada por revisar-tarefa passo 8.
disable-model-invocation: true
VERSION: "1.1.0"
---

# gitlab-api

Skill de **scripts bash** para a instância **`https://gitlab.baladapp.com.br`** via REST API v4. **Não** usa GitLab MCP nem `glab`.

## Autenticação

- **`GITLAB_TOKEN`** no ambiente de quem executa (`~/.zshrc`, Terminal integrado, hook).
- Os scripts carregam `~/.zshenv` / `~/.zshrc` se o token ainda não estiver definido.
- **VPN** da empresa deve estar ativa no Mac do executador.

## Scripts (`scripts/`)

| Script | Função |
|--------|--------|
| `gitlab-api-env.sh` | `GITLAB_API_BASE`, `gitlab_api_curl`, `gitlab_api_urlencode` |
| `gitlab-api-validate.sh` | `GET /user` — diagnóstico |
| `gitlab-api-mr-ensure.sh` | Garante MR aberto (`existing` / `updated_target` / `created`); trata 409 e retarget |

### `gitlab-api-mr-ensure.sh`

```bash
scripts/gitlab-api-mr-ensure.sh \
  baladapp/assinaturas dev-minha-branch \
  --target master --title "Título da tarefa Monday"
```

Saída (uma linha JSON): `repo`, `source_branch`, `target_branch`, `action`, `iid`, `web_url`, `error`.

| `action` | Significado |
|----------|-------------|
| `existing` | MR aberto já aponta para o target |
| `updated_target` | MR existente — target (e título) atualizados |
| `created` | MR novo |

Exit **2** no shell do agente Cursor quando `curl` não alcança a API — usar Terminal integrado ou `ctx_execute`.

## Instalação

Copiada pelo `install/` de `ia-config` para:

- `~/.cursor/skills/eduardolagares/gitlab-api/`
- `~/.agents/skills/eduardolagares/gitlab-api/`

A skill **`revisar-tarefa`** resolve estes scripts via `_resolve-gitlab-api.sh` (repo, Cursor ou Agents).

## Consumidores

| Skill | Uso |
|-------|-----|
| `revisar-tarefa` | Passo 8 — `gitlab-api-mr-ensure-bundle.sh` chama `mr-ensure` por repo |
| `revisar-tarefa` | Passos 3 — scripts locais `gitlab-api-*` (podem partilhar o mesmo `env`) |
