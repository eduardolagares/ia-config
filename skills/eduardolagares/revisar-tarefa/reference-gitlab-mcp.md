# GitLab MCP — passo 3 `/revisar-tarefa`

Servidor configurado em `~/.cursor/mcp.json`:

```json
"GitLab": {
  "type": "http",
  "url": "https://gitlab.baladapp.com.br/api/v4/mcp"
}
```

Autenticar em **Cursor Settings → MCP → GitLab** (OAuth; token com escopo `api`).

## Check rápido (agente / Terminal)

```bash
scripts/check-gitlab-ready.sh \
  --branch "<branch>" --titulo "<título exato>"
```

Interpretação:

| Campo | `online` / `ok` / `HIT` | Problema |
|-------|--------------------------|----------|
| `mcp_session` | tools em `~/.cursor/projects/*/mcps/GitLab/tools/` | `offline` → MCP não conectado nesta sessão |
| `mcp.json` | entrada `GitLab` presente | `missing` → editar `~/.cursor/mcp.json` |
| `hook prefetch` | script existe e executável | corrigir `~/.cursor/hooks.json` (path absoluto `$HOME/.cursor/hooks/...`) |
| `cache diff` | `HIT` após `/revisar-tarefa` | `MISS` → VPN on + reenviar prompt ou `prefetch-diff.sh` |
| `api (shell)` | `ok` no Terminal | `agent_shell_blocked` no agente é **normal** |

## Ordem no passo 3

1. **Cache** — `read-diff-bundle-cache.sh` (hook `beforeSubmitPrompt` pode ter pré-populado)
2. **GitLab MCP** — se o servidor estiver verde no Settings
3. **glab** — `glab-phase3-diff-bundle.sh` (shell do agente costuma falhar; hook/cache evitam isso)

## Tools úteis (plugin GitLab)

| Objetivo | Tool MCP |
|----------|----------|
| MR na branch | listar MRs do projeto com `source_branch` = branch da tarefa |
| Diff do MR | `get_merge_request_diffs` (project + `merge_request_iid`) |
| Metadados MR | `get_merge_request` |
| Pipelines | `get_merge_request_pipelines` |

Sem MR aberto: usar compare via API REST (script `glab-compare-diff.sh`) ou meta-tool `gitlab_repository` se o MCP expuser compare.

## Montar `## Diff` a partir do MCP

- Método na tabela: `mr_diff` quando vier de `get_merge_request_diffs`
- Incluir `MR: !<iid> — <web_url>` de `get_merge_request`
- Conteúdo: hunks retornados pelo MCP (até 400 linhas/repo; usar context-mode se maior)

## Falha do MCP

Se **Settings → MCP → GitLab** estiver com erro:

- Confiar no **cache** (`last-diff-bundle.json`) gerado pelo hook
- Ou rodar manualmente: `prefetch-diff.sh --titulo "..."` / `glab-phase3-diff-bundle.sh`

Não usar clone local — ver [reference-glab.md](reference-glab.md) § Proibido.
