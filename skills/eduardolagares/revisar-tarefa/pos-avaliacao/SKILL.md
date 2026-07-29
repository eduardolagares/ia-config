---
name: revisar-tarefa-pos-avaliacao
description: >-
  Passo 8 de revisar-tarefa: em qualquer veredito, garante MRs GitLab (branch → master)
  e publica links no doc Revisar código (tópico Merge requests); depois aplica status
  e owners conforme o veredito. Em qualquer veredito, anota veredito + data no doc Revisar
  código; se avançar, define status consolidado Revisão manual de código (automação Monday).
disable-model-invocation: true
VERSION: "2.8.0"
---

# revisar-tarefa — pós avaliação (passo 8)

Sub-skill **`pos-avaliacao`** do passo 8. **Escrita** no Monday (status, owners, doc) e no GitLab (MRs).

**Independente do veredito** (`precisa_de_correcao`, `pode_avancar_para_revisao_manual`, ou outro desfecho futuro): **sempre** (1) garantir MRs no GitLab e publicá-los no doc, (2) anotar **veredito + data** em **`## Resultado da revisão`**. Só depois executar status/owners do veredito.

**GitLab (MRs):** só `CallMcpTool` no servidor GitLab MCP da IDE — [reference-gitlab-mcp.md](../reference-gitlab-mcp.md) (**create/update/list**). **Proibido:** `GITLAB_TOKEN`, REST, scripts de API.

**Monday:** só `CallMcpTool` no servidor Monday MCP da IDE — [../../monday-task-info/reference-mcp-monday.md](../../monday-task-info/reference-mcp-monday.md) (**status, doc**). **Proibido:** `MONDAY_API_TOKEN`, GraphQL/REST contra `api.monday.com`.

## Receitas rápidas

| Ação | Como |
|------|------|
| Listar / criar / retarget MR | `gitlab_execute_action` → `merge_request.list` \| `create` \| `update` (`target_branch: master`) — JSON em reference-gitlab |
| Criar subtarefa Revisar código | `create_item` (`parentItemId`, `name: Revisar código`, status `A fazer`) |
| Status subtarefa / consolidado | `change_item_column_values` — `columnValues` string JSON com `{"label":"…"}` |
| Encaminhar por status | **Só** `status_1` → label; automação Monday move o grupo (**nunca** `move_item_to_group`) — ver [reference.md](../reference.md) |
| Append **Merge requests** / resultado | `update_doc` → `add_markdown_content` |
| Owners merge | `get_board_items_page` (`itemIds`) + `change_item_column_values` (`person.personsAndTeams`) |

**Gate (obrigatório, antes de qualquer mutation):** o passo 3 deve ter entregue **`## Diff`** com **`Status: ok`**. Se `parcial`, `indisponível`, secção ausente ou diff só com **Erro:** em todos os repos → **parar**; **não** alterar status, owners, doc **Merge requests** nem criar MRs. Emitir `## Pós avaliação` em modo bloqueio (§ abaixo).

## Pré-requisito

| Dado | Obrigatório |
|------|-------------|
| **`## Diff`** (passo 3) | Sim — **`Status: ok`** (critérios em [executar-diff](../executar-diff/SKILL.md) § Status do diff) |
| **`## Avaliação`** | Sim — passo 7 (`Veredito`) |
| **Passo 1** | Sim — `item_id` tarefa + subtarefas Executar, Revisar código (Testar não é alvo deste passo) |
| **Passo 1 ou 3** | **Branch** + lista de repos (`Projetos alterados` ou `## Diff`) — **sempre** (MRs em qualquer veredito) |
| **GitLab MCP** | Sim — MRs em **qualquer** veredito (IDE ligada + `ready` / `mcp_auth`) |
| **Passo 6** (recomendado) | Doc **Revisar código** — se `Ação: nenhum`, § A.2 pode **criar** doc só com MRs |
| **`doc_object_id`** | Sim (§ A.2) — passo 1 / passo 6 (`subtarefa Revisar código`) |

