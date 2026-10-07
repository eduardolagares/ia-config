---
name: criar-tarefa-no-monday
description: >-
  Cria tarefa no Monday.com a partir de documento funcional pronto (item,
  documento, subtarefas, branch, colunas) via MCP Monday. No Dia a dia: grupo
  Escrevendo e coluna Ação = Avaliar (fixos). Entrevista só parâmetros do
  Monday — não redige o documento. Converte qualquer gráfico Mermaid em PNG
  antes de adicionar ao documento. Use com /criar-tarefa-no-monday.
disable-model-invocation: true
VERSION: "1.9.0"
---

# criar-tarefa-no-monday

Publica no Monday uma tarefa já especificada: item no quadro, documento na coluna **Documento**, subtarefas, branch e metadados.

## Gate de execução (ler primeiro)

**Duas fases:** (1) **Entrevista** — só texto no chat; (2) **Execução** — MCP Monday + `render_diagramas.py`.

**Proibido na fase Entrevista** (inclui o turno em que você pergunta parâmetros ou “posso criar?”): qualquer MCP Monday (`create_item`, `create_doc`, `create_items`, `change_item_column_values`, `update_doc`, …), `render_diagramas.py`, e **usar sugestão como valor gravado** (título/branch só entram em **Respondidos** depois que o usuário confirmar ou corrigir).

**Única autorização para Executar:** resposta explícita do usuário à pergunta **“Posso criar no Monday exatamente com os parâmetros acima?”** (ou equivalente), **depois** do bloco `### Parâmetros Monday` com checklist fechada (sem **Em aberto** obrigatório).

| O usuário disse | Autoriza Executar? |
|-----------------|-------------------|
| “cria no monday”, “sim”, “pode gerar monday”, “crie subtask UX”, pedido extra de subtarefa | **Não** — mostrar/atualizar **Parâmetros Monday** |
| Confirmou título e/ou branch (ou “confirmo o sugerido”) | **Não** — ainda falta **“Posso criar…?”** |
| “sim” / “pode criar” **somente** à pergunta **“Posso criar…?”** com resumo completo | **Sim** — MCP no **próximo** turno do agente |

**Caminho feliz (2 turnos):** (1) agente — fixos + sugestões + lista final de subtarefas (padrão + extras) + **“Posso criar…?”**; (2) usuário — `sim` ou ajustes + `sim`; (3) agente — Executar.

**Overrides de subtarefa** (ex.: UX): entram na **lista nominal** do resumo; não aplicar silenciosamente.

## Entrada: documento pronto

O **conteúdo funcional** (UCs, telas, RFs) vem **pronto** — ficheiro (`docs/tarefas/…`), texto colado ou output de `/escrever-tarefa`. **Esta skill não entrevista** para redigir o documento.

| Responsabilidade | Skill |
|------------------|--------|
| Redigir documento funcional | `escrever-tarefa` |
| Parâmetros Monday + publicar | `criar-tarefa-no-monday` |

Sem documento na invocação → pedir path, texto ou encaminhar para `/escrever-tarefa`. **Não** inventar UCs/RFs nem fazer grill do conteúdo.

**Regra central:** entrevistar **só** os parâmetros Monday antes de criar. Não reutilizar valores de sessões anteriores (quadro, grupo, branch, responsável, etc.).

