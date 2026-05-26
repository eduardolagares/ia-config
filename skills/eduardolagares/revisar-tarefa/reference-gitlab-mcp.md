# GitLab MCP — não usar em `/revisar-tarefa`

O plugin **GitLab MCP** do Cursor (OAuth em Settings → MCP) **não** faz parte desta skill.

| Passo | GitLab |
|-------|--------|
| 3 — diff | REST API + **`GITLAB_TOKEN`** (env); ver [executar-diff/SKILL.md](executar-diff/SKILL.md) |
| 8 — MRs | Scripts `gitlab-api-mr-ensure*` + mesmo token |

**Proibido:** `CallMcpTool` no servidor GitLab, `/api/v4/mcp`, e qualquer fluxo que dependa só do OAuth do MCP em vez de `GITLAB_TOKEN`.

Documentação: **[reference-gitlab-api.md](reference-gitlab-api.md)** · diagnóstico: `scripts/check-gitlab-ready.sh`
