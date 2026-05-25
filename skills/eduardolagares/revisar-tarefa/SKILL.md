---
name: revisar-tarefa
description: >-
  Coleta contexto de tarefa no Monday, gera e verifica requisitos, diff GitLab, code review,
  publica achados, avalia veredito e atualiza status/owners no Monday. Use com /revisar-tarefa
  ou "revisar tarefa monday".
disable-model-invocation: true
VERSION: "5.3.1"
---

# `/revisar-tarefa`

Oito passos: contexto → requisitos → diff → code review → verificação → publicação doc → **avaliação** → **pós avaliação** (Monday).

**Pacote:** `skills/eduardolagares/revisar-tarefa/` (instalada em `{dest}/skills/eduardolagares/revisar-tarefa/`). Sub-skills e `scripts/` usam paths **relativos** a esta pasta.

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
- **Saída:** secção **`## Diff`** — branch vs **`master`** por repo.
- **Proibido:** clones locais, GitLab MCP e `glab`.

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

- **Entrada:** passo 1 (status **Testar**) + doc **Revisar código** (após passo 6).
- **Lógica:**
  - Existe item pendente em **Revisão de código** ou **Requisitos não implementados** (checkbox `- [ ]`, exceto `#ignorar`) → **não pode avançar** → veredito **`precisa_de_correcao`**.
  - Senão, subtarefa **Testar** concluída → **`pode_avancar_para_deploy`**.
  - Senão → **`deve_ser_testada`**.
- **Saída:** **`## Avaliação`** com veredito.
- **Somente leitura.**

## Passo 8 — Pós avaliação (`pos-avaliacao`)

**Obrigatório.** Aplicar a sub-skill:

`pos-avaliacao/SKILL.md`

- **Entrada:** **`## Avaliação`** (passo 7) + IDs do passo 1 / cache.
- **Saída:** **`## Pós avaliação`** — mutations executadas.

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

Não pular. Passos **6** e **8** escrevem no doc **Revisar código** (passo 6: revisão + R*; passo 8: **Merge requests** se `precisa_de_correcao`). Passo **8** também altera status/owners. GitLab: **leitura** no passo 3; **escrita** no passo 8 se `precisa_de_correcao` (MR → `master`).

## Erros

| Situação | Ação |
|----------|------|
| MCP Monday indisponível | Parar ou fallback leitura; passo 8 não simular |
| Passo N sem saída do N−1 | Voltar ao passo em falta |
| `GITLAB_TOKEN` ausente | Parar no passo 3 |
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
