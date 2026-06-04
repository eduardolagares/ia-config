---
name: revisar-tarefa-gerar-requisitos-de-codigo
description: >-
  Passo 6 de revisar-tarefa: publica no documento Monday da subtarefa Revisar código
  os tópicos Revisão de código (1.M/2.M) e Requisitos não implementados (R*). Cria doc
  se ausente. Respeita #ignorar em itens existentes.
disable-model-invocation: true
VERSION: "2.2.2"
---

# revisar-tarefa — gerar requisitos de código (passo 6)

Sub-skill **`gerar-requisitos-de-codigo`** do passo 6. **Escrita** no Monday — **somente** documento da subtarefa **Revisar código** (coluna `monday_doc`). **Não** alterar status de subtarefas nem publicar updates.

**Monday:** `CallMcpTool`, `server`: `plugin-monday.com-monday` apenas. Ler schema em `mcps/plugin-monday.com-monday/tools/<tool>.json` antes de cada tool.

## Pré-requisito

| Dado | Obrigatório |
|------|-------------|
| **`## Code review`** | Sim — passo 4 (blocos `1 - Crítico` e `2 - Grave`) |
| **`## Verificação de requisitos`** | Sim — passo 5 (**Requisitos não implementados**) |
| **Subtarefa Revisar código** | Sim — `item_id` do passo 1 ou cache `monday-task-info` |

Ambos vazios (blocos 1/2 `Nenhum.` **e** requisitos não implementados `Nenhum.`) → encerrar com `Ação: nenhum`; **não** criar doc vazio.

## Entrada

- Itens **`1.M`** (Crítico) e **`2.M`** (Grave) do `## Code review`
- Itens **`R*`** da secção **Requisitos não implementados** do passo 5
- `item_id` / `doc_object_id` da subtarefa **Revisar código**

Subboard subtarefas: **`4571892432`**. Coluna doc: **`monday_doc`**.

## Estrutura do documento Monday

Quatro tópicos no documento (headings **`##`**). O passo 6 preenche os dois primeiros; **`## Análise manual`** pode existir antes (itens inseridos à mão ou por outro fluxo); **`## Merge requests`** é preenchido no passo 8 quando veredito = `precisa_de_correcao` ([pos-avaliacao](../pos-avaliacao/SKILL.md) § A.2).

```markdown
# Revisar código

Documento gerado por /revisar-tarefa.

## Revisão de código

### Crítico

#### baladapp/ingressos

- [ ] **1.1** — **Onde:** `path` — **Problema:** … — **Correção:** … — **Hipótese de falha:** …

#### baladapp/account

Nenhum.

### Grave

#### baladapp/ingressos

- [ ] **2.1** — …

## Requisitos não implementados

- [ ] **R2** — <texto>. Evidência: …

## Análise manual

- [ ] **M1** — <texto>. Verificação humana obrigatória.

## Merge requests

| Repo | MR | Branch → target | URL |
|------|-----|-----------------|-----|
| baladapp/ingressos | !306 | `dev-foo` → `master` | https://gitlab.baladapp.com.br/... |
```

| Tópico | Conteúdo | Origem |
|--------|----------|--------|
| **`## Revisão de código`** | Checkboxes `1.M` / `2.M` | Passo 4 |
| **`## Requisitos não implementados`** | Checkboxes `R*` | Passo 5 |
| **`## Análise manual`** | Checkboxes `M*` (ou bullets `- [ ]`) | Fora do passo 6 por defeito — **não** sobrescrever; passo 7 bloqueia se aberto |
| **`## Merge requests`** | Tabela repo / MR / branch→master / URL | Passo 8 (`precisa_de_correcao`) — **não** publicar no passo 6 |

### Agrupamento por projeto (passo 6)

| Regra | Detalhe |
|-------|---------|
| **Quando** | **2+** repositórios no `## Code review` / `## Diff` |
| **Heading** | `#### <namespace/project>` (ex.: `#### baladapp/ingressos`) **dentro** de `### Crítico` e `### Grave` |
| **1 repo** | Omitir `####` — bullets direto sob `### Crítico` / `### Grave` |
| **Repo sem itens** | Incluir `#### <repo>` + `Nenhum.` — espelha passo 4 |
| **Mapeamento** | Path em **Onde:** → repo do `###` correspondente no diff; dúvida → repo do `diff_file` |

**Proibido:** publicar lista plana de `1.M`/`2.M` sem agrupar quando a tarefa tem vários projetos.

## Fluxo MCP (ordem fixa)

### 0. Resolver subtarefa Revisar código

Cache: `monday-task-info/cache/tasks-by-title.json` → `subitems["Revisar código"].item_id` / `doc_object_id`.

Se cache miss: `get_board_items_page` com `itemIds: [<item_id_tarefa>]`, `boardId: 4571892384`, `includeSubItems: true` → subtarefa `Revisar código` ou `Revisão de código`.

### 1. Ler documento existente (se houver)

