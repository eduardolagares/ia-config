---
name: criar-tarefa-no-monday
description: >-
  Cria tarefa no Monday.com a partir de documento funcional pronto (item,
  documento, subtarefas, branch, colunas) via MCP Monday. Entrevista só
  parâmetros do Monday — não redige o documento. Converte qualquer gráfico
  Mermaid em PNG antes de adicionar ao documento. Use com
  /criar-tarefa-no-monday.
disable-model-invocation: true
VERSION: "1.1.3"
---

# criar-tarefa-no-monday

Publica no Monday uma tarefa já especificada: item no quadro, documento na coluna **Documento**, subtarefas, branch e metadados.

## Entrada: documento pronto

O **conteúdo funcional** (UCs, telas, RFs) vem **pronto** — ficheiro (`docs/tarefas/…`), texto colado ou output de `/escrever-tarefa`. **Esta skill não entrevista** para redigir o documento.

| Responsabilidade | Skill |
|------------------|--------|
| Redigir documento funcional | `escrever-tarefa` |
| Parâmetros Monday + publicar | `criar-tarefa-no-monday` |

Sem documento na invocação → pedir path, texto ou encaminhar para `/escrever-tarefa`. **Não** inventar UCs/RFs nem fazer grill do conteúdo.

**Regra central:** entrevistar **só** os parâmetros Monday antes de criar. Não reutilizar valores de sessões anteriores (quadro, grupo, branch, subtarefas, responsável, tipo, etc.).

**Mermaid:** o Monday **não** renderiza Mermaid. **Qualquer** gráfico Mermaid do documento (flowchart, sequenceDiagram, etc.) deve ser **convertido em imagem PNG antes** de ser adicionado ao documento — nunca colar blocos ` ```mermaid ` no `create_doc` nem no markdown enviado ao Monday.

## Monday — conexão

1. `GetMcpTools` para descobrir o servidor Monday disponível (`plugin-monday-crm-monday` ou equivalente).
2. Se `serverStatus` ≠ `ready` → parar e pedir autenticação MCP.
3. `get_user_context` — identificar o utilizador atual (`id`, `name`) para atribuição.

Antes de `create_item` / `change_item_column_values`, chamar `get_board_info` no quadro escolhido para obter `groupId`, `column` ids e labels de status.

## Entrevista — só parâmetros Monday

**Todas as perguntas de uma vez** na primeira mensagem da entrevista. O utilizador pode responder **várias de uma vez** (ou todas).

**Fora do âmbito desta entrevista:** escopo funcional, UCs, telas, RFs, regras de negócio — já vêm no documento pronto.

Checklist — confirmar **todos** (exceto prioridade, opcional) antes de criar:

| # | Campo | Exemplo de pergunta |
|---|--------|---------------------|
| 1 | Título do item | Nome da tarefa no Monday (pode derivar do `# Título` do documento — confirmar) |
| 2 | Quadro | Ex.: Dia a dia |
| 3 | Grupo | Ex.: Revisão de código |
| 4 | Responsável(is) | Owner de **Executar** e **Corrigir** (as demais subtarefas têm owner fixo — ver § Atribuição) |
| 5 | Branch | Valor da coluna **Branch** (`texto`) |
| 6 | Tipo | Coluna **Tipo** (`label`) — ex.: FUNCIONALIDADE |
| 7 | Solicitante | Coluna **Solicitante** (`label6`) — ex.: SÓCIO TORCEDOR |
| 8 | Status consolidado | Coluna **Status consolidado** (`status_1`) — ex.: Aguardando revisão de código |
| 9 | Prioridade | Coluna **Priority** (`priority__1`) — opcional |
| 10 | Subtarefas | Nomes + status inicial; owners conforme § Atribuição (só perguntar se o utilizador quiser override) |

### Como conduzir

1. **Primeira mensagem:** listar **todos** os campos (1–10) com pergunta + recomendação quando o contexto sugerir (ex.: título a partir do documento). Não omitir campos “para perguntar depois”.
2. **Após cada resposta do utilizador:** atualizar o estado e mostrar de novo:
   - **Respondidos** — campo + valor confirmado
   - **Em aberto** — campos ainda sem resposta (com a pergunta / recomendação)
