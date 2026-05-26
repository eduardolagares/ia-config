---
name: revisar-tarefa
description: >-
  Coleta contexto de tarefa no Monday, gera e verifica requisitos, diff GitLab, code review,
  publica achados, avalia veredito e atualiza status/owners no Monday. Use com /revisar-tarefa
  ou "revisar tarefa monday".
disable-model-invocation: true
VERSION: "5.4.5"
---

# `/revisar-tarefa`

Oito passos: contexto → requisitos → diff → code review → verificação → publicação doc → **avaliação** → **pós avaliação** (Monday).

**Pacote:** `skills/eduardolagares/revisar-tarefa/` (instalada em `{dest}/skills/eduardolagares/revisar-tarefa/`). Sub-skills e `scripts/` usam paths **relativos** a esta pasta.

## GitLab — rede (VPN)

`gitlab.baladapp.com.br` **só** é alcançável pela **VPN** da empresa. **Premissa:** a VPN **já está ativa** no computador de quem executa a skill (hook `beforeSubmitPrompt`, Terminal integrado ou sessão do agente na mesma máquina).

- **Não** pedir para “ligar a VPN” como passo padrão de troubleshooting.
- Se a API falhar, verificar primeiro: `GITLAB_TOKEN`, escopo do PAT, cache/hook, sandbox do agente (`ctx_execute`).
- Só considerar VPN desligada se o utilizador confirmar que a ligação caiu.

## GitLab — autenticação

Sempre que usar GitLab nesta skill (passos **3** e **8**, scripts `gitlab-api-*`, hook `prefetch-diff`, `ctx_execute` com `fetch`):

1. **Ler `GITLAB_TOKEN` das variáveis de ambiente da máquina de quem executa** — shell do utilizador, Terminal integrado do Cursor ou processo do hook. O agente **não** inventa token, **não** pede para colar no chat e **não** grava em ficheiros do repo.
2. **Antes de API ou scripts:** confirmar presença (`scripts/check-gitlab-ready.sh` ou equivalente). Se `missing`, parar e pedir `export GITLAB_TOKEN="glpat-..."` no perfil do shell (`~/.zshrc`, `~/.bashrc`, etc.) e reiniciar o Cursor ou o Terminal integrado.
3. **Shell do agente bloqueado:** em `ctx_execute`, usar `process.env.GITLAB_TOKEN` herdado do ambiente da sessão — mesma regra: só o env do executador.
4. **OAuth / GitLab MCP** do plugin Cursor **não** substitui `GITLAB_TOKEN` para REST API desta skill (passo 3 proíbe MCP; passo 8 usa só scripts `gitlab-api-*`).

Detalhes: [reference-gitlab-api.md](reference-gitlab-api.md).

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

- Seguir `~/.agents/skills/monday-task-info/SKILL.md` (MCP Monday + cache context-mode).
- Entregar a **saída markdown completa** no chat (formato obrigatório daquela skill).
- **Não** usar `fetch-task.sh` / GraphQL manual, salvo falha do MCP (fallback: `scripts/fetch-task.sh` + aviso).

## Passo 2 — Requisitos de usuário (`gerar-requisitos-de-usuario`)

**Obrigatório.** Aplicar a sub-skill:

`gerar-requisitos-de-usuario/SKILL.md`

- **Entrada:** saída markdown do Passo 1 — **somente secção Documento** (documento principal).
- **Saída:** secção **`## Requisitos da tarefa`** — itens **`R*`** só da spec do documento principal.

## Passo 3 — DIFF (`executar-diff`)

**Obrigatório.** Aplicar a sub-skill:

`executar-diff/SKILL.md`

- **Entrada:** branch e projetos/repos da saída do Passo 1.
- **Check (início):** `scripts/check-gitlab-ready.sh --branch "<branch>" --titulo "<título>"`.
- **Saída:** secção **`## Diff`** — branch vs **`master`** por repo, com linha **`Status:`** `ok` \| `parcial` \| `indisponível` (ver `executar-diff`).
- **Canal:** cache + REST API (`gitlab-api-*`); ver [executar-diff/SKILL.md](executar-diff/SKILL.md). **Proibido:** GitLab MCP.
- **Bloqueio:** se **`Status: indisponível`** ou **`parcial`**, **não** avançar ao passo 8 — ver § Passo 8.