**Mermaid:** o Monday **não** renderiza Mermaid. **Qualquer** gráfico Mermaid do documento (flowchart, sequenceDiagram, etc.) deve ser **convertido em imagem PNG antes** de ser adicionado ao documento — nunca colar blocos ` ```mermaid ` no `create_doc` nem no markdown enviado ao Monday.

## Monday — conexão (fase Execução)

1. `GetMcpTools` para descobrir o servidor Monday disponível (`plugin-monday-crm-monday` ou equivalente).
2. Se `serverStatus` ≠ `ready` → parar e pedir autenticação MCP.
3. `get_user_context` — identificar o utilizador atual (`id`, `name`) para atribuição.

Antes de `create_item` / `change_item_column_values`, chamar `get_board_info` no quadro escolhido para obter `groupId`, `column` ids e labels de status. **Só após** o gate (§ Gate de execução).

## Entrevista — só parâmetros Monday

### Hard stop — nunca pular a entrevista

**Antes de qualquer chamada MCP** (`create_item`, `create_doc`, `create_items`, etc.), a entrevista Monday **tem de estar concluída** e o utilizador **tem de ter respondido explicitamente** à pergunta **“posso criar?”**.

| Pedido do utilizador | O que **não** autoriza | O que fazer |
|----------------------|------------------------|-------------|
| “pode gerar o monday”, “cria no monday”, “gera a task” | Criar direto | Iniciar **Parâmetros Monday** (Respondidos fixos + Em aberto: Título, Branch, Prioridade) |
| Documento `.md` pronto ou contexto da conversa | Assumir título, branch ou prioridade | **Sugerir** valores; **confirmar** com o utilizador |
| “sim” à gravação do `.md` (`escrever-tarefa`) | Confirmação para publicar no Monday | Entrevista Monday é **fluxo separado** |
| “sim, crie no monday” / “sim + subtarefa UX” na mesma mensagem | Autorização para Executar | Entrevista + **“Posso criar…?”**; extras na lista de subtarefas do resumo |

**Proibido:** inferir branch/título do documento, reutilizar valores de sessões anteriores, ou “ser proativo” pulando a entrevista — **mesmo que o usuário peça para criar** — mesmo que pareça óbvio.

**Ordem obrigatória:** entrevista → checklist completo → **“Posso criar no Monday exatamente com os parâmetros acima?”** → resposta afirmativa **a essa pergunta** → **só então** MCP (turno seguinte).

**Todas as perguntas entrevistáveis de uma vez** na primeira mensagem da entrevista (Quadro, Grupo, Ação, subtarefas padrão e owners fixos — ver checklist). O utilizador pode responder **várias de uma vez** (ou todas).

**Fora do âmbito desta entrevista:** escopo funcional, UCs, telas, RFs, regras de negócio — já vêm no documento pronto.

Checklist — confirmar **todos** (exceto prioridade, opcional) antes de criar:

| # | Campo | Exemplo de pergunta |
|---|--------|---------------------|
| 1 | Título do item | Nome da tarefa no Monday (pode derivar do `# Título` do documento — confirmar) |
| 2 | Quadro | **Fixo:** **Dia a dia** (`4571892384`) — **não perguntar** |
| 3 | Grupo | **Fixo:** **Escrevendo** — não perguntar; não usar **Aguardando atribuição** |
| 4 | Branch | Valor da coluna **Branch** (`texto`) — sempre com prefixo `dev-` ou `dev-fix-` (nunca `feat/`, `fix/` ou equivalentes) |
| 5 | **Ação** | **Fixo:** label **Avaliar** — não perguntar; substitui o antigo **Status consolidado** (descontinuado) |
| 6 | Prioridade | Coluna **Priority** (`priority__1`) — opcional |
| 7 | Subtarefas | **Fixo:** lista padrão + owners do § Atribuição — **não perguntar** a lista padrão; se o utilizador pedir extra (ex.: UX), incluir na **lista nominal** do resumo e confirmar no **“Posso criar…?”** |

**Não entrevistar (não perguntar nem exigir):** coluna **Tipo** (`label`); coluna **Solicitante** (`label6`); responsáveis de **Executar** e **Corrigir** (deixar `person` vazio). Deixar vazias salvo pedido explícito do utilizador.

**Defaults obrigatórios do board (não entrevistar, não sobrescrever):** quadro **Dia a dia**; grupo **Escrevendo**; coluna **Ação** = **Avaliar**; subtarefas = lista padrão; **Executar** e **Corrigir** sem owner. **Proibido** criar em **Aguardando atribuição** ou gravar **Status consolidado**.