## IDs fixos (board Dia a dia)

| Entidade | Board | Coluna status | Coluna owner |
|----------|-------|---------------|--------------|
| Tarefa principal | `4571892384` | `status_1` (Status consolidado) | — |
| Subtarefas | `4571892432` | `status` | `person` |

Resolver `item_id` de cada subtarefa via passo 1 (markdown) ou MCP `get_board_items_page`. Se **Revisar código** estiver ausente → **criar** ([../SKILL.md](../SKILL.md) § Subtarefa Revisar código) antes de doc/status/owners.

## Entrada

- **`Veredito`** do `## Avaliação` (passo 7)
- IDs das subtarefas: **Executar**, **Revisar código**
- `item_id` da tarefa principal
- **Branch** + repos (`Projetos alterados` / `## Diff`) — para MRs em **qualquer** veredito

## Fluxo (ordem fixa)

0. **Validar diff:** ler `Status` em `## Diff` (passo 3). Se ≠ `ok` → § **Bloqueio (diff indisponível)** e **terminar** (zero mutations Monday/GitLab).
1. Confirmar veredito ∈ {`precisa_de_correcao`, `pode_avancar_para_revisao_manual`}.
2. **Sempre** (§ **Merge requests — comum**): GitLab (criar/reutilizar MRs) → doc Monday (**Merge requests**).
3. **Sempre** (§ **C — Resultado da revisão**): anotar **veredito + data** no doc **Revisar código**. **Não** pular por veredito.
4. Executar o bloco de status/owners **do veredito** (§ abaixo) — **depois** dos MRs e do resultado.
5. Status: `change_item_column_values` com `{"label": "<texto exato>"}`.
6. Reportar cada mutation no chat (sucesso/erro por item).

### Bloqueio (diff indisponível)

Quando o passo 0 falhar — **não** chamar `change_item_column_values`, `create_doc`, `append_blocks`, nem criar/atualizar MRs no GitLab.

Entregar no chat:

```markdown
## Pós avaliação

| Campo | Valor |
|-------|-------|
| Veredito (passo 7) | `<veredito>` — **não aplicado** |
| Motivo | Diff GitLab indisponível (`Status: <parcial\|indisponível>`) |
| Ações Monday | **nenhuma** (status/owners/doc MR inalterados) |
| Próximo passo | Corrigir MCP GitLab na IDE e repetir passo 3 até `Status: ok` (VPN já ativa no executador) |
```

Opcional: uma linha no chat com o veredito que **teria** sido aplicado — sem executá-lo.

## Merge requests — comum a todos os vereditos

**Obrigatório** em **qualquer** veredito válido, **antes** das ações de status/owners. Inclui `precisa_de_correcao`, `pode_avancar_para_revisao_manual` e qualquer desfecho futuro de status (ex. deploy) — o destino Monday muda; **MRs + doc não**.

**Ordem deste bloco:** GitLab (MRs) → doc Monday (**Merge requests**).

### A. Merge requests (GitLab MCP)

Para **cada** `namespace/project` da tarefa (mesma lista do passo 3 — `## Diff` / **Projetos alterados** do passo 1):

1. **Check:** GitLab MCP da IDE `ready` (ou `mcp_auth`); senão parar — pedir GitLab em **Settings → MCP** (não pedir token no chat). Preferir parar tudo se MRs forem necessários.
2. Via `gitlab_execute_action` (ver [reference-gitlab-mcp.md](../reference-gitlab-mcp.md)):

| Comportamento | Detalhe |
|---------------|---------|
| Target | **`master`** |
| Source | Branch da tarefa (coluna Monday) |
| MR já aberto `source` → `master` | Reutiliza (`action: existing`) — `merge_request.list` / `get` |
| MR aberto com outro target | `merge_request.update` → target `master` (`updated_target`) |
| Sem MR aberto | `merge_request.create` (`created`) |
| Canal | **só** GitLab MCP da IDE |

