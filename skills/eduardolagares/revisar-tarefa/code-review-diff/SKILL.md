---
name: revisar-tarefa-code-review-diff
description: >-
  Passo 4 de revisar-tarefa: aplica code-review sobre o diff do passo 3.
  Entrega blocos 1–5 (Crítico, Grave, Padrão de código, Outros, Lacunas de teste).
  Itens 1.M, 2.M e 3.M alimentam o passo 6 (gerar-requisitos-de-codigo). Use após executar-diff ou "code review diff revisar".
disable-model-invocation: true
VERSION: "1.7.1"
---

# revisar-tarefa — code review do diff (passo 4)

Sub-skill do **passo 4** de `revisar-tarefa`. **Somente leitura** — não editar código.

**Protocolo:** aplicar integralmente [../../code-review/SKILL.md](../../code-review/SKILL.md) (`/code-review`) — skill irmã em `skills/eduardolagares/code-review/` (não sob `revisar-tarefa/`).

**Cache:** metadados **só** via context-mode ([../SKILL.md](../SKILL.md) § Cache). Diff truncado → **re-obter** via GitLab MCP; **nunca** indexar/usar conteúdo do diff no cache.

## Fonte obrigatória do `/code-review`

Ao invocar o protocolo neste passo, **declarar explicitamente** à skill `code-review`:

> **Fonte da revisão:** diff extraído no **passo 3** (`executar-diff` via GitLab MCP), secção **`## Diff`** desta conversa — ou **re-fetch** fresco via GitLab MCP se o chat estiver truncado. **Não** usar outro diff, snapshot em cache, nem paths soltos do utilizador fora do passo 3.

Regras:

| Regra | Detalhe |
|-------|---------|
| **Única fonte primária** | Hunks atuais do passo 3 (`## Diff`) ou re-fetch GitLab MCP com os mesmos project/MR/branch |
| **Truncado** | **Re-obter** via MCP GitLab (`mr_review.raw_diffs` / `repository.compare`). **Proibido** confiar em cache/índice antigo do patch; **proibido** cache em disco |
| **Proibido** | Reler repo inteiro, inventar alterações, usar diff de outra branch/tarefa, comparar contra doc/diff guardado em cache |
| **Secundário** | Passo 1 (spec Monday — **reler** `read_docs` se for cruzar conteúdo), passo 2 (requisitos), `docs/specs/tdd/*.md` — só cruzamento de escopo, **não** substituem o diff |

Cada achado `N.M` nos blocos **1–5** deve referir linha/path **presente no diff do passo 3**.

## Cobertura por projeto (obrigatório)

A revisão cobre **todos** os repositórios da tarefa — os mesmos de **`## Diff`** (passo 3), alinhados a **Projetos alterados** (passo 1).

| Regra | Detalhe |
|-------|---------|
| **Lista de projetos** | Um heading `### <namespace/project>` por repo em `## Diff` (ex.: `### baladapp/ingressos`) |
| **Ordem** | Mesma ordem das subsecções em `## Diff` |
| **1 projeto** | Pode omitir headings `###` — itens direto sob `1 - Crítico` / `2 - Grave` / `3 - Padrão de código` |
| **2+ projetos** | **Obrigatório** agrupar: sob cada bloco de severidade, um `### <repo>` antes dos itens daquele repo |
| **Repo sem achados** | Incluir `### <repo>` com `Nenhum.` (Crítico / Grave / Padrão de código) — prova que o projeto foi revisado |
| **Repo só com Erro:** no diff | `### <repo>` + linha explicando indisponibilidade; blocos 1–3 `Nenhum.` para esse repo |
| **Mapear path → repo** | Prefixo do path no hunk define o projeto (ex.: `app/...` no diff de `baladapp/account` → projeto `baladapp/account`) |

**Proibido:** revisar só o repo “principal” (ex.: ingressos) e ignorar account, checkout, assinaturas, react-components, etc.

## Pré-requisito

| Dado | Obrigatório |
|------|-------------|
| **`## Diff`** | Sim — saída completa do passo 3 (`executar-diff`), **todos** os `### <repo>` |
| **Projetos alterados** | Sim — passo 1; deve bater com os repos do diff |
| **Contexto Monday** | Recomendado — passo 1 (spec, branch) |
| **`## Requisitos da tarefa`** | Recomendado — passo 2 (cruzamento escopo) |

Sem diff com conteúdo (só erros por repo) → entregar code review com stocks do bloco 5; não inventar achados.

## Entrada

- Bloco **`## Diff`** do chat (fences `diff` por repo)
- Se truncado: **re-obter** via GitLab MCP; **não** usar cache de conteúdo do diff
- Opcional: paths de `docs/specs/tdd/*.md` nos repositórios do escopo (se existirem no workspace)

## Execução

