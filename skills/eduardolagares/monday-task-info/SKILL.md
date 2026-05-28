---
name: monday-task-info
description: >-
  Passo 1 revisar-tarefa: lê tarefa Monday só via MCP Cursor (plugin-monday.com-monday).
  Grava cache com write-task-cache.sh. Use com /monday-task-info.
disable-model-invocation: true
VERSION: "1.3.1"
---

# monday-task-info

Skill do **passo 1** de `/revisar-tarefa`. **Somente leitura** no Monday.

## Conexão Monday do Cursor (único canal)

O Monday está ligado em **Cursor → Settings → MCP → Monday**. Toda leitura usa **`CallMcpTool`**:

| Parâmetro | Valor |
|-----------|--------|
| **`server`** | `plugin-monday.com-monday` |
| **`toolName`** | ex.: `get_board_items_page`, `read_docs` |
| **`arguments`** | conforme schema em `mcps/plugin-monday.com-monday/tools/*.json` |

Exemplo:

```json
{
  "server": "plugin-monday.com-monday",
  "toolName": "get_board_items_page",
  "arguments": {
    "boardId": 4571892384,
    "searchTerm": "<título exato>",
    "includeColumns": true,
    "includeSubItems": true,
    "limit": 25
  }
}
```

Fluxo completo: [reference-mcp-monday.md](reference-mcp-monday.md).

**Não existe** neste repositório script, token (`MONDAY_API_TOKEN`) nem `curl` para Monday. Se o MCP falhar → **parar** e pedir para rever **Settings → MCP → Monday**. **Não** inventar dados.

## Entrada

```
/monday-task-info <título exato da tarefa>
```

Board **Dia a dia** (`4571892384`). Título **exato**.

| Resultado MCP | Ação |
|---------------|------|
| 0 itens | Erro |
| 2+ itens | Listar `id` + url; pedir qual item |
| 1 item | Prosseguir |

## Ordem de execução

1. **`CallMcpTool`** — `get_board_items_page` + `read_docs`.
2. Markdown no chat (§ Saída).
3. **`scripts/write-task-cache.sh`** — obrigatório para o prefetch do passo 3.

```bash
scripts/write-task-cache.sh "<título exato>" < payload.json
```

## Saída markdown (obrigatória)

```markdown
# <título>

| Campo | Valor |
|-------|-------|
| item_id | `...` |
| url | ... |
| Branch | ... |
| Status consolidado | ... |
| doc_object_id | ... |

## Projetos alterados

| Projeto |
|---------|
| `baladapp/...` |

## Subtarefas

| Nome | item_id | Status | doc_object_id |
|------|---------|--------|---------------|
| Executar | `...` | ... | — |
| Revisar código | `...` | ... | ... |
| Testar | `...` | ... | — |

## Documento

<blocks_as_markdown do read_docs>
```

## Cache (`cache/tasks-by-title.json`)

Ver esquema em [reference-mcp-monday.md](reference-mcp-monday.md) § Cache. Gravar com `write-task-cache.sh` após cada leitura MCP.

## Normalização de projetos alterados

Ao montar **`## Projetos alterados`**, aplicar as normalizações abaixo:

- `ingressos-repo` (citado no texto/doc/updates) representa o projeto **ingressos** (submodule) e deve entrar como `baladapp/ingressos`.

## Setup (utilizador)

**Monday** conectado em **Cursor → Settings → MCP → Monday**. Sem scripts de setup nesta skill.

## Skills relacionadas

| Skill | Papel |
|-------|--------|
| `revisar-tarefa` | Passos 2–8 |
| `revisar-tarefa-gerar-requisitos-de-usuario` | Passo 2 — **Documento** |
