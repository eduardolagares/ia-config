---
name: revisar-tarefa-avaliar-tarefa
description: >-
  Passo 7 de revisar-tarefa: verifica no diff se itens abertos do doc Revisar código foram
  cumpridos, marca checkboxes no Monday, emite veredito e pendências restantes. Status Testar
  via passo 1.
disable-model-invocation: true
VERSION: "2.0.1"
---

# revisar-tarefa — avaliar tarefa (passo 7)

Sub-skill **`avaliar-tarefa`** do passo 7. **Leitura** do doc + diff; **escrita** no Monday **somente** para marcar itens **cumpridos** (`checked: true`) no documento da subtarefa **Revisar código**. **Não** alterar status de subtarefas (passo 8).

Determina o **veredito** que o passo 8 (`pos-avaliacao`) executará no Monday.

**Monday:** `CallMcpTool`, `server`: `plugin-monday.com-monday`. Ler schema em `mcps/plugin-monday.com-monday/tools/<tool>.json` antes de cada tool.

## Pré-requisito

| Dado | Obrigatório |
|------|-------------|
| **Passo 1** | Sim — subtarefas (Executar, Revisar código, **Testar**) + status |
| **Passo 3** | Sim — secção **`## Diff`** com **`Status: ok`** para handoff ao passo 8 (evidência de correção) |
| **Passo 6** | Sim — doc **Revisar código** publicado ou `Ação: nenhum` |
| **Passos 4–5** | Recomendado — fallback se doc ausente |

## Entrada

- Saída do **passo 1** (`monday-task-info`) — status da subtarefa **Testar**; `doc_object_id` da subtarefa **Revisar código**
- **`## Diff`** (passo 3)
- Doc da subtarefa **Revisar código** (`read_docs` via `doc_object_id` do cache ou passo 6)
- Opcional: **`## Requisitos da tarefa`** (passo 2) — contexto para bullets `R*` no doc
- Fallback: `## Code review` (passo 4) + `## Verificação de requisitos` (passo 5)

## Fase A — Ler documento (com blocos)

`read_docs`:

```json
{
  "mode": "content",
  "type": "object_ids",
  "ids": ["<doc_object_id>"],
  "include_blocks": true
}
```

Paginar com `blocks_page` / `blocks_limit` se `has_more_blocks` ou equivalente na resposta.

Extrair:

| Dado | Uso |
|------|-----|
| `blocks_as_markdown` / markdown integral | Secções e texto dos itens |
| `blocks[]` com `id`, `type`, `content`, `checked` | `update_block` nos checkboxes |
| IDs em aberto | `\*\*(\d\.\d+|R\d+)\*\*` em bullets `- [ ]` nas secções alvo |
| `#ignorar` | Excluir da verificação e da escrita |

**Secções alvo** (heading `##`):

- **`## Revisão de código`** (inclui subsecções datadas `## Revisão de código — YYYY-MM-DD`)
- **`## Requisitos não implementados`** (idem com data no título)

Fora dessas secções → **não** verificar nem marcar.

## Fase B — Verificar cumprimento (diff)

Para cada item **aberto** (`- [ ]` ou bloco `list_item` com `checked: false`) nas secções alvo:

| Tipo | ID | Critério **cumprido** |
|------|-----|----------------------|
| Code review | `1.M` / `2.M` | Diff (passo 3) mostra alteração no path de **Onde:** (ou repo do `####`) que implementa **Correção:** descrita no bullet; evidência clara — não especulativa |
| Requisito | `R*` | Mesma lógica do passo 5 ([verificar-requisitos-usuario](../verificar-requisitos-usuario/SKILL.md)): diff com mudança substantiva que atende o texto do bullet; modo `monday` sem artefato de código → **não cumprido** (não marcar) |

| Resultado | Ação na Fase C |
|-----------|----------------|
| **cumprido** | Marcar checkbox no Monday |
| **não cumprido** | Manter aberto |
| **incerto** / evidência fraca | Manter aberto (mesmo critério conservador do passo 5) |

**Regras:**

- **Não** inventar evidência fora do diff.
- **Não** desmarcar (`checked: false`) itens já concluídos no doc.
- **Não** alterar texto do bullet — só estado `checked`.
- Linha com **`#ignorar`** → ignorar (não verificar, não marcar).

Diff só com **Erro:** por repo → tratar itens daquele repo como **incerto**; não marcar cumpridos sem hunks.

## Fase C — Marcar cumpridos no Monday

Somente para itens classificados **cumprido** na Fase B.

1. Localizar o bloco `list_item` (`CHECK_LIST`) cujo conteúdo contém o id (`**1.1**`, `**R2**`, …) e `checked` é `false`.
2. `update_doc` com uma operação `update_block` por item (máx. **25** operações por chamada — agrupar em várias chamadas se necessário):