3. Aceitar respostas parciais: o utilizador pode preencher um, vários ou todos os campos abertos na mesma mensagem.
4. Repetir o passo 2 até não restar obrigatório em aberto. Prioridade (#9) pode ficar vazia se o utilizador disser que não quer.
5. **Confirmação final** (só quando o checklist obrigatório estiver completo): resumo dos parâmetros Monday + “posso criar?”. Não criar sem esta confirmação explícita.

Formato sugerido a cada turno (após a 1.ª listagem ou após cada resposta):

```markdown
### Parâmetros Monday

**Respondidos:**
- Título: …
- Quadro: …
…

**Em aberto:**
- 5. Branch — valor da coluna Branch? (ex.: `feat/…`)
- 6. Tipo — …?
…
```

**Subtarefas:** se o utilizador não especificar, manter em aberto e **perguntar** a lista completa — não assumir `Executar`, `Revisar código automaticamente`, `Revisar código manualmente`, `Testar`, `Corrigir`, `Fazer deploy` sem confirmação. Owners das subtarefas padrão: ver § Atribuição (aplicar automaticamente salvo override explícito).

**Título:** pode sugerir a partir do documento; o utilizador confirma ou corrige.

## Referência — quadro Dia a dia (só após confirmação do utilizador)

Valores usados no time; **só aplicar se o utilizador confirmar** este quadro:

| Campo | ID / coluna |
|-------|-------------|
| Board | Dia a dia — `4571892384` |
| Grupo Revisão de código | `group_mkxmth4x` |
| Branch | `texto` |
| Documento | `monday_doc` |
| Status consolidado | `status_1` |
| Tipo | `label` |
| Solicitante | `label6` |
| Subtarefas | coluna `subelementos` → board `4571892432` |
| Owner subtarefa | coluna `person` no subitem |
| Status subtarefa | coluna `status` — label `A fazer` |

## Diagramas Mermaid no documento (obrigatório)

**Qualquer** gráfico Mermaid — UC, fluxo, sequência, estado, etc. — deve ser **renderizado como PNG antes** de entrar no documento Monday. O Monday só exibe imagem; código Mermaid aparece como bloco de código sem renderização.

**Proibido:** adicionar ao documento blocos ` ```mermaid `, texto Mermaid cru ou diagramas não convertidos.

### Renderizar

Para cada diagrama:

```bash
curl -sS -X POST "https://kroki.io/mermaid/png" \
  -H "Content-Type: text/plain" \
  --data-binary @diagrama.mmd \
  -o diagrama.png
```

Alternativa para `public_url` no Monday: URL Kroki comprimida (base64url + deflate) — ver [reference-mermaid-monday.md](reference-mermaid-monday.md).

### Inserir no documento

1. **Não** enviar blocos ` ```mermaid ` no `create_doc` / `add_markdown_content`.
2. Criar documento só com texto (títulos, prosa, RFs).
3. `read_docs` com `include_blocks: true` — localizar o bloco de texto **antes** de cada diagrama (ex.: prosa do UC).
4. `update_doc` → `create_block` com `block_type: "image"`, `public_url` (Kroki) ou `asset_id`, `after_block_id` = id do bloco de texto do UC.
5. **Não** usar só `replace_block` no bloco mermaid antigo — reposiciona imagens no fim do doc. Preferir `create_block` com `after_block_id`.
6. Verificar posição: imagem imediatamente após a prosa de cada UC, antes do próximo título.

## Fluxo de criação

```
1. Obter documento pronto (ler ficheiro ou aceitar texto na invocação)
2. Entrevista — só parâmetros Monday (checklist acima)
3. get_board_info(boardId confirmado)
4. create_item — name, groupId, columnValues (status, tipo, solicitante)
5. Converter **todos** os gráficos Mermaid do documento em PNG **antes** de publicar
6. create_doc — location: item, item_id, column_id: monday_doc, markdown **sem** nenhum bloco mermaid
7. update_doc → create_block (imagem) com `after_block_id` após cada bloco de texto que tinha diagrama
8. create_items — subtarefas com parentItemId, person + status por subtarefa
9. change_item_column_values — branch em texto (e outros campos se faltarem)
10. Responder com URLs do item, documento e subtarefas
```

### columnValues — formato

Status/dropdown: `{"label": "Aguardando revisão de código"}`  
Texto (branch): string direta em `texto`  
People (subtarefa): `{"personsAndTeams": [{"id": <user_id>, "kind": "person"}]}`

### Atribuição

- Item principal do Dia a dia **não** tem coluna Person direta; responsável reflete nas subtarefas (`person`).
- Resolver `user_id` via `list_users_and_teams` / `get_user_context` pelo nome — **nunca** inventar IDs.
- Com a lista padrão de subtarefas, aplicar **automaticamente** (salvo override explícito do utilizador):

| Subtarefa | Owner (`person`) |
|-----------|------------------|
| `Revisar código automaticamente` | Eduardo Lagares |
| `Revisar código manualmente` | Eduardo Lagares |
| `Fazer deploy` | Eduardo Lagares |
| `Testar` | João Sanches |
| `Executar` | perguntar (#4) |
| `Corrigir` | perguntar (#4) |

- Na entrevista / confirmação final, **mostrar** estes owners no resumo; só mudar se o utilizador pedir.

## Saída no chat (obrigatória)

```markdown
## Tarefa criada

**Item:** [título](url)
- Quadro / Grupo / Status / Tipo / Solicitante / Branch

**Documento:** [nome](doc_url)
- Diagramas: N imagens (se aplicável)

**Subtarefas:**
1. Nome — responsável — status — url
...
```

## Erros comuns

| Problema | Ação |
|----------|------|
| Imagens no fim do doc | `delete_block` + `create_block` com `after_block_id` correto |
| Mermaid como código no Monday | Remover; substituir por imagem |
| Label de status inexistente | `get_board_info` → labels exatos; ou `createLabelsIfMissing: true` |
| MCP Monday indisponível | Parar; não inventar IDs |

## Skills relacionadas

| Skill | Quando |
|-------|--------|
| `escrever-tarefa` | **Antes** — quando ainda não há documento funcional pronto |
| `monday-task-info` | Ler tarefa existente (somente leitura) |

**Ordem típica:** `/escrever-tarefa` → documento pronto → `/criar-tarefa-no-monday` com o ficheiro ou texto.

## Referência adicional

- Kroki + posicionamento de imagens: [reference-mermaid-monday.md](reference-mermaid-monday.md)
