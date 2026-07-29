---
name: revisar-tarefa
description: >-
  Coleta contexto de tarefa no Monday, gera e verifica requisitos, diff GitLab, code review,
  publica achados, avalia veredito e atualiza status/owners no Monday. Use com /revisar-tarefa
  ou "revisar tarefa monday".
disable-model-invocation: true
VERSION: "6.4.0"
---

# `/revisar-tarefa`

Oito passos: contexto → requisitos → diff → code review → verificação → publicação doc → **avaliação** → **pós avaliação** (Monday).

**Pacote:** `skills/eduardolagares/revisar-tarefa/` (instalada em `{dest}/skills/eduardolagares/revisar-tarefa/`). Sub-skills usam paths **relativos** a esta pasta. Sem scripts de API.

## Receitas MCP (pré-estabelecidas — não rediscobrir)

Antes de cada passo que toca Monday/GitLab, usar as receitas prontas (action/tool + JSON). **Não** gastar turnos em `gitlab_find_action` / schema hunting se o action já está documentado.

| Canal | Servidor típico | Reference | Uso |
|-------|-----------------|-----------|-----|
| Monday | `user-monday-mcp` | [../monday-task-info/reference-mcp-monday.md](../monday-task-info/reference-mcp-monday.md) | passos 1, 6–8 |
| GitLab | `user-gitlab` | [reference-gitlab-mcp.md](reference-gitlab-mcp.md) | passos 3, 8 |

**Atalhos validados:**

| Necessidade | Tool / action |
|-------------|---------------|
| Listar workspaces Monday | `list_workspaces` |
| Buscar quadro | `search` (`searchType: BOARD`, `searchTerm` obrigatório) |
| Metadados board / grupos | `get_board_info` (`boardId: 4571892384`) |
| Item + subtarefas | `get_board_items_page` |
| Ler / append / checkbox doc | `read_docs` / `update_doc` |
| Status / owner | `change_item_column_values` |
| Mover grupo | `all_api_write` → `move_item_to_group` (`group_mm5j20e`) |
| Diff via MR | `gitlab_execute_action` → `merge_request.list` → `mr_review.raw_diffs` |
| Diff sem MR | `repository.compare` (`from: master`, `to: branch`) |
| Criar / ajustar MR | `merge_request.create` / `merge_request.update` (`target_branch: master`) |

Resolver `server` com `GetMcpTools` se o id da sessão for outro; se `needsAuth` → `mcp_auth`.

## Cache (só context-mode)

Se algum passo precisar **guardar ou reconsultar** payload grande (diff, doc Monday, JSON de MCP) fora do chat curto:

| Regra | Detalhe |
|-------|---------|
| **Único cache** | MCP **context-mode** da IDE (`GetMcpTools` / `mcps/*context-mode*` — ex. `plugin-context-mode-context-mode`) |
| **Tools** | `ctx_index` + `ctx_search` (e `ctx_execute` / `ctx_execute_file` quando couber) |
| **Indisponível** | **Não** usar cache — nem disco, nem scripts, nem inventar store. Trabalhar só com o que couber no chat (resumir / truncar e avisar) |
| **Proibido** | `tasks-by-title.json`, ficheiros locais de cache, `write-task-cache`, prefetch |

IDs pequenos do passo 1 (item, subtarefas, branch) ficam no **markdown da conversa** — isso não é “cache”; não exige context-mode.

## Monday — requisito obrigatório

O Monday é **requisito** (passos 1 e 6–8). Sem MCP Monday da IDE não há contexto nem escrita de status/doc.

- **Canal único:** MCP Monday instalado na IDE de quem executa — ver [../monday-task-info/reference-mcp-monday.md](../monday-task-info/reference-mcp-monday.md).
- **Monday indisponível** = MCP Monday ausente/`needsAuth` sem resolução.
- Nesse caso a skill **para** — **não** inventar contexto, **não** simular escrita. Reportar bloqueio (Settings → MCP → Monday).

## Monday — MCP (IDE)

Sempre que usar Monday nesta skill (passos **1**, **6**, **7**, **8**):

