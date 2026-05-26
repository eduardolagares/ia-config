---
name: revisar-tarefa-pos-avaliacao
description: >-
  Passo 8 de revisar-tarefa: executa no Monday as ações conforme o veredito do passo 7
  (status, owners). Se precisa_de_correcao, garante MRs GitLab (branch → master), publica
  links no doc Revisar código (tópico Merge requests) e atualiza status/owners.
disable-model-invocation: true
VERSION: "1.2.3"
---

# revisar-tarefa — pós avaliação (passo 8)

Sub-skill **`pos-avaliacao`** do passo 8. **Escrita** no Monday — status, owners e (se **`precisa_de_correcao`**) doc **Revisar código** (tópico **`## Merge requests`**). Para esse veredito, também **garante MRs** no GitLab (branch → **`master`**).

**GitLab (MRs):** ler **`GITLAB_TOKEN` das variáveis de ambiente da máquina de quem executa** — mesma regra do passo 3 ([SKILL.md](../SKILL.md) § GitLab — autenticação). Scripts `gitlab-api-mr-ensure*` herdam o env; `ctx_execute` usa `process.env.GITLAB_TOKEN`.

**Monday:** `CallMcpTool` com `server`: `plugin-monday.com-monday` (conexão Monday ligada no Cursor — Settings → MCP). Ler schema em `mcps/plugin-monday.com-monday/tools/<tool>.json` antes de cada tool.

**Gate (obrigatório, antes de qualquer mutation):** o passo 3 deve ter entregue **`## Diff`** com **`Status: ok`**. Se `parcial`, `indisponível`, secção ausente ou diff só com **Erro:** em todos os repos → **parar**; **não** alterar status, owners, doc **Merge requests** nem criar MRs. Emitir `## Pós avaliação` em modo bloqueio (§ abaixo).

## Pré-requisito

| Dado | Obrigatório |
|------|-------------|
| **`## Diff`** (passo 3) | Sim — **`Status: ok`** (critérios em [executar-diff](../executar-diff/SKILL.md) § Status do diff) |
| **`## Avaliação`** | Sim — passo 7 (`Veredito`) |
| **Passo 1** | Sim — `item_id` tarefa + subtarefas Executar, Revisar código, Testar |
| **Passo 1 ou 3** (só `precisa_de_correcao`) | **Branch** + lista de repos (`Projetos alterados` ou `## Diff`) |
| **GITLAB_TOKEN** | Sim — **env do executador**, para MRs em `precisa_de_correcao` |
| **Passo 6** (recomendado) | Doc **Revisar código** — se `Ação: nenhum`, § A.2 pode **criar** doc só com MRs |
| **`doc_object_id`** | Sim (§ A.2) — cache `monday-task-info` → `subitems["Revisar código"].doc_object_id` |

## IDs fixos (board Dia a dia)

| Entidade | Board | Coluna status | Coluna owner |
|----------|-------|---------------|--------------|
| Tarefa principal | `4571892384` | `status_1` (Status consolidado) | — |
| Subtarefas | `4571892432` | `status` | `person` |

Resolver `item_id` de cada subtarefa via cache `monday-task-info` ou passo 1.

## Entrada

- **`Veredito`** do `## Avaliação` (passo 7)
- IDs das subtarefas: **Executar**, **Revisar código**, **Testar**
- `item_id` da tarefa principal

## Fluxo (ordem fixa)

0. **Validar diff:** ler `Status` em `## Diff` (passo 3). Se ≠ `ok` → § **Bloqueio (diff indisponível)** e **terminar** (zero mutations Monday/GitLab).
1. Confirmar veredito ∈ {`precisa_de_correcao`, `deve_ser_testada`, `pode_avancar_para_deploy`}.
2. Executar **apenas** o bloco de ações do veredito (§ abaixo).
3. Usar `change_item_column_values` — status: `{"label": "<texto exato>"}`.
4. Reportar cada mutation no chat (sucesso/erro por item).

### Bloqueio (diff indisponível)

Quando o passo 0 falhar — **não** chamar `change_item_column_values`, `create_doc`, `append_blocks`, `gitlab-api-mr-ensure*` nem equivalente MCP.

