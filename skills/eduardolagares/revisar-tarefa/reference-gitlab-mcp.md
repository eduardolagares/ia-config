# GitLab — receitas MCP (`revisar-tarefa`)

**Validado neste ambiente:** servidor `user-gitlab`, `serverStatus: ready`, host `gitlab.baladapp.com.br`.

## Canal único

| Usar | Proibido |
|------|----------|
| `CallMcpTool` → servidor GitLab MCP da IDE | `GITLAB_TOKEN`, PAT, curl/`fetch` `/api/v4`, scripts de API |
| `gitlab_execute_action` com `action` + `params` | Inventar token; pedir PAT no chat |
| `gitlab_find_action` **só** se o action id for incerto | GraphQL/REST manual |

**Resolver `server`:** `GetMcpTools` padrão `gitlab` (ex. `user-gitlab`). Se `needsAuth` → `mcp_auth` nesse servidor.

**Forma fixa de chamada:**

```text
CallMcpTool
  server: <gitlab-mcp-da-ide>   # ex. user-gitlab
  toolName: gitlab_execute_action
  arguments:
    action: "<action.id>"
    params: { ... }
```

Não chamar `gitlab_find_action` em loop se o action abaixo já está listado.

## Rede (VPN)

`gitlab.baladapp.com.br` só com VPN. Premissa: VPN **já ativa**. Falha → Settings → MCP → GitLab / `mcp_auth`. Só mencionar VPN se o utilizador confirmar que caiu.

## IDs

| Conceito | Valor |
|----------|--------|
| `project_id` | path `namespace/project` (ex. `baladapp/ingressos`) |
| MR | **IID** do projeto (`!410` → `410`), **não** o ID global |
| Base de diff / target MR | **`master`** (fixo — não assumir `main`) |

---

## Passo 3 — Diff (leitura)

Ordem **obrigatória** por cada `namespace/project`:

### 1) Listar MR aberto da branch

```json
{
  "action": "merge_request.list",
  "params": {
    "project_id": "baladapp/ingressos",
    "source_branch": "<branch-da-tarefa>",
    "state": "opened",
    "per_page": 20
  }
}
```

### 2a) Com MR → diff unificado (preferido) → `method: mcp_mr_diff`

```json
{
  "action": "mr_review.raw_diffs",
  "params": {
    "project_id": "baladapp/ingressos",
    "merge_request_iid": 410
  }
}
```

Alternativa estruturada (ficheiros):

```json
{
  "action": "mr_review.changes_get",
  "params": {
    "project_id": "baladapp/ingressos",
    "merge_request_iid": 410
  }
}
```

Preferir `raw_diffs` para o fence `diff` do `## Diff`. Se truncado → `raw_diffs` / context-mode.

### 2b) Sem MR (ou diff do MR falhou) → compare → `method: mcp_compare`

```json
{
  "action": "repository.compare",
  "params": {
    "project_id": "baladapp/ingressos",
    "from": "master",
    "to": "<branch-da-tarefa>"
  }
}
```

`from` = base (`master`); `to` = branch da tarefa.

### 3) Detalhe do MR (opcional)

```json
{
  "action": "merge_request.get",
  "params": {
    "project_id": "baladapp/ingressos",
    "merge_request_iid": 410
  }
}
```

Diffs grandes: resumir no chat (~400 linhas/repo); reconsultar só via context-mode (`ctx_index` / `ctx_search`). Sem context-mode → sem cache em disco.

---

## Passo 8 — Garantir MR (qualquer veredito)

Target sempre **`master`**. Source = branch Monday. Título = título da tarefa (ou branch).

**Obrigatório** em todo desfecho do passo 8 (`precisa_de_correcao`, `pode_avancar_para_revisao_manual`, etc.): criar/reutilizar MRs e publicar no doc **Revisar código** (§ A.2 em [pos-avaliacao](pos-avaliacao/SKILL.md)).

### A) Já existe aberto `source` → `master` → `existing`

Usar `merge_request.list` (acima). Reutilizar `iid` + `web_url`.

### B) Aberto com outro target → `updated_target`

```json
{
  "action": "merge_request.update",
  "params": {
    "project_id": "baladapp/ingressos",
    "merge_request_iid": 410,
    "target_branch": "master"
  }
}
```

### C) Sem MR aberto → `created`

```json
{
  "action": "merge_request.create",
  "params": {
    "project_id": "baladapp/ingressos",
    "source_branch": "<branch-da-tarefa>",
    "target_branch": "master",
    "title": "<título Monday ou branch>"
  }
}
```

Reportar por repo: `action` ∈ {`existing`,`updated_target`,`created`}, `iid`, `web_url`.

---

## Descoberta de projeto (raro)

Se o path for ambíguo:

```json
{
  "action": "project.list",
  "params": {
    "search": "ingressos",
    "per_page": 10
  }
}
```

Ou `gitlab_find_action` com `query: "project get"` / `"merge request create"`.

---

## Checklist rápido

1. GitLab MCP `ready` (ou `mcp_auth`)?
2. Só `gitlab_execute_action` com actions desta página — não reinventar.
3. `project_id` = `namespace/project`; MR = IID.
4. Base/target = `master`.
5. MCP falhou → **parar**; não inventar diff/MR; passo 8 proibido se `## Diff` ≠ `ok`.