1. Confirmar que **`## Diff`** do passo 3 está no contexto (senão → parar e executar passo 3).
2. Montar **lista de projetos** = todos os `### <namespace/project>` em `## Diff`; cruzar com **Projetos alterados** do passo 1.
3. Para **cada** projeto da lista, aplicar o protocolo **só** nos hunks daquele fence — read-only, pt-BR, ids `N.M` **por projeto** (reiniciar `M` em cada bloco de severidade **ou** numerar globalmente; preferir **global** `1.1`, `1.2`… mantendo agrupamento visual por `### <repo>`).
4. Ler [../../code-review/SKILL.md](../../code-review/SKILL.md) e seguir **todas** as regras (read-only, pt-BR, blocos 1–5).
5. **Aplicar code-review com fonte = diff do passo 3** — secção **Fontes (ordem fixa)**: item 1 é **exclusivamente** esse diff; regras/convenções/spec TDD entram nos itens 2–3.
6. **Não** reler o repositório inteiro salvo para confirmar contexto de uma linha duvidosa **já visível no diff**.
7. **Spec TDD:** se houver `docs/specs/tdd/*.md` aplicável, cruzar **paths que aparecem no diff do passo 3** ↔ escopo da spec (por projeto).
8. **Bloco 5:** lacunas **por projeto** — comparar diff ↔ testes de cada repo (sem rodar suite, sem cobertura %).
9. **Não** duplicar itens do passo 2; achados vão para o doc **Revisar código** no passo 6 (tópico **Revisão de código**, agrupado por projeto).

## Saída obrigatória

Entregar **somente** este bloco (títulos **exatos** do code-review):

```markdown
## Code review

`1 - Crítico`

### baladapp/ingressos

- **1.1** — **Onde:** `path` — **Problema:** … — **Correção:** … — **Hipótese de falha:** …

### baladapp/account

Nenhum.

`2 - Grave`

### baladapp/ingressos

- **2.1** — …

### baladapp/account

Nenhum.

`3 - Padrão de código`

### baladapp/ingressos

- **3.1** — **Onde:** `path` — **Problema:** … — **Correção:** … — **regra:** `rules/eduardolagares/…`

### baladapp/account

Nenhum.

`4 - Outros`

### baladapp/ingressos

- **4.1** — …

`5 - Lacunas de teste frente ao diff`

### baladapp/ingressos

- **5.1** — …
```

(Com **um** repo no diff, omitir `### <repo>` e listar itens direto sob cada bloco de severidade.)

### Regras de formato

- Títulos de secção: strings literais do code-review (`1 - Crítico`, etc.) — pode usar heading markdown `### 1 - Crítico` ou linha solta conforme legibilidade.
- **2+ repos:** sob cada bloco de severidade, heading `### <namespace/project>` antes dos itens; **todos** os repos do diff devem aparecer.
- Secção vazia (bloco inteiro) → `Nenhum.`; secção vazia **só num repo** → `### <repo>` + `Nenhum.`
- Cada item com substância nos blocos **1** e **2** → prefixo `1.M` / `2.M` + **onde** (path do diff desse repo) + **problema** + **correção** + **Hipótese de falha:**
- Cada item com substância no bloco **3** → prefixo `3.M` + **onde** + **problema** + **correção** + **regra:** (path da rule violada)
- **Não** repetir o diff integral no chat.
- **Não** implementar correções em disco.

## Handoff para passo 6

| Bloco code review | Uso no passo 6 |
|-----------------|----------------|
| **1 - Crítico** (`1.M`) | Tópico **`## Revisão de código`** → subsecção **`### Crítico`** — checkbox `- [ ]`, **agrupado por `#### <repo>`** |
| **2 - Grave** (`2.M`) | Idem → **`### Grave`** |
| **3 - Padrão de código** (`3.M`) | Idem → **`### Padrão de código`** — **mesmo peso** que Crítico/Grave (decisor de veredito no passo 7) |
| **4 - Outros** | Não publicar |
| **5 - Lacunas** | Não publicar (salvo pedido explícito) |

Passo 6: [gerar-requisitos-de-codigo/SKILL.md](../gerar-requisitos-de-codigo/SKILL.md) — publica **1.M**, **2.M** e **3.M** no tópico **Revisão de código** (Monday; cria doc se ausente).

## Erros

| Situação | Ação |
|----------|------|
| Sem `## Diff` no contexto | Parar; executar passo 3 |
| Diff só com **Erro:** por repo | Code review por repo com erro; blocos 1–5 `Nenhum.` ou stock bloco 5 |
| Diff truncado no chat | **Re-obter** via GitLab MCP; **não** usar índice/cache do patch |
| Tentação de editar código | Recusar — read-only |

## Skills relacionadas

| Skill | Papel |
|-------|--------|
| `code-review` | Protocolo de review |
| `revisar-tarefa-executar-diff` | Passo 3 — fornece diff |
| `revisar-tarefa-verificar-requisitos-usuario` | Passo 5 — verificação R* vs diff |
| `revisar-tarefa-gerar-requisitos-de-codigo` | Passo 6 — publica no doc Revisar código |
| `revisar-tarefa-avaliar-tarefa` | Passo 7 |
| `revisar-tarefa-pos-avaliacao` | Passo 8 |
| `revisar-tarefa-gerar-requisitos-de-usuario` | Passo 2 — requisitos de usuário |