```json
{
  "object_id": "<doc_object_id>",
  "operations": [
    {
      "operation_type": "update_block",
      "block_id": "<block_id>",
      "content": {
        "block_content_type": "list_item",
        "checked": true,
        "delta_format": "<copiar delta_format atual do bloco; última op {insert: {text: \"\\n\"}}>"
      }
    }
  ]
}
```

| Situação | Ação |
|----------|------|
| Nenhum item **cumprido** | Não chamar `update_doc` |
| `update_doc` falhou | Reportar ids afetados; pendências = estado **antes** da escrita falhada |
| Sucesso parcial | Reportar ids marcados e ids que falharam |

**Proibido nesta fase:** `add_markdown_content`, `create_doc`, apagar blocos, editar **Merge requests**, alterar status de subtarefas.

## Fase D — Veredito (pendências restantes)

Reavaliar pendências **após** Fase C (reler doc com `read_docs` se houve marcações; senão usar estado calculado).

### Regra 1 — Pendências bloqueiam avanço

A tarefa **não pode avançar** se existir **qualquer** item ainda aberto em:

| Fonte | O que conta |
|-------|-------------|
| Doc **Revisar código** | Checkbox `- [ ]` nos tópicos **`## Revisão de código`** ou **`## Requisitos não implementados`** |
| Exclusão | Linhas com **`#ignorar`** — **não** contam |
| Fallback (sem doc) | Itens `1.M`/`2.M` nos blocos **1–2** do code review **≠** `Nenhum.` **ou** ids em **Requisitos não implementados** **≠** `Nenhum.` |

Se **há pendências** → veredito **`precisa_de_correcao`**.

### Regra 2 — Sem pendências: olhar subtarefa Testar

Só aplicar se **não** há pendências (Regra 1).

| Status Testar | Veredito |
|---------------|----------|
| **Concluída** (ou `concluído` / `Done`) | `pode_avancar_para_deploy` |
| Qualquer outro | `deve_ser_testada` |

### Vereditos (enum fixo)

| Veredito | Significado |
|----------|-------------|
| `precisa_de_correcao` | Ainda há itens abertos de revisão ou requisitos |
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
| Itens marcados cumpridos | <ids ou —> |
| Pendências revisão | <ids ou contagem> (ou —) |
| Pendências requisitos | <ids ou contagem> (ou —) |
| Status Testar | <label do passo 1> |
| Doc atualizado | `sim` \| `não` \| `parcial` |

### Motivo

<1–3 frases em pt-BR — incluir quantos itens foram marcados cumpridos no Monday, se houver>
```

### Regras da saída

- **`Pode avançar?`** = `não` só quando veredito = `precisa_de_correcao`.
- **`Doc atualizado`** = `sim` se Fase C concluiu sem falha; `parcial` se algum `update_block` falhou; `não` se nada a marcar.
- **Não** repetir doc integral nem code review.

## Handoff para passo 8

Só executar [pos-avaliacao](../pos-avaliacao/SKILL.md) se **`## Diff` · `Status: ok`**. Caso contrário, incluir em **`## Avaliação`** a linha **`Pós-avaliação: bloqueada (diff GitLab indisponível)`** e entregar § Bloqueio do passo 8 — **sem** aplicar veredito no Monday.

| Veredito | Passo 8 (se `Status: ok`) |
|----------|---------------------------|
| `precisa_de_correcao` | § Correção |
| `deve_ser_testada` | § Testar |
| `pode_avancar_para_deploy` | § Deploy |

## Erros

| Situação | Ação |
|----------|------|
| Sem passo 1 | Parar |
| Sem passo 3 (`## Diff`) | Parar |
| `## Diff` com `Status` ≠ `ok` | Emitir veredito **sugerido** se possível; passo 8 **bloqueado** |
| Sem passo 6 e sem passos 4–5 | Parar |
| Subtarefa Testar não encontrada | Parar; listar subtarefas |
| Doc ilegível | Fallback passos 4–5; avisar |
| MCP Monday indisponível | Parar; **não** simular veredito nem checkboxes marcados |
| `read_docs` sem blocos | Repetir com `include_blocks: true` antes de `update_doc` |

## Skills relacionadas

| Skill | Papel |
|-------|--------|
| `revisar-tarefa-executar-diff` | Passo 3 — evidência de cumprimento |
| `revisar-tarefa-gerar-requisitos-de-codigo` | Passo 6 — doc fonte de pendências |
| `revisar-tarefa-verificar-requisitos-usuario` | Passo 5 — critério para `R*` |
| `revisar-tarefa-pos-avaliacao` | Passo 8 — executa veredito (status/owners) |
| `monday-task-info` | Passo 1 — status Testar + `doc_object_id` |