1. **`CallMcpTool`** no servidor **Monday MCP** da IDE (`GetMcpTools` / `mcps/*monday*` — ex. `plugin-monday.com-monday`, `user-monday-mcp`).
2. Auth só via MCP (`mcp_auth` se necessário).
3. **Proibido:** `MONDAY_API_TOKEN`, GraphQL/REST contra `api.monday.com`, curl/`fetch` com token, `monday.env` como autenticação.

Detalhes: [../monday-task-info/reference-mcp-monday.md](../monday-task-info/reference-mcp-monday.md).

## GitLab — requisito obrigatório

O GitLab é **requisito para o funcionamento da skill**. Sem diff válido do GitLab não há base para code review, avaliação nem decisão de status.

- **Canal único:** MCP GitLab instalado na IDE de quem executa — ver [reference-gitlab-mcp.md](reference-gitlab-mcp.md).
- **GitLab indisponível** = MCP GitLab ausente/`needsAuth` sem resolução **ou** o passo 3 entrega `## Diff` com `Status: parcial` \| `indisponível`.
- Nesse caso a skill **para** e **não move a tarefa no Monday**: **nenhuma** escrita de status/owner, MR ou append em **Merge requests** (passo 8 proibido). Reportar o bloqueio (MCP GitLab / VPN se o utilizador confirmar).
- Só o passo 8 (movimentar Monday) corre com `## Diff` · `Status: ok`.

## GitLab — rede (VPN)

`gitlab.baladapp.com.br` **só** é alcançável pela **VPN** da empresa. **Premissa:** a VPN **já está ativa** no computador de quem executa a skill.

- **Não** pedir para “ligar a VPN” como passo padrão de troubleshooting.
- Se o MCP falhar, verificar primeiro: GitLab ligado em **Settings → MCP**, auth (`mcp_auth`), status `ready`.
- Só considerar VPN desligada se o utilizador confirmar que a ligação caiu.

## GitLab — MCP (IDE)

Sempre que usar GitLab nesta skill (passos **3** e **8**):

1. **`CallMcpTool`** no servidor **GitLab MCP** da IDE de quem executa (`GetMcpTools` / `mcps/*gitlab*` — ex. `user-gitlab`).
2. Preferir `gitlab_find_action` + `gitlab_execute_action`. Auth só via MCP (`mcp_auth` se necessário).
3. **Proibido:** `GITLAB_TOKEN`, PAT no chat, curl/`fetch` REST `/api/v4`, qualquer script de API GitLab.

Detalhes: [reference-gitlab-mcp.md](reference-gitlab-mcp.md).

## Entrada

```
/revisar-tarefa <título exato da tarefa>
```

- Board: **Dia a dia** (`4571892384`)
- Título: **exato** (via `monday-task-info`)
  - 0 itens → erro
  - 2+ itens → listar opções; pedir qual item

## Passo 1 — Contexto da tarefa (`monday-task-info`)

**Obrigatório.** Aplicar a skill **`monday-task-info`** com o mesmo título:

```
/monday-task-info <título exato da tarefa>
```

- Seguir `skills/eduardolagares/monday-task-info/SKILL.md` — **`CallMcpTool`** no Monday MCP da IDE.
- Entregar a **saída markdown completa** no chat (formato daquela skill); IDs ficam no contexto da conversa.
- Monday fora do MCP (API direta, token, GraphQL, scripts) → **proibido** — não há alternativa neste pacote.
- MCP Monday indisponível → **parar** (sem simular contexto).

## Passo 2 — Requisitos de usuário (`gerar-requisitos-de-usuario`)

**Obrigatório.** Aplicar a sub-skill:

`gerar-requisitos-de-usuario/SKILL.md`

- **Entrada:** saída markdown do Passo 1 — **somente secção Documento** (documento principal).
- **Saída:** secção **`## Requisitos da tarefa`** — itens **`R*`** só da spec do documento principal.

## Passo 3 — DIFF (`executar-diff`)

**Obrigatório.** Aplicar a sub-skill:

`executar-diff/SKILL.md`

- **Entrada:** branch e projetos/repos da saída do Passo 1.
- **Saída:** secção **`## Diff`** — branch vs **`master`** por repo, com linha **`Status:`** `ok` \| `parcial` \| `indisponível` (ver `executar-diff`).
- **Canal:** só GitLab MCP da IDE; ver [executar-diff/SKILL.md](executar-diff/SKILL.md) e [reference-gitlab-mcp.md](reference-gitlab-mcp.md).
- **Bloqueio:** se **`Status: indisponível`** ou **`parcial`** (GitLab indisponível — requisito da skill), **parar** e **não mover a tarefa no Monday** — passo 8 proibido; ver § GitLab — requisito obrigatório e § Passo 8.

## Passo 4 — Code review do diff (`code-review-diff`)

**Obrigatório.** Aplicar a sub-skill:

`code-review-diff/SKILL.md`

- **Entrada:** `## Diff` (passo 3) + **Projetos alterados** do passo 1.
- **Cobertura:** revisar **cada** repositório/projeto presente em `## Diff` (e listado em Projetos alterados). Um projeto sem achados → subsecção com `Nenhum.` — **não** omitir o projeto.
- **Protocolo:** skill irmã `skills/eduardolagares/code-review/SKILL.md` (via `code-review-diff`) — fonte primária = diff do passo 3, **por projeto**. Saída = relatório do protocolo `code-review`.
- **Saída:** secção **`## Code review`** (blocos 1–5); itens **1.M** / **2.M** / **3.M** agrupados por projeto quando houver mais de um repo.

## Passo 5 — Verificação de requisitos (`verificar-requisitos-usuario`)

**Obrigatório.** Aplicar a sub-skill:

`verificar-requisitos-usuario/SKILL.md`

- **Entrada:** `## Requisitos da tarefa` (passo 2) + `## Diff` (passo 3).
- **Saída:** **`## Verificação de requisitos`** + **`### Requisitos não implementados`**.
- **Somente leitura.**

## Passo 6 — Publicar doc Revisar código (`gerar-requisitos-de-codigo`)

**Obrigatório.** Aplicar a sub-skill:

`gerar-requisitos-de-codigo/SKILL.md`

- **Entrada:** code review (passo 4) + verificação (passo 5).
- **Saída:** **`## Requisitos de código`** — confirmação do doc Monday.
- **Tópicos:** **`## Revisão de código`** (`1.M`/`2.M`/`3.M` — Crítico, Grave, Padrão de código; **agrupados por projeto** se 2+ repos) e **`## Requisitos não implementados`** (`R*`).
- **Não** alterar status (passo 8).

## Passo 7 — Avaliação (`avaliar-tarefa`)

**Obrigatório.** Aplicar a sub-skill:

`avaliar-tarefa/SKILL.md`

- **Entrada:** passo 1 + **`## Diff`** (passo 3) + doc **Revisar código** (após passo 6).
- **Lógica:**
  - Para cada item aberto em **Revisão de código** (Crítico, Grave ou **Padrão de código**) ou **Requisitos não implementados** (exceto `#ignorar`), cruzar com o diff; se **cumprido** → marcar checkbox no doc Monday (`update_doc` / `checked: true`).
  - **`## Análise manual`:** itens abertos **bloqueiam** avanço e **não** são marcados pelo agente (conclusão só humana no Monday).
  - Ainda existe `- [ ]` em **Revisão de código** (inclui **Padrão de código**), **Requisitos não implementados** ou **Análise manual** → **não pode avançar** → veredito **`precisa_de_correcao`** (passo 8: **Revisar código** → Aguardando correção; tarefa → **Fazendo**).
  - Senão → **`pode_avancar_para_revisao_manual`** (passo 8: grupo + status **Revisão manual de código** — **não** QA, testes nem deploy).
- **Saída:** **`## Avaliação`** com veredito e ids marcados cumpridos.
- **Escrita Monday:** somente checkboxes cumpridos no doc **Revisar código** (status/grupo → passo 8).