## Passo 4 — Code review do diff (`code-review-diff`)

**Obrigatório.** Aplicar a sub-skill:

`code-review-diff/SKILL.md`

- **Entrada:** `## Diff` (passo 3) + **Projetos alterados** do passo 1.
- **Cobertura:** revisar **cada** repositório/projeto presente em `## Diff` (e listado em Projetos alterados). Um projeto sem achados → subsecção com `Nenhum.` — **não** omitir o projeto.
- **Protocolo:** `code-review` — fonte primária = diff do passo 3, **por projeto**.
- **Saída:** secção **`## Code review`** (blocos 1–4); itens **1.M** / **2.M** agrupados por projeto quando houver mais de um repo.

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
- **Tópicos:** **`## Revisão de código`** (`1.M`/`2.M`, **agrupados por projeto** se 2+ repos) e **`## Requisitos não implementados`** (`R*`).
- **Não** alterar status (passo 8).

## Passo 7 — Avaliação (`avaliar-tarefa`)

**Obrigatório.** Aplicar a sub-skill:

`avaliar-tarefa/SKILL.md`

- **Entrada:** passo 1 (status **Testar**) + **`## Diff`** (passo 3) + doc **Revisar código** (após passo 6).
- **Lógica:**
  - Para cada item aberto em **Revisão de código** ou **Requisitos não implementados** (exceto `#ignorar`), cruzar com o diff; se **cumprido** → marcar checkbox no doc Monday (`update_doc` / `checked: true`).
  - Ainda existe `- [ ]` nas secções acima → **não pode avançar** → veredito **`precisa_de_correcao`**.
  - Senão, subtarefa **Testar** concluída → **`pode_avancar_para_deploy`**.
  - Senão → **`deve_ser_testada`**.
- **Saída:** **`## Avaliação`** com veredito e ids marcados cumpridos.
- **Escrita Monday:** somente checkboxes cumpridos no doc **Revisar código** (status → passo 8).

## Passo 8 — Pós avaliação (`pos-avaliacao`)

**Obrigatório** — **somente se** o passo 3 entregou **`## Diff`** com **`Status: ok`**. Aplicar a sub-skill:

`pos-avaliacao/SKILL.md`

- **Entrada:** **`## Avaliação`** (passo 7) + IDs do passo 1 / cache + **`## Diff`** com **`Status: ok`**.
- **Saída:** **`## Pós avaliação`** — mutations executadas, **ou** bloqueio documentado (sem alterar status/owners no Monday).
- **Proibido sem diff válido:** `change_item_column_values` de status/owner, MRs GitLab e append em **Merge requests** — **nenhuma** decisão final no Monday (QA, Fazendo, Aguardando deploy, Aguardando correção, etc.).

| Veredito | Ações |
|----------|--------|
| `precisa_de_correcao` | **MR** por repo (`branch` → `master`); links no doc **Merge requests**; owner **Executar** → **Revisar código**; Revisar código → **Aguardando correção**; tarefa → **Fazendo** |
| `deve_ser_testada` | Revisar código → **Concluída**; Testar → **Aguardando testes**; tarefa → **QA** |
| `pode_avancar_para_deploy` | Revisar código → **Concluída**; tarefa → **Aguardando deploy** |

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

Não pular passos 1–7. Passos **6** e **7** escrevem no doc **Revisar código** (passo 6: append revisão + R*; passo 7: marca itens **cumpridos**). Passo **8** só corre com **`## Diff` · `Status: ok`**; aí altera status/owners e, se `precisa_de_correcao`, **Merge requests** + MRs. GitLab: **leitura** no passo 3; **escrita** no passo 8 condicionada a diff **ok**.

## Erros

| Situação | Ação |
|----------|------|
| MCP Monday indisponível | Parar ou fallback leitura; passo 8 não simular |
| Passo N sem saída do N−1 | Voltar ao passo em falta |
| `GITLAB_TOKEN` ausente no env do executador | Parar no passo 3; passo 8 **proibido** |
| `## Diff` com `Status: parcial` ou `indisponível` | **Não** executar passo 8; reportar bloqueio em `## Pós avaliação` |
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
7. **Avaliação** → ex. `deve_ser_testada`  
8. **Pós avaliação** → status QA, Testar aguardando, Revisar código concluída  

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
| `code-review` | Protocolo passo 4 |
