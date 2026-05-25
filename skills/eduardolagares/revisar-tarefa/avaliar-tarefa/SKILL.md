---
name: revisar-tarefa-avaliar-tarefa
description: >-
  Passo 7 de revisar-tarefa: emite veredito se a tarefa pode avançar com base em
  pendências no doc Revisar código e status da subtarefa Testar. Somente leitura.
disable-model-invocation: true
VERSION: "1.0.0"
---

# revisar-tarefa — avaliar tarefa (passo 7)

Sub-skill **`avaliar-tarefa`** do passo 7. **Somente leitura** — não altera Monday.

Determina o **veredito** que o passo 8 (`pos-avaliacao`) executará no Monday.

## Pré-requisito

| Dado | Obrigatório |
|------|-------------|
| **Passo 1** | Sim — subtarefas (Executar, Revisar código, **Testar**) + status |
| **Passo 6** | Sim — doc **Revisar código** publicado ou `Ação: nenhum` |
| **Passos 4–5** | Recomendado — fallback se doc ausente |

## Entrada

- Saída do **passo 1** (`monday-task-info`) — status da subtarefa **Testar**
- Doc da subtarefa **Revisar código** (`read_docs` via `doc_object_id` do cache ou passo 6)
- Fallback: `## Code review` (passo 4) + `## Verificação de requisitos` (passo 5)

## Regra 1 — Pendências bloqueiam avanço

A tarefa **não pode avançar** se existir **qualquer** item pendente em:

| Fonte | O que conta |
|-------|-------------|
| Doc **Revisar código** | Checkbox `- [ ]` nos tópicos **`## Revisão de código`** ou **`## Requisitos não implementados`** |
| Exclusão | Linhas com **`#ignorar`** (case-insensitive) — **não** contam como pendência |
| Fallback (sem doc) | Itens `1.M`/`2.M` nos blocos **1–2** do code review **≠** `Nenhum.` **ou** ids em **Requisitos não implementados** **≠** `Nenhum.` |

**Implementação:** preferir `read_docs` do doc Revisar código (conteúdo integral após passo 6). Percorrer markdown e contar `- [ ]` nas secções relevantes, ignorando linhas com `#ignorar`.

Se **há pendências** → veredito fixo:

```
precisa_de_correcao
```

(Motivo: a tarefa precisa de correção antes de avançar.)

## Regra 2 — Sem pendências: olhar subtarefa Testar

Só aplicar se **não** há pendências (Regra 1).

Ler status da subtarefa **Testar** no passo 1 (nome exato `Testar`; tolerar variação mínima de capitalização).

| Status Testar | Veredito |
|---------------|----------|
| **Concluída** (ou equivalente `concluído` / `Done` no label Monday) | `pode_avancar_para_deploy` |
| Qualquer outro | `deve_ser_testada` |

### Vereditos (enum fixo)

| Veredito | Significado |
|----------|-------------|
| `precisa_de_correcao` | Há itens abertos de revisão de código ou requisitos não implementados |
| `deve_ser_testada` | Revisão limpa; Testar ainda não concluída |
| `pode_avancar_para_deploy` | Revisão limpa; Testar já concluída |

## Saída obrigatória

Entregar **somente** este bloco:

```markdown
## Avaliação

| Campo | Valor |
|-------|-------|
| Pode avançar? | `sim` \| `não` |
| Veredito | `precisa_de_correcao` \| `deve_ser_testada` \| `pode_avancar_para_deploy` |
| Pendências revisão | <ids ou contagem> (ou —) |
| Pendências requisitos | <ids ou contagem> (ou —) |
| Status Testar | <label do passo 1> |

### Motivo

<1–3 frases em pt-BR>
```

### Regras

- **`Pode avançar?`** = `não` só quando veredito = `precisa_de_correcao`.
- **Não** alterar Monday neste passo.
- **Não** repetir doc integral nem code review.

## Handoff para passo 8

| Veredito | Passo 8 |
|----------|---------|
| `precisa_de_correcao` | [pos-avaliacao](../pos-avaliacao/SKILL.md) § Correção |
| `deve_ser_testada` | § Testar |
| `pode_avancar_para_deploy` | § Deploy |

## Erros

| Situação | Ação |
|----------|------|
| Sem passo 1 | Parar |
| Sem passo 6 e sem passos 4–5 | Parar |
| Subtarefa Testar não encontrada | Parar; listar subtarefas |
| Doc ilegível | Fallback passos 4–5; avisar |

## Skills relacionadas

| Skill | Papel |
|-------|--------|
| `revisar-tarefa-gerar-requisitos-de-codigo` | Passo 6 — doc fonte de pendências |
| `revisar-tarefa-pos-avaliacao` | Passo 8 — executa veredito |
| `monday-task-info` | Passo 1 — status Testar |