## Passo 8 — Pós avaliação (`pos-avaliacao`)

**Obrigatório** — **somente se** o passo 3 entregou **`## Diff`** com **`Status: ok`**. Aplicar a sub-skill:

`pos-avaliacao/SKILL.md`

- **Entrada:** **`## Avaliação`** (passo 7) + IDs do passo 1 + **`## Diff`** com **`Status: ok`**.
- **Saída:** **`## Pós avaliação`** — mutations executadas, **ou** bloqueio documentado (sem alterar status/owners no Monday).
- **Proibido sem diff válido:** `change_item_column_values` de status/owner, `move_item_to_group`, MRs GitLab e append em **Merge requests** — **nenhuma** decisão final no Monday (Fazendo, Aguardando correção, Revisão manual de código, etc.).

| Veredito | Ações |
|----------|--------|
| `precisa_de_correcao` | **MR** por repo (`branch` → `master`) via GitLab MCP; links no doc **Merge requests**; owner **Executar** → **Revisar código**; Revisar código → **Aguardando correção**; tarefa → **Fazendo** |
| `pode_avancar_para_revisao_manual` | Revisar código → **Concluída**; tarefa → grupo **Revisão manual de código** + status consolidado **Revisão manual de código** (**proibido** QA / testes / deploy) |

Ver detalhes e formato MCP: [pos-avaliacao/SKILL.md](pos-avaliacao/SKILL.md).

## Ordem fixa

1. `monday-task-info`
2. `gerar-requisitos-de-usuario`
3. `executar-diff`
4. `code-review-diff`
5. `verificar-requisitos-usuario`
6. `gerar-requisitos-de-codigo`
7. `avaliar-tarefa`
8. `pos-avaliacao`

Não pular passos 1–7. Passos **6** e **7** escrevem no doc **Revisar código** (passo 6: append revisão + R*; passo 7: marca itens **cumpridos**). Passo **8** só corre com **`## Diff` · `Status: ok`**; aí altera status/owners e, se `precisa_de_correcao`, **Merge requests** + MRs. GitLab: **leitura** no passo 3; **escrita** no passo 8 condicionada a diff **ok** — ambos só via MCP da IDE.

## Erros

| Situação | Ação |
|----------|------|
| MCP Monday indisponível | Parar no passo 1; passos 6–8 não simular escrita |
| Passo N sem saída do N−1 | Voltar ao passo em falta |
| MCP GitLab indisponível / sem auth | GitLab indisponível → **parar** no passo 3; **não** mover a tarefa no Monday; passo 8 **proibido** |
| GitLab indisponível (`## Diff` com `Status: parcial`/`indisponível`) | **Parar**; **não** mover a tarefa no Monday (sem status/owner/MR); reportar bloqueio em `## Pós avaliação` |
| Passo 8 sem avaliação | Voltar ao passo 7 |
| Título ambíguo | Não escolher item aleatório |

## Exemplo

```
/revisar-tarefa Ajustar e-mail de transferência aceita
```

1. Contexto Monday  
2. Requisitos R*  
3. Diff  
4. Code review  
5. Verificação R*  
6. Doc Revisar código  
7. **Avaliação** → ex. `pode_avancar_para_revisao_manual`  
8. **Pós avaliação** → grupo/status **Revisão manual de código**, Revisar código concluída  

## Skills relacionadas

| Skill | Papel |
|-------|--------|
| `monday-task-info` | Passo 1 |
| `revisar-tarefa-gerar-requisitos-de-usuario` | Passo 2 |
| `revisar-tarefa-executar-diff` | Passo 3 |
| `revisar-tarefa-code-review-diff` | Passo 4 |
| `revisar-tarefa-verificar-requisitos-usuario` | Passo 5 |
| `revisar-tarefa-gerar-requisitos-de-codigo` | Passo 6 |
| `revisar-tarefa-avaliar-tarefa` | Passo 7 |
| `revisar-tarefa-pos-avaliacao` | Passo 8 |
| `code-review` (`../code-review/`) | Protocolo passo 4 |