Título do MR: título da tarefa Monday (ou branch se ausente).

Incluir na saída **`## Pós avaliação`** subsecção **`### Merge requests`** com tabela:

| Repo | Ação | MR | URL |
|------|------|-----|-----|
| `baladapp/…` | `created` \| `existing` \| `updated_target` | `!<iid>` | link |

Erro por repo: linha com **Erro:**; seguir nos demais (doc e status do veredito).

Guardar `web_url` / `iid` / `repo` / `action` por projeto para § A.2.

### A.2. Documento Revisar código — tópico `## Merge requests`

**Somente** MRs com `web_url` válida (§ A). **Append** — não alterar **`## Revisão de código`** nem **`## Requisitos não implementados`**.

1. Resolver `item_id` / `doc_object_id` da subtarefa **Revisar código** (passo 1 / passo 6). Se a subtarefa **não** existir → **criar** ([../SKILL.md](../SKILL.md) § Subtarefa Revisar código) e seguir.
2. `read_docs` — `mode: content`, `type: object_ids`, `ids: [<doc_object_id>]`.
3. Extrair do markdown existente (secção **`## Merge requests`** ou variantes `## Merge requests — <data>`):
   - URLs já publicadas (`https://gitlab.baladapp.com.br/...`)
   - Pares `repo` + `!<iid>` (regex `baladapp/[\w.-]+` e `!\d+`)
4. Para cada MR com `web_url` (§ A):
   - Já no doc (mesma URL **ou** mesmo `repo` + `!iid`) → **SKIP** — reportar `SKIP MR duplicado: <repo>`
   - Novo → incluir na tabela de append
5. Se **nenhum** MR novo após filtro → `Doc MR: nenhum`; seguir ações do veredito.
6. Montar markdown:

```markdown
## Merge requests — <YYYY-MM-DD>

| Repo | MR | Branch → target | URL |
|------|-----|-----------------|-----|
| baladapp/ingressos | !306 | `<branch>` → `master` | <web_url> |
```

(`Branch → target` = branch da tarefa + `master`.)

7. Publicar:

| Situação | MCP |
|----------|-----|
| Doc existe | `update_doc` → `add_markdown_content` com markdown do passo 6 |
| Doc ausente | `create_doc` — `location: item`, `item_id` subtarefa Revisar código, `column_id: monday_doc`, `doc_name: Revisar código`, markdown:

```markdown
# Revisar código

Documento gerado por /revisar-tarefa.

## Merge requests — <YYYY-MM-DD>

| Repo | MR | Branch → target | URL |
|------|-----|-----------------|-----|
| … | … | … | … |
```

8. Se `create_doc` retornou novo id, usar esse `doc_object_id` no restante do passo 8 (contexto do chat).

| Erro | Ação |
|------|------|
| MCP Monday indisponível | Reportar; seguir status do veredito se usuário não bloqueou |
| `update_doc` / `create_doc` falhou | Reportar; **não** simular link no doc |
| Nenhum MR com `web_url` | Omitir § A.2; reportar aviso |

Incluir em **`## Pós avaliação`**: linha `Doc Merge requests` = `append` \| `criado` \| `nenhum` \| `erro`.

## C. Documento Revisar código — resultado (qualquer veredito)

**Obrigatório** em **qualquer** veredito válido, **depois** dos MRs (§ A/A.2) e **antes** das ações de status/owners. Registo histórico: **qual veredito** e **em que data**. **Append** — não alterar tópicos de revisão/R*/análise/MRs.

1. Resolver `doc_object_id` (passo 1 / passo 6 / § A.2). Se a subtarefa **Revisar código** não existir → **criar** ([../SKILL.md](../SKILL.md) § Subtarefa Revisar código) antes do append.
2. `read_docs` — se já existir heading `## Resultado da revisão — <YYYY-MM-DD>` **hoje** com o **mesmo** veredito → **SKIP**; reportar `Doc resultado: já anotado`.
3. Montar markdown conforme o veredito:

**`precisa_de_correcao`:**

```markdown
## Resultado da revisão — <YYYY-MM-DD>

**Veredito:** `precisa_de_correcao` (`/revisar-tarefa`).

- Há pendências abertas (revisão, requisitos ou análise manual)
- Subtarefa Revisar código → **Aguardando correção**; tarefa → **Fazendo** (grupo **Atribuídas** via automação)
```

**`pode_avancar_para_revisao_manual`:**

```markdown
## Resultado da revisão — <YYYY-MM-DD>

**Veredito:** `pode_avancar_para_revisao_manual` (`/revisar-tarefa`).

- Revisão automatizada passou — sem pendências abertas
- Status consolidado → **Revisão manual de código** (automação Monday move o grupo)
```

Outro veredito futuro: mesmo heading com `**Veredito:** \`<nome>\`` + 1–2 bullets do desfecho.

4. Publicar com `update_doc` → `add_markdown_content`. Se doc ausente → `create_doc` com `# Revisar código` + bloco acima (mesmo padrão de § A.2).
5. Em **`## Pós avaliação`**: linha `Doc Resultado` = `append` \| `criado` \| `já anotado` \| `erro`.

Falha no append → reportar; **seguir** status do veredito (não bloquear só por falha de anotação).

### `precisa_de_correcao`

Inclui pendências só em **`## Análise manual`** (passo 7 não marca checkboxes — conclusão humana). **Antes:** § Merge requests (§ A + A.2) + § **C** (veredito + data). Depois: Monday (owners + status).

#### B. Monday (status / owners)

| # | Alvo | Ação |
|---|------|------|
| 1 | Subtarefa **Revisar código** | **Adicionar** owner(s) da subtarefa **Executar** à coluna `person` (merge — **não** remover owners existentes) |
| 2 | Subtarefa **Revisar código** | Status → **`Aguardando correção`** |
| 3 | Tarefa principal | Status consolidado (`status_1`) → **`Fazendo`** (automação Monday move para o grupo **Atribuídas**) |

**Não** chamar `move_item_to_group` — grupo **Atribuídas** vem da automação ao setar **Fazendo**.

**Owner merge (passo 1):**

1. `get_board_items_page` — `itemIds: [<executar_id>, <revisar_codigo_id>]`, `boardId: 4571892432`, `includeColumns: true`.
2. Extrair ids de pessoa da coluna `person` de **Executar** e **Revisar código** (JSON em `value` / `personsAndTeams`).
3. Unir ids únicos; gravar em **Revisar código**:

```json
{"person": {"personsAndTeams": [{"id": <user_id>, "kind": "person"}, ...]}}
```

Se **Executar** não tiver owner → pular merge; reportar aviso; executar passos 2–3.

### `pode_avancar_para_revisao_manual`

**Antes:** § Merge requests (§ A + A.2) + § **C** (veredito + data) — **mesmo** bloco comum.

**Obrigatório** definir status consolidado **`Revisão manual de código`**. A **automação já existente no Monday** move a tarefa para o grupo correspondente — **não** chamar `move_item_to_group` / `get_board_info` para grupo (mesma regra que **Fazendo** → **Atribuídas** e **Revisão automática de código** → seu grupo). **Proibido** neste veredito: status **QA**, **Aguardando testes**, **Aguardando deploy**, ou qualquer outro destino de testes/deploy.

**Ordem (após MRs + § C):** subtarefa Revisar código → status consolidado da tarefa principal.

| # | Alvo | Ação |
|---|------|------|
| 1 | Subtarefa **Revisar código** | Status → **`Concluída`** |
| 2 | Tarefa principal | Status consolidado (`status_1`) → **`Revisão manual de código`** (automação Monday move o grupo) |

**Não** alterar subtarefa **Testar**, **Executar** nem **Deploy**.
**Não** chamar `move_item_to_group`.

