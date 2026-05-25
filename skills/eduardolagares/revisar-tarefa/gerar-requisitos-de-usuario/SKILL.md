---
name: revisar-tarefa-gerar-requisitos-de-usuario
description: >-
  Gera requisitos de usuário (spec) a partir do documento principal da tarefa no Monday.
  Passo 2 de revisar-tarefa.
disable-model-invocation: true
VERSION: "2.1.0"
---

# revisar-tarefa — gerar requisitos de usuário (passo 2)

Sub-skill **`gerar-requisitos-de-usuario`** do passo 2. **Somente leitura** — não altera Monday.

**Escopo:** requisitos **apenas** do **documento principal** da tarefa (secção **Documento** do passo 1). **Não** extrair de subtarefas, updates, metadados da tabela nem code review.

Fluxo completo: passo 3 [executar-diff](../executar-diff/SKILL.md) → … → passo 7 [avaliar-tarefa](../avaliar-tarefa/SKILL.md) → passo 8 [pos-avaliacao](../pos-avaliacao/SKILL.md).

## Pré-requisito

Saída completa de `monday-task-info` (mesmo título exato) no contexto, **com conteúdo** em **Documento** (`blocks_as_markdown`).

Sem documento principal ou conteúdo vazio → parar; não inventar requisitos.

## Entrada

- Secção **Documento** do passo 1 (`blocks_as_markdown` integral)
- Título (`# <titulo>`) — só para contexto; **Fonte** de cada item = `documento`

## Saída obrigatória

Entregar **somente** este bloco:

```markdown
## Requisitos da tarefa

Itens que devem ser verificados:

1. **R1** — <o que verificar>. Fonte: documento. Verificação: <modo>. Status: pendente.
2. **R2** — …

### Resumo

- **Total:** N itens
- **Pendentes:** R1, R2 (ou —)
- **Concluídos (ignorar revisão):** — (ou R8…)
- **Bloqueantes pendentes:** —
- **Projetos sugeridos:** … (campo da tabela passo 1, se existir; não vira item R*)
```

## Regras da lista

| Regra | Detalhe |
|-------|---------|
| Cabeçalho | **`## Requisitos da tarefa`** — texto exato |
| Intro | Frase fixa: `Itens que devem ser verificados:` |
| ID | Só **`R1`**, **`R2`**, … — **sem `RB*`** neste passo |
| **Fonte** | Sempre **`documento`** (documento principal da tarefa) |
| **Verificação** | **Obrigatório** — um modo por item |
| **Status** | Default **`pendente`**; `concluído` só com marcador ignorar-revisão **no documento principal** |
| Formato | Lista numerada; **sem** tabela de requisitos |
| Passo 1 | **Não** repetir markdown do Monday |

### Modos de Verificação (obrigatório)

| Modo | Quando usar |
|------|-------------|
| `diff` | Código, migração, template, mailer, partial, DTO, estrutura |
| `teste` | Comportamento validável em QA/automação citado na spec |
| `monday` | Processo/status citado na spec |
| `manual` | Visual, copy, layout, screenshot de referência na spec |

**Não** omitir `Verificação:` nem fundir modos.

## Ignorar revisão (só no documento principal)

Marcador no **texto do documento principal** (case-insensitive):

`#ignorar-revisao`, `#ignorar-revisão`, `ignorar revisão`, `ignorar revisao`, `[ignorar-revisão]`, `[ignorar-revisao]`

→ `Status: concluído` + sufixo `*(ignorar revisão — não reabrir)*`. **Não** ler marcadores de subtarefas ou doc **Revisar código**.

## Como extrair itens

**Única fonte:** secção **Documento** do passo 1.

| Padrão no documento | Itens |
|---------------------|--------|
| **Comportamento atual** | baseline (se relevante para verificação) |
| **Novo comportamento** / **O que deve ser feito** | ≥1 item por bullet substantivo |
| DTO / parâmetros / regras técnicas | item por grupo |
| “Substituir X por Y” | migração → `Verificação: diff` |
| Layout / visual com screenshot | `Verificação: manual` ou `diff` se implica código |

### Proibido neste passo

- Subtarefas (Executar, Revisar código, Testar, Deploy)
- Updates (`impacto:`, `branch:`)
- Tabela passo 1 (branch, status) como item R*
- Code review (passo 4)
- Documento da subtarefa **Revisar código**

## IDs e redação

- Sequência `R1`, `R2`, … apenas
- Frase: resultado verificável ligado ao texto da spec

## Erros

| Situação | Ação |
|----------|------|
| Sem saída monday-task-info | Parar |
| Documento `—` ou vazio | Parar; `spec_incompleta` — não inventar R* |
| Spec ambígua | Item + `Verificação: manual`; manter `Fonte: documento` |

Schema opcional: [reference.md](reference.md).

## Skills relacionadas

| Skill | Papel |
|-------|--------|
| `monday-task-info` | Passo 1 — fornece documento principal |
| `revisar-tarefa-code-review-diff` | Passo 4 |
| `revisar-tarefa-verificar-requisitos-usuario` | Passo 5 — cruza R* com diff |
| `revisar-tarefa-gerar-requisitos-de-codigo` | Passo 6 — publica no doc Revisar código |
| `revisar-tarefa-avaliar-tarefa` | Passo 7 |
| `revisar-tarefa-pos-avaliacao` | Passo 8 |