Entregar no chat:

```markdown
## Pós avaliação

| Campo | Valor |
|-------|-------|
| Veredito (passo 7) | `<veredito>` — **não aplicado** |
| Motivo | Diff GitLab indisponível (`Status: <parcial\|indisponível>`) |
| Ações Monday | **nenhuma** (status/owners/doc MR inalterados) |
| Próximo passo | Corrigir `GITLAB_TOKEN`/cache, rodar prefetch ou repetir passo 3 até `Status: ok` (VPN já ativa no executador) |
```

Opcional: uma linha no chat com o veredito que **teria** sido aplicado — sem executá-lo.

### `precisa_de_correcao`

**Ordem:** GitLab (MRs) → doc Monday (**Merge requests**) → Monday (owners + status).

#### A. Merge requests (GitLab REST API)

Para **cada** `namespace/project` da tarefa (mesma lista do passo 3 — `## Diff` / **Projetos alterados** do passo 1):

1. **Check:** `GITLAB_TOKEN` presente no **env da máquina do executador** (`check-gitlab-ready.sh` ou equivalente); senão parar e pedir `export` no shell local (não pedir token no chat). Monday abaixo só se MRs não forem bloqueantes — preferir parar tudo.
2. Rodar e **mostrar no chat** o JSON resumido:

```bash
scripts/gitlab-api-mr-ensure-bundle.sh \
  --branch "<branch>" --titulo "<título exato da tarefa>" \
  baladapp/repo1 baladapp/repo2
```

| Comportamento | Detalhe |
|---------------|---------|
| Target | **`master`** |
| Source | Branch da tarefa (coluna Monday) |
| MR já aberto `source` → `master` | Reutiliza (`action: existing`) |
| MR aberto com outro target | Atualiza target para `master` (`updated_target`) |
| Sem MR aberto | Cria (`created`) |
| Canal | REST API — scripts `gitlab-api-mr-ensure*`; GitLab MCP proibido |
| Exit **2** | `ctx_execute` com `fetch` ou Terminal integrado (rede do Mac, VPN ativa) |

Título do MR: título da tarefa Monday (ou branch se ausente).

Incluir na saída **`## Pós avaliação`** subsecção **`### Merge requests`** com tabela:

| Repo | Ação | MR | URL |
|------|------|-----|-----|
| `baladapp/…` | `created` \| `existing` \| `updated_target` | `!<iid>` | link |

Erro por repo: linha com **Erro:**; seguir nos demais (doc e status).

Guardar o JSON do bundle (`projects[]` com `web_url` / `iid` / `repo` / `action`) para § A.2.

#### A.2. Documento Revisar código — tópico `## Merge requests`

**Somente** MRs com `web_url` válida no bundle (§ A). **Append** — não alterar **`## Revisão de código`** nem **`## Requisitos não implementados`**.

1. Resolver `doc_object_id` da subtarefa **Revisar código** (cache `monday-task-info` ou passo 1).
2. `read_docs` — `mode: content`, `type: object_ids`, `ids: [<doc_object_id>]`.
3. Extrair do markdown existente (secção **`## Merge requests`** ou variantes `## Merge requests — <data>`):
   - URLs já publicadas (`https://gitlab.baladapp.com.br/...`)
   - Pares `repo` + `!<iid>` (regex `baladapp/[\w.-]+` e `!\d+`)
4. Para cada entrada do bundle com `web_url`:
   - Já no doc (mesma URL **ou** mesmo `repo` + `!iid`) → **SKIP** — reportar `SKIP MR duplicado: <repo>`
   - Novo → incluir na tabela de append
5. Se **nenhum** MR novo após filtro → `Doc MR: nenhum`; seguir § B.
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

8. Atualizar cache `tasks-by-title.json` — `doc_object_id` se `create_doc` retornou novo id (`ctx_execute` + `ctx_index`, `source: monday-task-info:index`).