`read_docs` com `mode: content`, `type: object_ids`, `ids: [<objectId>]`.

Extrair de `blocks_as_markdown` (ou conteúdo equivalente):

- IDs já presentes: `R\d+`, `\d\.\d+` (ex.: `1.1`, `2.3`)
- Linhas/itens que contêm **`#ignorar`** (case-insensitive, em qualquer parte do texto)

### 2. Filtrar itens a publicar

Para cada candidato (`1.M`, `2.M`, `R*`):

| Condição | Ação |
|----------|------|
| Mesmo id já no doc | **SKIP** — reportar `SKIP duplicado: <id>` |
| Item existente com mesmo id contém `#ignorar` | **SKIP** — reportar `SKIP #ignorar: <id>` |
| Novo item | Incluir no markdown de append |

**Regra `#ignorar`:** qualquer bullet/linha existente com `#ignorar` **nunca** é recriada, mesmo que o passo 4/5 o liste de novo.

### 3. Montar markdown de append

Formato **append** (não substituir doc inteiro). Incluir data:

```markdown
## Revisão de código — <YYYY-MM-DD>

### Crítico

#### baladapp/ingressos

- [ ] **1.1** — …

#### baladapp/account

Nenhum.

### Grave

#### baladapp/ingressos

- [ ] **2.1** — …

## Requisitos não implementados — <YYYY-MM-DD>

- [ ] **R2** — …
```

Regras:

- Omitir secção/subsecção vazia (ex.: sem `1.M` em **todos** os repos → sem `### Crítico`).
- **2+ repos:** repetir estrutura `### Crítico` → `#### <repo>` → bullets (ou `Nenhum.`).
- Um bullet `- [ ]` por item.
- Preservar id original no texto (`1.1`, `R2`, …).

Se **nada** passou no filtro §2 → `Ação: nenhum`; não chamar `update_doc`/`create_doc`.

### 4. Criar ou atualizar documento

| Situação | Ação |
|----------|--------|
| Doc existe | `update_doc` → `add_markdown_content` com markdown do §3 |
| Doc ausente | `create_doc` (§5) |

### 5. Criar documento (se ausente)

`create_doc`:

```json
{
  "location": "item",
  "item_id": <subitem_id Revisar código>,
  "column_id": "monday_doc",
  "doc_name": "Revisar código",
  "markdown": "<estrutura § Estrutura do documento + conteúdo §3>"
}
```

Na **primeira criação**, usar a estrutura completa com ambos os tópicos (secções vazias omitidas).

### 6. Atualizar cache Monday

Após sucesso, `ctx_execute` — merge em `tasks-by-title.json`:

- `subitems["Revisar código"].doc_object_id` = objectId retornado
- `cached_at` = ISO 8601 UTC

`ctx_index` com `source: monday-task-info:index`.

## Saída obrigatória (chat)

```markdown
## Requisitos de código

| Campo | Valor |
|-------|-------|
| Subtarefa | Revisar código (`<item_id>`) |
| Doc | <url ou —> |
| Ação | `criado` \| `append` \| `nenhum` |
| Revisão de código | 1.1, 2.1… (ou —) |
| Requisitos não implementados | R2… (ou —) |
| Ignorados (duplicado) | … (ou —) |
| Ignorados (#ignorar) | … (ou —) |
```

**Não** repetir `## Code review` nem `## Verificação de requisitos` integral.

## Erros

| Situação | Ação |
|----------|------|
| Sem `## Code review` | Parar; executar passo 4 |
| Sem `## Verificação de requisitos` | Parar; executar passo 5 |
| Subtarefa Revisar código não encontrada | Parar; listar subtarefas |
| MCP Monday indisponível | Parar; **não** simular doc publicado |
| Nada a publicar após filtros | `Ação: nenhum` |
| `create_doc` / `update_doc` falhou | Reportar erro; não atualizar cache |

## Proibido

- Publicar ou alterar tópico **`## Merge requests`** (responsabilidade do passo 8)
- Alterar **status** de subtarefas
- `create_update` / comentários no item principal
- Publicar blocos **3 - Outros** ou **4 - Lacunas** (salvo pedido explícito)
- Sobrescrever/apagar conteúdo existente (só **append**)
- Recriar item existente marcado com **`#ignorar`**

## Skills relacionadas

| Skill | Papel |
|-------|--------|
| `revisar-tarefa-code-review-diff` | Passo 4 — fonte 1.M / 2.M |
| `revisar-tarefa-verificar-requisitos-usuario` | Passo 5 — fonte R* não implementados |
| `revisar-tarefa-avaliar-tarefa` | Passo 7 — verifica cumprimento no diff e marca checkboxes deste doc |
| `revisar-tarefa-pos-avaliacao` | Passo 8 — MRs + tópico Merge requests + status/owners |
| `monday-task-info` | Cache IDs subtarefa/doc |
| `revisar-tarefa-gerar-requisitos-de-usuario` | Passo 2 — requisitos de usuário |
