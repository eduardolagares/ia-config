# GitLab — conexão MCP na IDE (`revisar-tarefa`)

## Canal único

| Usar | Proibido |
|------|----------|
| `CallMcpTool` no **servidor GitLab MCP** instalado na IDE de quem executa | `GITLAB_TOKEN`, PAT, curl/`fetch` contra `/api/v4`, qualquer script de API GitLab |
| `gitlab_find_action` + `gitlab_execute_action` (catálogo do MCP) | Inventar token, pedir PAT no chat, GraphQL/REST manual |
| OAuth / auth do MCP em **Cursor → Settings → MCP → GitLab** | Depender de env shell para autenticar GitLab |

**Resolver o `server`:** usar o id do GitLab MCP **desta** IDE (`GetMcpTools` com padrão `gitlab`, ou pasta `mcps/*gitlab*`). Exemplos comuns: `user-gitlab`, id do plugin GitLab. **Não** hardcodar um id se o da sessão for outro — usar o que estiver ligado e `ready`.

Se `serverStatus` for `needsAuth` → chamar `mcp_auth` nesse servidor (utilizador autoriza na IDE). Não pedir token no chat.

Schemas/ações: `gitlab_find_action` com `query` quando o action id for incerto; depois `gitlab_execute_action` com `action` + `params`.

## Rede (VPN)

`gitlab.baladapp.com.br` **só** responde com **VPN** da empresa. Premissa: VPN **já ativa** na máquina de quem executa.

- **Não** pedir “ligar a VPN” como troubleshooting padrão.
- Falha MCP → verificar GitLab ligado em Settings → MCP, auth (`mcp_auth`), sandbox/rede da IDE.
- Só considerar VPN desligada se o utilizador confirmar.

## Passo 3 — diff (leitura)

Por cada `namespace/project` (`project_id`, ex. `baladapp/ingressos`), branch da tarefa, base **`master`**:

| Ordem | Ação MCP | `method` na saída |
|-------|----------|-------------------|
| 1 | `merge_request.list` — `project_id`, `source_branch` = branch, `state` = opened (ou equivalente) | — |
| 2 | MR aberto → `mr_review.raw_diffs` (preferido) ou `mr_review.changes_get` | `mcp_mr_diff` |
| 3 | Sem MR (ou diff falhou) → `repository.compare` — `from` = `master`, `to` = branch | `mcp_compare` |

Diffs grandes: resumir no chat. Reconsultar payload completo **só** via MCP context-mode (`ctx_index` / `ctx_search`). Sem context-mode → sem cache (ver [SKILL.md](SKILL.md) § Cache).

## Passo 8 — garantir MR (`precisa_de_correcao`)

Por cada repo, target **`master`**, source = branch da tarefa, título = título Monday (ou branch):

| Situação | Ação MCP |
|----------|----------|
| MR aberto `source` → `master` | Reutilizar (`existing`) — `merge_request.list` / `merge_request.get` |
| MR aberto com outro target | `merge_request.update` — `target_branch: master` (`updated_target`) |
| Sem MR aberto | `merge_request.create` — `source_branch`, `target_branch: master`, `title` (`created`) |

Reportar `iid`, `web_url`, `action` por repo.

## Checklist do agente

1. GitLab MCP existe e está `ready` (ou autenticar com `mcp_auth`)?
2. `GetMcpTools` / schema antes de executar ações pouco usadas.
3. Só `CallMcpTool` no servidor GitLab da IDE — zero REST/token.
4. Instância: `gitlab.baladapp.com.br` (VPN).
5. MCP indisponível → **parar**; não inventar diff nem MR.
