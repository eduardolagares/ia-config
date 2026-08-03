---
name: criar-tarefa-no-monday
description: >-
  Cria tarefa no board Dia a Dia do monday.com no grupo Escrevendo,
  com subtarefas fixas (Executar, Revisar código, Testar, Corrigir, Deploy),
  coluna Ação = Avaliar na principal e status A fazer em todas as subtarefas,
  responsáveis definidos e documento anexado a partir de um .md (Mermaid
  renderizado como imagem). Use com /criar-tarefa-no-monday ou quando escrever-tarefa
  acionar após gravar.
disable-model-invocation: true
VERSION: "1.2.1"
---

# criar-tarefa-no-monday

Cria uma **tarefa no monday.com** (board **Dia a Dia**) a partir de um documento funcional `.md`. Usa o MCP **monday** (`plugin-monday-crm-monday`).

## Pré-requisitos

1. MCP monday conectado — se falhar autenticação, orientar OAuth (`/mcp` → conectar `monday`).
2. **Documentação obrigatória:** caminho de um `.md` legível (parâmetro da invocação ou pergunta única pedindo o path).
3. **Título e Branch — obrigatório pedir ao usuário:**
   - **Título** da tarefa no monday (nome do item).
   - **Branch** Git (valor da coluna Branch).

**Jamais** inventar, inferir ou usar valores sugeridos por conta própria — mesmo que o `.md`, o cenário ou o slug do arquivo sugiram um nome. Pode **recomendar** no chat, mas **só criar** depois que o usuário informar **explicitamente** título e branch (na mesma mensagem ou em resposta à pergunta).

Uma pergunta de cada vez quando faltar dado; incluir recomendação quando o contexto sugerir valor — **sem** substituir a resposta do usuário.

**Bloqueio:** se o usuário disser apenas “pode criar” / “cria no monday” sem título e branch → **perguntar primeiro**; **não** chamar `create_item` até ter os dois valores confirmados pelo usuário.

## Board e colunas (defaults)

| Escopo | Board ID | Observação |
|--------|----------|------------|
| Tarefa principal | `4571892384` | Dia a Dia |
| Subtarefas | `4571892432` | board filho (sub_items) |

Antes de criar, chamar `get_board_info` nos dois boards se colunas ou grupos não estiverem no contexto. Resolver por **título** da coluna ou do grupo:

| Coluna / Grupo | Board | Uso |
|--------|-------|-----|
| **Escrevendo** | principal | grupo — **sempre** criar a tarefa principal aqui (`groupId`) |
| Branch | principal | texto — branch informada pelo usuário |
| **Ação** | principal | status — label **`Avaliar`** (substitui o antigo Status consolidado) |
| Status | subtarefas | status — label **`A fazer`** |
| person | subtarefas | responsáveis (tipo people) |

**Descontinuado no board (não usar):** grupo **Aguardando atribuição**; coluna **Status consolidado**.

Se `~/.config/revisar-tarefa/monday.env` existir, pode complementar IDs — **não** substituir confirmação de título/branch pelo usuário.

## Subtarefas fixas (ordem obrigatória)

Criar **exatamente** estas cinco subtarefas, nesta ordem, sob a tarefa principal:

1. **Executar**
2. **Revisar código**
3. **Testar**
4. **Corrigir**
5. **Deploy**

Cada subtarefa: status **`A fazer`**.

## Responsáveis (coluna person nas subtarefas)

Resolver IDs com `list_users_and_teams`:

| Subtarefa | Responsáveis |
|-----------|--------------|
| Executar | _(nenhum fixo — não atribuir)_ |
| Revisar código | **Eduardo Lagares** |
| Testar | **Adão Teodoro de Morais Neto** **e** **João Sanches** |
| Corrigir | _(nenhum fixo — não atribuir)_ |
| Deploy | **Eduardo Lagares** |

Formato people (Monday):

```json
{"person": {"personsAndTeams": [{"id": "<user_id>", "kind": "person"}]}}
```