## Exemplo MCP — status subtarefa

```json
{
  "boardId": 4571892432,
  "itemId": 12052260363,
  "columnValues": "{\"status\": {\"label\": \"Aguardando correção\"}}"
}
```

## Exemplo MCP — status tarefa principal

```json
{
  "boardId": 4571892384,
  "itemId": 12052222930,
  "columnValues": "{\"status_1\": {\"label\": \"Revisão manual de código\"}}"
}
```

Labels devem existir no board. Se `change_item_column_values` falhar por label inexistente → reportar erro com label tentado; **não** inventar índice.

## Saída obrigatória (chat)

```markdown
## Pós avaliação

| Campo | Valor |
|-------|-------|
| Veredito | `<veredito>` |
| Ações executadas | <lista resumida> |
| Grupo | — (automação Monday após status) \| — (correção) |
| Doc Merge requests | `append` \| `criado` \| `nenhum` \| `erro` \| — |
| Doc Resultado | `append` \| `criado` \| `já anotado` \| `erro` \| — (sempre) |
| Erros | — (ou detalhe) |

### Merge requests (GitLab)

(sempre — qualquer veredito; após § A)

| Repo | Ação | MR | URL |
|------|------|-----|-----|
| … | … | … | … |

### Detalhe (Monday)

| Item | board | item_id | Coluna / ação | Novo valor | Resultado |
|------|-------|---------|---------------|------------|-----------|
| Revisar código | 4571892432 | … | doc Resultado | veredito + data | ok |
| Revisar código | 4571892432 | … | status | Concluída | ok |
| Tarefa | 4571892384 | … | status_1 | Revisão manual de código | ok |
```

## Erros

| Situação | Ação |
|----------|------|
| `## Diff` ausente ou `Status` ≠ `ok` | § Bloqueio; **nenhuma** mutation Monday/GitLab |
| Sem `## Avaliação` | Parar; executar passo 7 |
| Veredito inválido (incl. legados `deve_ser_testada` / `pode_avancar_para_deploy`) | Parar — **não** mapear para QA/deploy; corrigir passo 7 |
| MCP Monday indisponível | Parar; **não** simular mutations |
| MCP GitLab indisponível | Parar antes de Monday (status); pedir GitLab em Settings → MCP — MRs são obrigatórios em **qualquer** veredito |
| MR falhou em todos os repos | Reportar; § A.2 omitido; status do veredito opcional |
| Doc sem `doc_object_id` e `create_doc` falhou | Reportar; seguir § B |
| Subtarefa Revisar código ausente | **Criar** (§ Subtarefa Revisar código no SKILL pai); se `create_item` falhar → parar |
| Subtarefa Executar não encontrada | Reportar aviso no merge de owners; seguir status se possível |
| Mutation parcial | Reportar o que falhou; não reverter automaticamente |

## Proibido

- Alterar tópicos **`## Revisão de código`**, **`## Requisitos não implementados`** ou **`## Análise manual`** no doc (passo 6 / conclusão humana)
- Sobrescrever/apagar conteúdo existente do doc (só **append** em **Merge requests** e **Resultado da revisão**)
- `create_update` / comentários
- Remover owners existentes em **Revisar código** (só merge)
- Mudar status de **Executar**, **Testar** ou **Deploy** (salvo pedido explícito)
- Em qualquer veredito: **`move_item_to_group`** (grupo é da automação Monday via `status_1`)
- Em `pode_avancar_para_revisao_manual`: status **QA**, **Aguardando testes**, **Aguardando deploy**

## Skills relacionadas

| Skill | Papel |
|-------|--------|
| `revisar-tarefa-avaliar-tarefa` | Passo 7 — veredito |
| `monday-task-info` | IDs subtarefas (passo 1) |
| `revisar-tarefa-gerar-requisitos-de-codigo` | Passo 6 — outros tópicos do doc |
