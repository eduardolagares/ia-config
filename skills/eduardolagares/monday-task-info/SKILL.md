---
name: monday-task-info
description: >-
  Passo 1 revisar-tarefa: lê tarefa Monday só via MCP da IDE.
  Use com /monday-task-info.
disable-model-invocation: true
VERSION: "2.1.0"
---

# monday-task-info

Skill do **passo 1** de `/revisar-tarefa`. **Somente leitura** no Monday.

## Conexão Monday da IDE (único canal)

O Monday está ligado em **Cursor → Settings → MCP → Monday**. Toda leitura usa **`CallMcpTool`** no servidor Monday MCP **desta** IDE.

Receitas completas (workspaces, boards, docs, colunas): [reference-mcp-monday.md](reference-mcp-monday.md).

| Parâmetro | Valor |
|-----------|--------|
| **`server`** | id do Monday MCP da sessão (`GetMcpTools` / `mcps/*monday*` — ex. `user-monday-mcp`) |
| **`toolName`** | `get_board_items_page`, `read_docs`, … |
| **`arguments`** | JSON das receitas — **não** rediscobrir schema se já estiver na reference |

### Ordem mínima (passo 1)

1. `get_board_items_page` — board `4571892384`, título exato, `includeColumns` + `includeSubItems`
2. `read_docs` — `mode: content`, `type: object_ids`, `ids: [<doc_object_id>]`

```json
{
  "server": "<monday-mcp-da-ide>",
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

Extras úteis (fora do caminho crítico): `list_workspaces`, `search` (`BOARD` + `searchTerm`), `get_board_info`.

**Proibido:** `MONDAY_API_TOKEN`, GraphQL/REST contra `api.monday.com`, curl/`fetch` com token, scripts de API. Se o MCP falhar → **parar** e pedir **Settings → MCP → Monday** (ou `mcp_auth`). **Não** inventar dados.

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

0. Confirmar Monday MCP `ready` (`GetMcpTools`; `mcp_auth` se `needsAuth`).
1. **`CallMcpTool`** — `get_board_items_page` + `read_docs`.
2. Entregar markdown no chat (§ Saída). IDs ficam no contexto da conversa para os passos 2–8.

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

## Normalização de projetos alterados

Ao montar **`## Projetos alterados`**, aplicar as normalizações abaixo:

- `ingressos-repo` (citado no texto/doc/updates) representa o projeto **ingressos** (submodule) e deve entrar como `baladapp/ingressos`.

## Setup (utilizador)

**Monday** conectado em **Cursor → Settings → MCP → Monday**. Sem scripts nesta skill. Sem API/token fora do MCP.

## Erros

| Situação | Ação |
|----------|------|
| MCP Monday indisponível / auth falhou | Parar; Settings → MCP → Monday |
| Tentação de API/token/script | Recusar — só MCP da IDE |
| Título ambíguo | Não escolher item aleatório |

## Skills relacionadas

| Skill | Papel |
|-------|--------|
| `revisar-tarefa` | Passos 2–8 |
| `revisar-tarefa-gerar-requisitos-de-usuario` | Passo 2 — **Documento** |