Vários responsáveis na mesma subtarefa: incluir todos no array `personsAndTeams`.

## Ação (tarefa principal) e Status (subtarefas)

| Escopo | Coluna | Label |
|--------|--------|-------|
| Tarefa principal | **Ação** | **`Avaliar`** |
| Cada subtarefa | Status | **`A fazer`** |

Definir na criação (`columnValues` em `create_item`) ou em seguida com `change_item_column_values` — **nunca** deixar a principal sem **Ação = Avaliar** nem subtarefa sem **Status = A fazer**.

Exemplo coluna Ação (principal) — usar o `column_id` real resolvido via `get_board_info`:

```json
{"<column_id_acao>": {"label": "Avaliar"}}
```

Exemplo coluna status (subtarefa):

```json
{"status": {"label": "A fazer"}}
```

Usar o `column_id` real de cada board. Se `change_item_column_values` falhar por label inexistente, reportar erro — **não** inventar índice. **Não** escrever em **Status consolidado**.

## Grupo

A **tarefa principal** deve ser criada **sempre** no grupo **`Escrevendo`**.

1. Obter o `groupId` desse grupo via `get_board_info` (board principal `4571892384`), resolvendo pelo título exato.
2. Passar `groupId` em `create_item` ao criar a tarefa principal.
3. Se o grupo não existir ou o `groupId` não for encontrado, reportar erro — **não** criar em outro grupo (inclui **não** usar **Aguardando atribuição**).

## Documento da tarefa

A documentação `.md` vira o **doc monday** no campo **Documento** da **tarefa principal** — e **somente** ali (não colar Mermaid cru).

### Local do documento (obrigatório)

- Criar o documento **exclusivamente** no campo **Documento** da tarefa principal (`location: item`, `item_id` da tarefa principal).
- **Proibido** criar documentos em subtarefas ou em qualquer subelemento.
- **Proibido** criar documentos soltos na área de trabalho (workspace) ou fora do item principal.

### Mermaid → imagem (obrigatório)