| Erro | Ação |
|------|------|
| MCP Monday indisponível | Reportar; seguir § B (status) se usuário não bloqueou |
| `update_doc` / `create_doc` falhou | Reportar; **não** simular link no doc |
| Bundle sem nenhum `web_url` | Omitir § A.2; reportar aviso |

Incluir em **`## Pós avaliação`**: linha `Doc Merge requests` = `append` \| `criado` \| `nenhum` \| `erro`.

#### B. Monday (status / owners)

| # | Alvo | Ação |
|---|------|------|
| 1 | Subtarefa **Revisar código** | **Adicionar** owner(s) da subtarefa **Executar** à coluna `person` (merge — **não** remover owners existentes) |
| 2 | Subtarefa **Revisar código** | Status → **`Aguardando correção`** |
| 3 | Tarefa principal | Status → **`Fazendo`** |

**Owner merge (passo 1):**

1. `get_board_items_page` — `itemIds: [<executar_id>, <revisar_codigo_id>]`, `boardId: 4571892432`, `includeColumns: true`.
2. Extrair ids de pessoa da coluna `person` de **Executar** e **Revisar código** (JSON em `value` / `personsAndTeams`).
3. Unir ids únicos; gravar em **Revisar código**:

```json
{"person": {"personsAndTeams": [{"id": <user_id>, "kind": "person"}, ...]}}
```

Se **Executar** não tiver owner → pular merge; reportar aviso; executar passos 2–3.

### `deve_ser_testada`

| # | Alvo | Ação |
|---|------|------|
| 1 | Subtarefa **Revisar código** | Status → **`Concluída`** |
| 2 | Subtarefa **Testar** | Status → **`Aguardando testes`** |
| 3 | Tarefa principal | Status → **`QA`** |

### `pode_avancar_para_deploy`

| # | Alvo | Ação |
|---|------|------|
| 1 | Subtarefa **Revisar código** | Status → **`Concluída`** |
| 2 | Tarefa principal | Status → **`Aguardando deploy`** |

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
  "columnValues": "{\"status_1\": {\"label\": \"Fazendo\"}}"
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
| Doc Merge requests | `append` \| `criado` \| `nenhum` \| `erro` \| — |
| Erros | — (ou detalhe) |

### Merge requests (GitLab)

(só se veredito = `precisa_de_correcao`; senão omitir secção)

| Repo | Ação | MR | URL |
|------|------|-----|-----|
| … | … | … | … |

### Detalhe (Monday)

| Item | board | item_id | Coluna | Novo valor | Resultado |
|------|-------|---------|--------|------------|-----------|
| Revisar código | 4571892432 | … | status | Aguardando correção | ok |
| … | … | … | … | … | … |
```

## Erros

| Situação | Ação |
|----------|------|
| `## Diff` ausente ou `Status` ≠ `ok` | § Bloqueio; **nenhuma** mutation Monday/GitLab |
| Sem `## Avaliação` | Parar; executar passo 7 |
| Veredito inválido | Parar |
| MCP Monday indisponível | Parar; **não** simular mutations |
| `GITLAB_TOKEN` ausente no env (`precisa_de_correcao`) | Parar antes de Monday; pedir `export` no shell local |
| MR falhou em todos os repos | Reportar; § A.2 omitido; Monday § B opcional |
| Doc sem `doc_object_id` e `create_doc` falhou | Reportar; seguir § B |
| Subtarefa não encontrada | Parar; listar subtarefas |
| Mutation parcial | Reportar o que falhou; não reverter automaticamente |

## Proibido

- Alterar tópicos **`## Revisão de código`** ou **`## Requisitos não implementados`** no doc (passo 6)
- Sobrescrever/apagar conteúdo existente do doc (só **append** em **Merge requests**)
- `create_update` / comentários
- Remover owners existentes em **Revisar código** (só merge)
- Mudar status de **Executar** ou **Deploy** (salvo pedido explícito)

## Skills relacionadas

| Skill | Papel |
|-------|--------|
| `revisar-tarefa-avaliar-tarefa` | Passo 7 — veredito |
| `monday-task-info` | IDs subtarefas / cache |
| `revisar-tarefa-gerar-requisitos-de-codigo` | Passo 6 — outros tópicos do doc |