### Como conduzir

1. **Primeira mensagem:** listar os campos **entrevistáveis** (1, 4, 6) com pergunta + recomendação quando o contexto sugerir (ex.: título a partir do documento; branch com `dev-…` ou `dev-fix-…`). Incluir no resumo, como já definidos: Quadro = **Dia a dia**, Grupo = **Escrevendo**, Ação = **Avaliar**, Subtarefas = lista padrão (Executar/Corrigir sem responsável). Não omitir campos “para perguntar depois”.
2. **Após cada resposta do utilizador:** atualizar o estado e mostrar de novo:
   - **Respondidos** — campo + valor confirmado (incluir Quadro, Grupo, Ação e Subtarefas padrão como fixos)
   - **Em aberto** — campos ainda sem resposta (com a pergunta / recomendação)
3. Aceitar respostas parciais: o utilizador pode preencher um, vários ou todos os campos abertos na mesma mensagem.
4. Repetir o passo 2 até não restar obrigatório em aberto. Prioridade (#6) pode ficar vazia se o utilizador disser que não quer. **Não** pedir Quadro, Grupo, Ação, Tipo, Solicitante, lista de subtarefas nem owners de Executar/Corrigir.
5. **Confirmação final** (só quando o checklist obrigatório estiver completo): resumo completo + pergunta literal **“Posso criar no Monday exatamente com os parâmetros acima?”** — **sem** MCP no mesmo turno. Só Executar após **sim** do usuário **a essa pergunta**.

Formato sugerido a cada turno (após a 1.ª listagem ou após cada resposta):

```markdown
### Parâmetros Monday

**Respondidos:**
- Título: …
- Quadro: Dia a dia (fixo)
- Grupo: Escrevendo (fixo)
- Ação: Avaliar (fixo)
- Subtarefas: lista padrão (fixo; Executar/Corrigir sem responsável)
…

**Em aberto:**
- 4. Branch — valor da coluna Branch? (ex.: `dev-…` ou `dev-fix-…`)
…
```

**Subtarefas:** **sempre** criar a lista padrão abaixo, status inicial **A fazer**, com owners do § Atribuição. **Não** perguntar se confirma só a lista padrão. Extras pedidas pelo utilizador → listar no resumo antes do **“Posso criar…?”**.

Lista padrão (obrigatória):

1. `Escrever`
2. `Executar`
3. `Revisar código automaticamente`
4. `Revisar código manualmente`
5. `Testar`
6. `Corrigir`
7. `Fazer deploy`

**Branch:** recomendar e gravar **sempre** com prefixo `dev-` (feature/ajuste) ou `dev-fix-` (correção). **Proibido** sugerir ou gravar `feat/`, `fix/` ou outros prefixos legados.

**Título:** pode sugerir a partir do documento; o utilizador confirma ou corrige.

## Referência — quadro Dia a dia (fixo)

Valores usados no time; quadro **sempre** Dia a dia — **não perguntar**:

| Campo | ID / coluna |
|-------|-------------|
| Board | Dia a dia — `4571892384` (**fixo**) |
| Grupo **Escrevendo** | resolver `groupId` via `get_board_info` pelo título exato **Escrevendo** |
| Branch | `texto` |
| Documento | `monday_doc` |
| **Ação** | resolver `column_id` via `get_board_info` pelo título **Ação** — label **`Avaliar`** |
| Tipo | `label` — **não entrevistar**; não preencher por defeito |
| Solicitante | `label6` — **não entrevistar**; não preencher por defeito |
| Subtarefas | coluna `subelementos` → board `4571892432` |
| Owner subtarefa | coluna `person` no subitem |
| Status subtarefa | coluna `status` — label `A fazer` |

**Descontinuado (não usar):** grupo **Aguardando atribuição**; coluna **Status consolidado** (`status_1`).

## Diagramas Mermaid no documento (obrigatório)

**Qualquer** gráfico Mermaid — UC, fluxo, sequência, estado, etc. — deve ser **renderizado como PNG antes** de entrar no documento Monday. O Monday só exibe imagem; código Mermaid aparece como bloco de código sem renderização.

**Proibido:** adicionar ao documento blocos ` ```mermaid `, texto Mermaid cru ou diagramas não convertidos.

### Renderizar (só pelo script)

**Proibido montar a URL do diagrama à mão.** O único caminho é o script da skill, que lê os blocos do próprio `.md`, baixa o PNG e **verifica os bytes**:

```bash
python3 ~/.cursor/skills/eduardolagares/criar-tarefa-no-monday/render_diagramas.py \
  docs/tarefas/<arquivo>.md /tmp/diagramas
```

Ele imprime uma linha por diagrama (`UC n <caminho> <largura>x<altura>`) e sai com **exit ≠ 0** quando:

- o `flowchart` não está em `LR` — vertical vira tira alta e ilegível no `width: 700`;
- a resposta não é PNG (renderer fora do ar devolve HTML/erro).

**Altura não é limitada.** `sequenceDiagram` cresce na vertical por natureza; imagem alta no doc é aceitável e não motiva simplificar o diagrama.

**Exit ≠ 0 → não publicar.** Corrigir o `.md` (ou o renderer no topo do script) e rodar de novo. Como o script lê o `.md`, o diagrama do Monday nunca divergir do arquivo local.

**Nunca inserir imagem que não saiu do script.** Escrever mermaid solto no shell e colar URL no `create_block` foi exatamente o que publicou quatro imagens quebradas em `flowchart TD` — o endpoint `kroki.io/mermaid` vive fora do ar e ninguém percebe, porque o Monday aceita a URL e mostra imagem vazia.

Preferir `asset_id` nativo quando o board tiver coluna de arquivo (imagem fica no Monday, não apodrece); sem coluna de arquivo, `public_url` do renderer verificado.

### Inserir no documento

1. **Não** enviar blocos ` ```mermaid ` no `create_doc` / `add_markdown_content`.
2. Criar documento só com texto (títulos, prosa, RFs).
3. `read_docs` com `include_blocks: true` — localizar o **último bloco** de cada UC (normalmente o último item da lista de passos).
4. `update_doc` → `create_block` com `block_type: "image"`, `asset_id` (preferencial) ou `public_url`, `after_block_id` = id desse último bloco do UC.
5. **Não** usar só `replace_block` no bloco mermaid antigo — reposiciona imagens no fim do doc. Preferir `create_block` com `after_block_id`.
6. Pode criar um bloco de texto vazio antes/depois da imagem para separação visual, mas isso **não corrige** imagem com proporção ou largura errada.
7. Verificar com **um** `read_docs` (blocos + comentários numa só leitura):
   - sequência por UC: passos → imagem → título do próximo UC (espaçadores opcionais);
   - exatamente uma imagem por UC, nenhuma solta no fim **nem no início** do doc (`create_block` sem `after_block_id` joga a imagem para o topo);
   - `aspectRatio` de cada bloco de imagem confere com o `largura x altura` impresso pelo script — proporções idênticas em diagramas diferentes significam imagem de erro;
   - títulos de seção à esquerda, em negrito, com texto presente;
   - nenhum título vazio/duplicado e nenhuma imagem fora do respectivo UC.
8. Se algo falhar, corrigir e repetir `read_docs`; **não encerrar a criação sem essa validação**. Ela é o único passo que pega imagem quebrada ou fora de lugar — pular equivale a entregar o doc torto.

## Atualizar documento existente (sync)

Quando o documento já existe e o conteúdo funcional mudou (feedback, renumeração de RFs, ajuste de texto):

- **Sincronizar uma vez, no fim.** O markdown local (`docs/tarefas/…`) é a fonte da verdade. Fechar **todas** as alterações no arquivo e só então empurrar para o Monday — não sincronizar a cada rodada de feedback.
- **Uma leitura, um plano de escrita.** Um único `read_docs` com `include_blocks: true` e `include_comments: true`; a partir daí calcular **todas** as operações e disparar. Não intercalar leitura → escrita → leitura → escrita, nem chamar `read_docs` separado para blocos e para comentários.
- **Editar bloco a bloco é o padrão.** Mudança pontual (uma linha, um RF, um título) → `update_block` só nos blocos afetados, numa única chamada. Reescrever o corpo (`delete_blocks` + `add_markdown_content`) é exceção, reservada a mudança estrutural em cascata: renumeração de RFs, seções reagrupadas, ordem alterada. Refazer ~150 blocos para trocar uma linha custa minutos, força reler o doc inteiro e derruba a âncora de todos os comentários. **Não** decidir com base em preservar comentários.
- **Diagrama só re-renderiza se o mermaid mudou.** Comparar o bloco mermaid do `.md` com o que já está publicado: fonte idêntica → manter a imagem existente, sem rodar o script e sem refazer o `create_block`.
- **Comentários:** os ancorados em blocos reescritos somem junto; os de documento (sem âncora) sobrevivem. É aceitável — não é critério para escolher o método.
- **Diagramas cujo texto mudou** (ex.: número de RF citado): atualizar o bloco mermaid no `.md`, rodar o script e reinserir com `create_block` + `after_block_id`. Bloco de imagem é imutável: apagar o antigo, nunca deixar os dois.
- **Limites da API:** `delete_blocks` aceita ≤ 100 IDs por operação e `update_doc` ≤ 25 operações por chamada — dividir em lotes quando o doc for grande.

## Fluxo de criação

```
1. Obter documento pronto (ler ficheiro ou aceitar texto na invocação)
2. Entrevista — só parâmetros Monday (checklist acima)
3. get_board_info(boardId = Dia a dia `4571892384`)
4. create_item — name, groupId = **Escrevendo**, columnValues (**Ação** = **Avaliar**; sem Tipo/Solicitante por defeito)
5. Rodar o script `render_diagramas.py` sobre o `.md` — exit 0 obrigatório antes de seguir
6. create_doc — location: item, item_id, column_id: monday_doc, markdown **sem** nenhum bloco mermaid
7. update_doc → create_block (imagem) com `after_block_id` após o último passo de cada UC
8. create_items — subtarefas padrão com parentItemId, person + status por subtarefa
9. change_item_column_values — branch em texto com prefixo `dev-` ou `dev-fix-` (e outros campos se faltarem)
10. read_docs + get_assets (quando usar asset) — validar ordem, geometria e alinhamento
11. Responder com URLs do item, documento e subtarefas
```

### columnValues — formato

Ação (principal): `{"<column_id_acao>": {"label": "Avaliar"}}` — `column_id` via `get_board_info`  
Texto (branch): string direta em `texto` (prefixo `dev-` ou `dev-fix-`)  
People (subtarefa): `{"personsAndTeams": [{"id": <user_id>, "kind": "person"}]}` — `Testar` leva os dois owners no mesmo array  
**Não** escrever em **Status consolidado**.  
**Não** preencher **Tipo** nem **Solicitante** salvo pedido explícito.

### Atribuição

- Item principal do Dia a dia **não** tem coluna Person direta; responsável reflete nas subtarefas (`person`).
- Resolver `user_id` via `list_users_and_teams` / `get_user_context` pelo nome — **nunca** inventar IDs.
- Com a lista padrão de subtarefas, aplicar **automaticamente** (salvo override explícito do utilizador):

| Subtarefa | Owner (`person`) |
|-----------|------------------|
| `Escrever` | Adão Neto (fixo — sempre) |
| `Revisar código automaticamente` | Eduardo Lagares |
| `Revisar código manualmente` | Eduardo Lagares |
| `Fazer deploy` | Eduardo Lagares |
| `Testar` | João Sanches e Leandro Rodrigues |
| `Executar` | **sem owner** (fixo — não perguntar; não preencher `person`) |
| `Corrigir` | **sem owner** (fixo — não perguntar; não preencher `person`) |

- Na entrevista / confirmação final, **mostrar** estes owners no resumo; só mudar se o utilizador pedir.
- **Proibido** atribuir **Executar** ou **Corrigir** por defeito.

## Saída no chat (obrigatória)

```markdown
## Tarefa criada

**Item:** [título](url)
- Quadro / Grupo (Escrevendo) / Ação (Avaliar) / Branch (`dev-…` ou `dev-fix-…`) / Prioridade (se houver)

**Documento:** [nome](doc_url)
- Diagramas: N imagens (se aplicável)

**Subtarefas:**
1. Nome — responsável — status — url
...
```

## Erros comuns

| Problema | Ação |
|----------|------|
| Imagens no fim ou no topo do doc | `delete_blocks` + `create_block` com `after_block_id` correto; `create_block` sem `after_block_id` vai para o topo |
| Imagem vazia / `aspectRatio` igual em diagramas diferentes | Renderer devolveu erro. Rodar o script (ele detecta), trocar o renderer no topo dele e reinserir |
| Diagrama vertical (`flowchart TD`) | Reescrever em `flowchart LR` no `.md` e rodar o script; ele recusa TD |
| Imagem sobreposta ao texto | Medir o PNG e a altura exibida; corrigir orientação/proporção e substituir a imagem. Espaçadores não corrigem geometria errada |
| Diagrama ilegível por ser muito largo | Simplificar nós/rótulos ou reorganizar o fluxo; renderizar e medir novamente antes de publicar |
| Título vazio, duplicado ou desalinhado | `read_docs`; remover duplicata e normalizar conteúdo, negrito e alinhamento `LEFT` |
| Mermaid como código no Monday | Remover; substituir por imagem |
| Label de status inexistente | `get_board_info` → labels exatos; ou `createLabelsIfMissing: true` |
| Grupo/coluna descontinuados | Não usar **Aguardando atribuição** nem **Status consolidado**; usar **Escrevendo** e **Ação = Avaliar** |
| Prefixo de branch legado | Não usar `feat/` nem `fix/`; usar `dev-` ou `dev-fix-` |
| MCP Monday indisponível | Parar; não inventar IDs |
| Pulou entrevista / criou sem “posso criar?” | **Erro grave.** Não repetir. Voltar ao § Hard stop; pedir desculpas; entrevistar antes de qualquer nova criação |

## Proibido

- Chamar MCP Monday ou `render_diagramas.py` **antes** da confirmação explícita à **“Posso criar no Monday exatamente com os parâmetros acima?”**
- **Mesmo turno:** texto de entrevista ou “vou confirmar…” **e** qualquer tool de Execução
- Tratar “gera o monday”, “sim”, documento pronto ou pedido de subtarefa extra como substituto do **“Posso criar…?”**
- Assumir título, branch ou prioridade sem resposta do utilizador na checklist (sugestão ≠ confirmado)
- Criar item “proativamente” para poupar um turno de chat

## Skills relacionadas

| Skill | Quando |
|-------|--------|
| `escrever-tarefa` | **Antes** — quando ainda não há documento funcional pronto |
| `monday-task-info` | Ler tarefa existente (somente leitura) |

**Ordem típica:** `/escrever-tarefa` → documento pronto → `/criar-tarefa-no-monday` com o ficheiro ou texto.

## Referência adicional

- Renderização, estado dos renderers e posicionamento de imagens: [reference-mermaid-monday.md](reference-mermaid-monday.md)
- Script obrigatório de diagramas: `render_diagramas.py` (nesta pasta)