Para **cada** bloco ` ```mermaid ` no `.md`:

1. Extrair o código Mermaid.
2. **Gerar imagem PNG** — preferir render local:
   ```bash
   npx -y @mermaid-js/mermaid-cli -i /tmp/diagram-N.mmd -o /tmp/diagram-N.png -b transparent
   ```
3. **Substituir** o bloco no conteúdo do doc por referência visual — **nunca** colar o texto Mermaid no monday.
4. Inserir imagem no doc monday:
   - **Preferência:** upload via `get_asset_upload_url` → PUT do PNG → usar `asset_id` em `update_doc` (`create_block`, `block_type: image`) ou URL pública resultante.
   - **Fallback** se CLI/upload falhar: [mermaid.ink](https://mermaid.ink) — `![UC n — fluxo](https://mermaid.ink/img/<base64url do código mermaid>)` no markdown.

Montar o markdown final na ordem do arquivo original: texto → imagem → texto → imagem…

### Criar doc no item

Após criar a tarefa principal (`item_id` conhecido), preencher **apenas** o campo **Documento** dessa tarefa:

```text
create_doc — location: item, item_id: <id da tarefa principal>, doc_name: <Título>, markdown: <conteúdo processado>
```

Se houver imagens via `asset_id`, alternar `add_markdown_content` (texto) e `create_block` (imagem) com `update_doc` — **sempre** no doc da tarefa principal.

## Fluxo de execução

```
1. Ler .md (parâmetro)
2. Perguntar Título e Branch (se faltarem) — aguardar resposta; nunca preencher por conta própria
3. get_board_info — boards principal e subtarefas; resolver grupo **Escrevendo**, coluna **Ação** e Status das subtarefas
4. list_users_and_teams — Eduardo Lagares, João Sanches, Adão Teodoro de Morais Neto
5. Processar .md — Mermaid → PNG/imagem
6. create_item — tarefa principal (board 4571892384)
   - groupId = **Escrevendo** (obrigatório)
   - name = Título
   - columnValues: Branch + Ação = **Avaliar**
7. Para cada subtarefa (parentItemId = item principal):
   - create_item — name = nome fixo da subtarefa; columnValues: Status = **A fazer**
   - change_item_column_values — Status = **A fazer** (se não definido na criação)
   - change_item_column_values — person (quando aplicável)
8. create_doc / update_doc — documento no campo Documento da tarefa principal (nunca em subtarefas nem solto no workspace)
9. Responder no chat com URL da tarefa e resumo
```

## MCP — ferramentas

Ler schema em `mcps/plugin-monday-crm-monday/tools/` antes de chamar.

| Etapa | Ferramenta |
|-------|------------|
| Board/colunas | `get_board_info` |
| Usuários | `list_users_and_teams` |
| Item / subtarefa | `create_item` |
| Colunas | `change_item_column_values` |
| Doc | `create_doc`, `update_doc` |
| Imagem | `get_asset_upload_url`, `finalize_asset_upload` |

Servidor MCP: **`plugin-monday-crm-monday`**.

## Saída no chat

Após sucesso:

```markdown
## Tarefa monday criada

| Campo | Valor |
|-------|-------|
| Título | … |
| Grupo | Escrevendo |
| Branch | … |
| Ação | Avaliar (principal) |
| Status subtarefas | A fazer |
| URL | … |
| Doc | … (se disponível) |

### Subtarefas

| Nome | Status | Responsáveis |
|------|--------|--------------|
| Executar | A fazer | — |
| … | … | … |
```

Se alguma etapa falhar após criar o item, reportar o que foi criado e o que falhou — **não** simular sucesso.

## Invocação

```
/criar-tarefa-no-monday docs/tarefas/2026-06-16-173000-exemplo.md
/criar-tarefa-no-monday @docs/tarefas/arquivo.md
```

Sem `.md` na invocação: pedir o path (uma mensagem) antes de perguntar título/branch.

## Integração com escrever-tarefa

Quando acionada por **escrever-tarefa**, usar o `.md` recém-gravado como documentação. Ainda assim **perguntar Título e Branch** e **aguardar** resposta explícita do usuário — **jamais** derivar do slug do arquivo, do cenário ou de recomendação no chat.

## Escopo e limites

- Executar **somente** o que estiver **explicitamente** descrito nesta skill.
- **Não** improvisar passos, ferramentas, colunas, boards ou locais de documento além do previsto aqui.
- Se surgir necessidade de alguma ação **não descrita** nesta skill, **perguntar ao usuário** o que fazer **antes** de executar — não assumir nem contornar por conta própria.

## Proibido

- Criar a tarefa principal fora do grupo **Escrevendo** (inclui **Aguardando atribuição**).
- Usar a coluna **Status consolidado** (descontinuada) ou deixar a principal sem **Ação = Avaliar**.
- Deixar qualquer subtarefa sem status **A fazer**.
- Criar subtarefas com nomes ou ordem diferentes das cinco fixas.
- Colar blocos ` ```mermaid ` no doc monday.
- Criar documentos em subtarefas, subelementos ou soltos na área de trabalho — o doc fica **apenas** no campo **Documento** da tarefa principal.
- Atribuir Revisar código ou Deploy a outra pessoa que não Eduardo Lagares.
- Omitir João Sanches ou Adão Teodoro de Morais Neto em **Testar**.
- Pular pergunta de Título ou Branch.
- Inventar, inferir ou usar título ou branch sem o usuário ter informado explicitamente (inclui “pode criar” sem os dois valores).
- Usar recomendação do chat ou slug do `.md` como valor final de título ou branch.
- Inventar labels se **Avaliar** (Ação) ou **A fazer** (Status das subtarefas) não existirem no board.
- Executar qualquer ação fora do escopo desta skill sem autorização prévia do usuário.
