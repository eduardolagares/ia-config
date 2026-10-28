---
name: criar-tarefa-no-monday
description: >-
  Cria tarefa no Monday.com a partir de documento funcional pronto (item,
  documento, subtarefas, branch, colunas) via MCP Monday. No Dia a dia: grupo
  Escrevendo e coluna Ação = Avaliar (fixos). Tipo, Solicitante e Projetos
  Impactados são obrigatórios; os projetos são os slugs da seção Impactos do
  documento. A subtarefa Escrever fica com o usuário atual do Monday, não com
  um nome fixo. Entrevista só parâmetros do Monday — não redige o documento.
  Converte qualquer gráfico Mermaid em PNG antes de adicionar ao documento.
  Use com /criar-tarefa-no-monday.
disable-model-invocation: true
VERSION: "1.12.2"
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

O **conteúdo funcional** vem **pronto** — ficheiro (`docs/tarefas/…`), texto colado ou output de `/escrever-tarefa` (demanda) ou `/reportar-bug` (bug). **Esta skill não entrevista** para redigir o documento.

| Responsabilidade | Skill |
|------------------|--------|
| Redigir documento funcional | `escrever-tarefa` |
| Redigir relatório de bug | `reportar-bug` |
| Parâmetros Monday + publicar | `criar-tarefa-no-monday` |

Sem documento na invocação → pedir path, texto ou encaminhar para `/escrever-tarefa` (demanda nova) ou `/reportar-bug` (bug). **Não** inventar UCs/RFs nem fazer grill do conteúdo funcional.

**Regra central:** entrevistar **só** os parâmetros Monday antes de criar. Não reutilizar valores de sessões anteriores (quadro, grupo, branch, responsável, etc.).

**Mermaid:** o Monday **não** renderiza Mermaid. **Qualquer** gráfico Mermaid do documento (flowchart, sequenceDiagram, etc.) deve ser **convertido em imagem PNG antes** de ser adicionado ao documento — nunca colar blocos ` ```mermaid ` no `create_doc` nem no markdown enviado ao Monday.

## Monday — conexão (fase Execução)

1. `GetMcpTools` para descobrir o servidor Monday disponível (`plugin-monday-crm-monday` ou equivalente).
2. Se `serverStatus` ≠ `ready` → parar e pedir autenticação MCP.
3. `get_user_context` — identificar o utilizador atual (`id`, `name`). Esse `id` é o owner da subtarefa **Escrever**. Não substituir por um nome fixo. Se não houver `id`, parar; não publicar a subtarefa com outra pessoa.

Antes de `create_item` / `change_item_column_values`, chamar `get_board_info` no quadro escolhido para obter `groupId`, `column` ids e labels de status. **Só após** o gate (§ Gate de execução).

## Entrevista — só parâmetros Monday

### Hard stop — nunca pular a entrevista

**Antes de qualquer chamada MCP** (`create_item`, `create_doc`, `create_items`, etc.), a entrevista Monday **tem de estar concluída** e o utilizador **tem de ter respondido explicitamente** à pergunta **“posso criar?”**.

| Pedido do utilizador | O que **não** autoriza | O que fazer |
|----------------------|------------------------|-------------|
| “pode gerar o monday”, “cria no monday”, “gera a task” | Criar direto | Iniciar **Parâmetros Monday** (Respondidos fixos + Em aberto: Título, Branch, Tipo, Solicitante, Projetos Impactados, Prioridade) |
| Documento `.md` pronto ou contexto da conversa | Assumir título, branch, Tipo, Solicitante, Projetos Impactados ou prioridade | **Sugerir** valores; **confirmar** com o utilizador |
| “sim” à gravação do `.md` (`escrever-tarefa` ou `reportar-bug`) | Confirmação para publicar no Monday | Entrevista Monday é **fluxo separado** |
| “sim, crie no monday” / “sim + subtarefa UX” na mesma mensagem | Autorização para Executar | Entrevista + **“Posso criar…?”**; extras na lista de subtarefas do resumo |

**Proibido:** inferir branch, título, Tipo ou Solicitante do documento, tratar os slugs de Impactos como Projetos Impactados já confirmados, reutilizar valores de sessões anteriores, ou “ser proativo” pulando a entrevista — **mesmo que o usuário peça para criar** — mesmo que pareça óbvio.

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
| 8 | **Tipo** | Coluna **Tipo** (`label`) — **obrigatório**. Se o documento for relatório de bug, sugerir **BUG**; nos demais, perguntar o label sem escolher um por defeito |
| 9 | **Solicitante** | Coluna **Solicitante** (`label6`) — **obrigatório**. Perguntar o label; não sugerir um por defeito |
| 10 | **Projetos Impactados** | Coluna **Projetos Impactados** (`dropdown_mm7pg84c`) — **obrigatório**. Via de regra, os mesmos slugs da seção **Impactos** do documento — sugerir essa lista e confirmar |

**Não entrevistar (não perguntar nem exigir):** responsáveis de **Executar** e **Corrigir** (deixar `person` vazio). Deixar vazios salvo pedido explícito do utilizador.

**Proibido publicar** com **Tipo**, **Solicitante** ou **Projetos Impactados** vazios. Sugestão (inclusive a lista de Impactos) só entra em **Respondidos** depois que o usuário confirmar ou corrigir.

**Defaults obrigatórios do board (não entrevistar, não sobrescrever):** quadro **Dia a dia**; grupo **Escrevendo**; coluna **Ação** = **Avaliar**; subtarefas = lista padrão; **Executar** e **Corrigir** sem owner. **Proibido** criar em **Aguardando atribuição** ou gravar **Status consolidado**.

### Como conduzir

1. **Primeira mensagem:** listar os campos **entrevistáveis** (1, 4, 6, 8, 9, 10) com pergunta + recomendação quando o contexto sugerir (ex.: título a partir do documento; branch com `dev-…` ou `dev-fix-…`; Tipo **BUG** se for relatório de bug; Projetos Impactados = slugs de **Impactos**). Incluir no resumo, como já definidos: Quadro = **Dia a dia**, Grupo = **Escrevendo**, Ação = **Avaliar**, Subtarefas = lista padrão (Escrever = usuário atual do Monday, resolvido na execução; Executar/Corrigir sem responsável). Não omitir campos “para perguntar depois”.
2. **Após cada resposta do utilizador:** atualizar o estado e mostrar de novo:
   - **Respondidos** — campo + valor confirmado (incluir Quadro, Grupo, Ação e Subtarefas padrão como fixos)
   - **Em aberto** — campos ainda sem resposta (com a pergunta / recomendação)
3. Aceitar respostas parciais: o utilizador pode preencher um, vários ou todos os campos abertos na mesma mensagem.
4. Repetir o passo 2 até não restar obrigatório em aberto. Prioridade (#6) pode ficar vazia se o utilizador disser que não quer. **Tipo**, **Solicitante** e **Projetos Impactados** não podem ficar vazios. **Não** pedir Quadro, Grupo, Ação, lista de subtarefas nem owners de Executar/Corrigir.
5. **Confirmação final** (só quando o checklist obrigatório estiver completo): resumo completo + pergunta literal **“Posso criar no Monday exatamente com os parâmetros acima?”** — **sem** MCP no mesmo turno. Só Executar após **sim** do usuário **a essa pergunta**.

Formato sugerido a cada turno (após a 1.ª listagem ou após cada resposta):

```markdown
### Parâmetros Monday

**Respondidos:**
- Título: …
- Quadro: Dia a dia (fixo)
- Grupo: Escrevendo (fixo)
- Ação: Avaliar (fixo)
- Subtarefas: lista padrão (fixo; Escrever = usuário atual do Monday, resolvido na execução; Executar/Corrigir sem responsável)
…

**Em aberto:**
- 4. Branch — valor da coluna Branch? (ex.: `dev-…` ou `dev-fix-…`)
- 8. Tipo — label da coluna Tipo? (relatório de bug: sugestão **BUG**)
- 9. Solicitante — label da coluna Solicitante?
- 10. Projetos Impactados — os slugs de **Impactos** do documento (`ingressos`, …). Confirma?
…
```

**Subtarefas:** **sempre** criar a lista padrão abaixo, status inicial **A fazer**, com owners do § Atribuição. **Não** perguntar se confirma só a lista padrão. Extras pedidas pelo utilizador → listar no resumo antes do **“Posso criar…?”**.

Lista padrão (obrigatória):

1. `Escrever`
2. `Refinar documento`
3. `Executar`
4. `Revisar código automaticamente`
5. `Revisar código manualmente`
6. `Testar`
7. `Corrigir`
8. `Fazer deploy`

**Branch:** recomendar e gravar **sempre** com prefixo `dev-` (feature/ajuste) ou `dev-fix-` (correção). **Proibido** sugerir ou gravar `feat/`, `fix/` ou outros prefixos legados.

**Título:** pode sugerir a partir do documento; o utilizador confirma ou corrige.

**Tipo** (`label`, status): obrigatório. Label não vazio já existente no quadro. Se o documento for relatório de bug (`reportar-bug`, seção **Como replicar**), sugerir **BUG**. Demanda ou ajuste: perguntar, sem label por defeito. Labels: **Ajuste**, **Manutenção**, **BUG**, **IMPLANTAÇÃO**, **SEGURANÇA**, **MELHORIA**, **FUNCIONALIDADE**. Na execução, o texto tem de bater com `get_board_info`. Não criar label novo.

**Solicitante** (`label6`, status): obrigatório. Perguntar qual label; não sugerir um por defeito. Labels: **SAC**, **DIRETORIA**, **ADMINISTRAÇÃO**, **RISCO**, **CONTROLADORIA**, **FINANCEIRO**, **SUPORTE**, **COMERCIAL**, **TI**, **SÓCIO TORCEDOR**, **WHITELABEL**, **FERROVIÁRIA**, **QA**, **TICKETMASTER**, **SPORT RECIFE**, **CRUZEIRO**, **VITÓRIA EC**, **SANTOS FC**, **Eduardo Lagares**. **COMERCIAL** e **SÓCIO TORCEDOR** existem duas vezes no quadro: gravar `{"label": "<texto>"}`; se a API recusar a duplicata, usar o `index` menor entre os labels ativos com esse texto. Não criar label novo.

**Projetos Impactados** (`dropdown_mm7pg84c`, dropdown): obrigatório. Via de regra, os mesmos repositórios eleitos na seção **Impactos** do documento.

1. Ler a seção **Impactos** (`### **Impactos:**` ou equivalente).
2. De cada bullet, ficar só com o slug do repositório — o texto antes de ` — ` quando houver tela (`assinaturas-adm — Tela Faturas` → `assinaturas-adm`).
3. Ignorar placeholder (`_A confirmar com o usuário._`, `_A preencher._`) e o bullet `nenhum`.
4. Sugerir essa lista na entrevista. O usuário confirma ou corrige. Sem essa resposta, o campo continua **Em aberto**.
5. Cada valor tem de ser um label já existente no dropdown. Slug do documento que não exista no dropdown: avisar na mesma pergunta e pedir o label existente correspondente. Não criar label (`createLabelsIfMissing` proibido nesta coluna).
6. Lista vazia no documento (`nenhum`, seção ausente ou só placeholder): o campo continua obrigatório — perguntar quais projetos marcar. Não publicar com a coluna vazia.

Labels atuais do dropdown (conferir na execução com `get_board_info`): `auth2`, `ingressos`, `assinaturas`, `assinaturas-adm`, `vitrine-rails`, `checkout`, `account`, `site-v2`, `produtor`, `partner-api`, `comissarios`, `baladapp-react`, `baladapp-react-components`, `baladapp-mapa-assentos`, `biometria-facial`, `custom-errors`, `ingressos-api`, `facial-biometria`, `gatekeeper`, `auth-adm`, `virtual-waiting-room`, `sales_analytics`, `vendedor-api`.

## Referência — quadro Dia a dia (fixo)

Valores usados no time; quadro **sempre** Dia a dia — **não perguntar**:

| Campo | ID / coluna |
|-------|-------------|
| Board | Dia a dia — `4571892384` (**fixo**) |
| Grupo **Escrevendo** | resolver `groupId` via `get_board_info` pelo título exato **Escrevendo** |
| Branch | `texto` |
| Documento | `monday_doc` |
| **Ação** | resolver `column_id` via `get_board_info` pelo título **Ação** — label **`Avaliar`** |
| **Tipo** | `label` — **obrigatório**; status `{"label": "<confirmado>"}` |
| **Solicitante** | `label6` — **obrigatório**; status `{"label": "<confirmado>"}` |
| **Projetos Impactados** | `dropdown_mm7pg84c` — **obrigatório**; dropdown `{"labels": ["<slug>", …]}`; via de regra os slugs de **Impactos** |
| Subtarefas | coluna `subelementos` → board `4571892432` |
| Owner subtarefa | coluna `person` no subitem |
| Status subtarefa | coluna `status` — label `A fazer` |

**Descontinuado (não usar):** grupo **Aguardando atribuição**; coluna **Status consolidado** (`status_1`).

## Espaçamento entre blocos (obrigatório)

O `.md` em `docs/tarefas/` separa blocos com uma linha em branco (seção e seção, grupo de requisitos, caso de uso, grupo de critérios). O importador do Monday **apaga parágrafo vazio**: essa linha só delimita blocos e não vira espaço visível. Sem um parágrafo com conteúdo, as seções saem coladas.

**Não alterar** o arquivo local. A transformação vale só para o markdown de `create_doc` e de `add_markdown_content`.

Depois de remover os blocos ` ```mermaid `:

1. Cada linha em branco que separa blocos de conteúdo vira um parágrafo sozinho com `&nbsp;`.
2. Várias linhas em branco seguidas viram **um** `&nbsp;`.
3. Não inserir `&nbsp;` onde o `.md` não tem linha em branco (título colado no corpo, item colado no item).
4. Não inserir no início nem no fim do documento.

No `read_docs` seguinte, cada um desses separadores tem de ser um bloco de texto. Se o importador comeu o `&nbsp;`, criar o bloco com `create_block` (`block_type: "text"`, `text_block_type: "NORMAL_TEXT"`, delta `[{insert: {text: "\u00a0"}}, {insert: {text: "\n"}}]`) em `after_block_id` do bloco anterior. Publicar sem esses blocos não está pronto.

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

**Hospedagem no Monday (obrigatório):** depois do script, enviar **cada PNG como asset** do Monday e inserir no doc com `asset_id`. **Proibido** `public_url` de mermaid.ink, kroki ou outro host externo no `create_block` — hotlink quebra ou cai fora; `replace_block` com URL externa já publicou imagens inválidas.

### Upload PNG → asset (antes de inserir no doc)

Para cada arquivo `ucN.png` gerado pelo script (na ordem dos UCs):

1. `get_asset_upload_url` — `fileName`, `contentType: image/png`, `fileSize` em bytes.
2. `curl -si -X PUT` no `upload_url` com `--data-binary @ucN.png` — capturar header `ETag` (sem aspas).
3. `finalize_asset_upload` — `uploadId`, `etag`, `boardId` do item pai, `itemId` da tarefa, `columnId: monday_doc`.
4. **Asset id:** se a resposta trouxer `asset_id`, usar esse valor. Se falhar com `CellLimitExceededException` (coluna Documento já tem doc e não aceita anexo), o asset **mesmo assim é criado** — extrair `assetId` do JSON em `variables.value` / mensagem de erro (ex.: `"assetId":"3316844352"`).
5. Guardar mapa `UC N → asset_id` para o passo seguinte.

Detalhes e limites do board **Dia a dia**: [reference-mermaid-monday.md](reference-mermaid-monday.md) § Upload como asset Monday.

### Inserir no documento

1. **Não** enviar blocos ` ```mermaid ` no `create_doc` / `add_markdown_content`.
2. Criar documento só com texto (títulos, prosa, RFs), já com o parágrafo `&nbsp;` de cada linha em branco que separa blocos (§ Espaçamento).
3. `read_docs` com `include_blocks: true` — localizar o **último bloco** de cada UC (normalmente o último item da lista de passos).
4. `update_doc` → `create_block` com `block_type: "image"`, **`asset_id`** (do upload acima), `width: 700`, `after_block_id` = id desse último bloco do UC. **Não** colocar `alignment` nesse objeto: o schema do MCP rejeita o campo e a chamada falha. O bloco nasce alinhado à esquerda. Em seguida, centralizar com `all_api_write` → `update_doc_block`: reenviar o `content` do bloco com `alignment` `center` (minúsculo), mantendo `assetId`, `width` e `url`. Sem esse passo a imagem fica à esquerda.
5. Inserir **de UC 6 → UC 1** (ou apagar imagens erradas primeiro) para não deslocar âncoras. **Não** usar `replace_block` para corrigir posição — tende a jogar imagens no **fim** do doc; usar `delete_blocks` nas imagens mal colocadas + `create_block` com `after_block_id` correto.
6. O separador entre blocos é o `&nbsp;` do § Espaçamento, não um bloco vazio. Bloco só com `\n` o importador apaga. Espaçador não corrige imagem com proporção ou largura errada.
7. Verificar com **um** `read_docs` (blocos + comentários numa só leitura):
   - onde o `.md` tem linha em branco entre blocos, o doc tem um bloco de texto `&nbsp;` (seções, grupos de requisitos, casos de uso, grupos de critérios); título e corpo do mesmo bloco continuam colados;
   - sequência por UC: passos → imagem → parágrafo `&nbsp;` (quando o `.md` tem linha em branco ali) → título do próximo UC;
   - exatamente uma imagem por UC, nenhuma solta no fim **nem no início** do doc (`create_block` sem `after_block_id` joga a imagem para o topo);
   - cada imagem de diagrama com `alignment` `center` no content; `left` ou ausente → repetir `update_doc_block`. Não encerrar com imagem à esquerda;
   - `aspectRatio` de cada bloco de imagem confere com o `largura x altura` impresso pelo script — proporções idênticas em diagramas diferentes significam imagem de erro;
   - títulos de seção à esquerda, em negrito, com texto presente;
   - nenhum título vazio/duplicado e nenhuma imagem fora do respectivo UC.
8. Se algo falhar, corrigir e repetir `read_docs`; **não encerrar a criação sem essa validação**. Ela é o único passo que pega imagem quebrada ou fora de lugar — pular equivale a entregar o doc torto.

## Atualizar documento existente (sync)

Quando o documento já existe e o conteúdo funcional mudou (feedback, renumeração de RFs, ajuste de texto):

- **Sincronizar uma vez, no fim.** O markdown local (`docs/tarefas/…`) é a fonte da verdade. Fechar **todas** as alterações no arquivo e só então empurrar para o Monday — não sincronizar a cada rodada de feedback. No markdown enviado, aplicar o § Espaçamento (`&nbsp;` no lugar de cada linha em branco entre blocos). Não gravar `&nbsp;` no arquivo.
- **Uma leitura, um plano de escrita.** Um único `read_docs` com `include_blocks: true` e `include_comments: true`; a partir daí calcular **todas** as operações e disparar. Não intercalar leitura → escrita → leitura → escrita, nem chamar `read_docs` separado para blocos e para comentários.
- **Editar bloco a bloco é o padrão.** Mudança pontual (uma linha, um RF, um título) → `update_block` só nos blocos afetados, numa única chamada. Reescrever o corpo (`delete_blocks` + `add_markdown_content`) é exceção, reservada a mudança estrutural em cascata: renumeração de RFs, seções reagrupadas, ordem alterada. Refazer ~150 blocos para trocar uma linha custa minutos, força reler o doc inteiro e derruba a âncora de todos os comentários. **Não** decidir com base em preservar comentários.
- **Diagrama só re-renderiza se o mermaid mudou.** Comparar o bloco mermaid do `.md` com o que já está publicado: fonte idêntica → manter a imagem existente, sem rodar o script e sem refazer o `create_block`.
- **Comentários:** os ancorados em blocos reescritos somem junto; os de documento (sem âncora) sobrevivem. É aceitável — não é critério para escolher o método.
- **Diagramas cujo texto mudou** (ex.: número de RF citado): atualizar o bloco mermaid no `.md`, rodar o script, **novo upload asset**, `delete_blocks` na imagem antiga e `create_block` + `after_block_id`, depois `update_doc_block` com `alignment` `center`. Bloco de imagem é imutável quanto ao arquivo: nunca deixar duas imagens no mesmo UC.
- **Limites da API:** `delete_blocks` aceita ≤ 100 IDs por operação e `update_doc` ≤ 25 operações por chamada — dividir em lotes quando o doc for grande.

## Fluxo de criação

```
1. Obter documento pronto (ler ficheiro ou aceitar texto na invocação)
2. Entrevista — só parâmetros Monday (checklist acima)
3. get_board_info(boardId = Dia a dia `4571892384`)
4. create_item — name, groupId = **Escrevendo**, columnValues (**Ação** = **Avaliar**; **Tipo**; **Solicitante**; **Projetos Impactados**; Branch em `texto`)
5. Rodar o script `render_diagramas.py` sobre o `.md` — exit 0 obrigatório antes de seguir
6. create_doc — location: item, item_id, column_id: monday_doc, markdown **sem** bloco mermaid e **com** `&nbsp;` em cada linha em branco que separa blocos (§ Espaçamento)
7. Upload de **cada** `ucN.png` → asset Monday (`get_asset_upload_url` + PUT + `finalize_asset_upload`); obter `asset_id` por UC
8. `update_doc` → `create_block` (imagem com **`asset_id`**, `width: 700`, sem `alignment`) com `after_block_id` após o último passo de cada UC; em seguida `update_doc_block` com `alignment` `center` no content completo do bloco
9. create_items — subtarefas padrão com parentItemId, person + status por subtarefa
10. change_item_column_values — só o que o `create_item` não gravou (Branch, Tipo, Solicitante, Projetos Impactados). Não encerrar com algum desses vazio
11. `read_docs` (`include_blocks: true`) — validar ordem UC → imagem → próximo UC, `alignment` `center` em cada imagem e o parágrafo `&nbsp;` em cada linha em branco do `.md` (§ Espaçamento); `get_assets` se precisar conferir PNG
12. Responder com URLs do item, documento e subtarefas
```

### columnValues — formato

Ação (principal): `{"<column_id_acao>": {"label": "Avaliar"}}` — `column_id` via `get_board_info`  
Tipo: `{"label": {"label": "<confirmado>"}}`  
Solicitante: `{"label6": {"label": "<confirmado>"}}`  
Projetos Impactados: `{"dropdown_mm7pg84c": {"labels": ["ingressos", "assinaturas-adm"]}}` — array mesmo com um valor; labels = slugs confirmados  
Texto (branch): string direta em `texto` (prefixo `dev-` ou `dev-fix-`)  
People (subtarefa): `{"personsAndTeams": [{"id": <user_id>, "kind": "person"}]}` — `Testar` leva os dois owners no mesmo array  
**Não** escrever em **Status consolidado**.  
**Não** publicar sem **Tipo**, **Solicitante** e **Projetos Impactados**. **Não** usar `createLabelsIfMissing` nessas três colunas.

### Atribuição

- Item principal do Dia a dia **não** tem coluna Person direta; responsável reflete nas subtarefas (`person`).
- **Escrever:** owner = usuário atual devolvido por `get_user_context` (`id` e `name`). É quem está criando a tarefa no Monday. Não gravar um nome fixo. Não inferir o owner pelo login do sistema, pelo path home nem por sessão anterior.
- Demais owners nomeados: resolver `user_id` via `list_users_and_teams` pelo nome — **nunca** inventar IDs.
- Com a lista padrão de subtarefas, aplicar **automaticamente** (salvo override explícito do utilizador):

| Subtarefa | Owner (`person`) |
|-----------|------------------|
| `Escrever` | usuário atual do Monday (`get_user_context`) |
| `Refinar documento` | Eduardo Lagares |
| `Revisar código automaticamente` | Eduardo Lagares |
| `Revisar código manualmente` | Eduardo Lagares |
| `Fazer deploy` | Eduardo Lagares |
| `Testar` | João Sanches e Leandro Rodrigues |
| `Executar` | **sem owner** (fixo — não perguntar; não preencher `person`) |
| `Corrigir` | **sem owner** (fixo — não perguntar; não preencher `person`) |

- Na entrevista / confirmação final, **mostrar** estes owners no resumo. **Escrever** aparece como «usuário atual do Monday»; o nome só existe depois de `get_user_context`, na execução. Não perguntar quem é. Só mudar se o utilizador pedir.
- Na saída da tarefa criada, a subtarefa **Escrever** mostra o `name` resolvido.
- **Proibido** atribuir **Escrever** a uma pessoa fixa.
- **Proibido** atribuir **Executar** ou **Corrigir** por defeito.

## Saída no chat (obrigatória)

```markdown
## Tarefa criada

**Item:** [título](url)
- Quadro / Grupo (Escrevendo) / Ação (Avaliar) / Branch (`dev-…` ou `dev-fix-…`) / Tipo / Solicitante / Projetos Impactados / Prioridade (se houver)

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
| Imagem vazia / `aspectRatio` igual em diagramas diferentes | Renderer devolveu erro. Rodar o script (ele detecta), trocar o renderer no topo dele, re-upload asset e reinserir com `asset_id` |
| Imagens só no fim do doc (após CAs) | Causa comum: `replace_block` ou `create_block` sem `after_block_id`. `delete_blocks` nas imagens + `create_block` após o último passo de cada UC |
| URL mermaid.ink / kroki no doc | Proibido. Só PNG do script + `asset_id` Monday |
| Diagrama vertical (`flowchart TD`) | Reescrever em `flowchart LR` no `.md` e rodar o script; ele recusa TD |
| Imagem sobreposta ao texto | Medir o PNG e a altura exibida; corrigir orientação/proporção e substituir a imagem. Espaçadores não corrigem geometria errada |
| Diagrama ilegível por ser muito largo | Simplificar nós/rótulos ou reorganizar o fluxo; renderizar e medir novamente antes de publicar |
| Título vazio, duplicado ou desalinhado | `read_docs`; remover duplicata e normalizar conteúdo, negrito e alinhamento `LEFT` |
| Seções coladas, sem a linha em branco do `.md` | O importador apagou o parágrafo vazio. Inserir `&nbsp;` (§ Espaçamento) ou `create_block` com `\u00a0` entre os blocos. Não editar o `.md` |
| Imagem de diagrama à esquerda | `update_doc_block` com o content do bloco e `alignment` `center`. Não passar `alignment` no `create_block` do MCP |
| Mermaid como código no Monday | Remover; substituir por imagem |
| Label de status inexistente | `get_board_info` → labels exatos. Em **Tipo**, **Solicitante** e **Projetos Impactados**, não criar label; voltar à entrevista |
| Tipo, Solicitante ou Projetos Impactados vazio | Não publicar. Os três são obrigatórios |
| Slug de Impactos sem label no dropdown | Não criar label. Perguntar qual label existente usar |
| Grupo/coluna descontinuados | Não usar **Aguardando atribuição** nem **Status consolidado**; usar **Escrevendo** e **Ação = Avaliar** |
| Prefixo de branch legado | Não usar `feat/` nem `fix/`; usar `dev-` ou `dev-fix-` |
| MCP Monday indisponível | Parar; não inventar IDs |
| Pulou entrevista / criou sem “posso criar?” | **Erro grave.** Não repetir. Voltar ao § Hard stop; pedir desculpas; entrevistar antes de qualquer nova criação |

## Proibido

- Chamar MCP Monday ou `render_diagramas.py` **antes** da confirmação explícita à **“Posso criar no Monday exatamente com os parâmetros acima?”**
- **Mesmo turno:** texto de entrevista ou “vou confirmar…” **e** qualquer tool de Execução
- Tratar “gera o monday”, “sim”, documento pronto ou pedido de subtarefa extra como substituto do **“Posso criar…?”**
- Assumir título, branch, prioridade, Tipo, Solicitante ou Projetos Impactados sem resposta do utilizador na checklist (sugestão ≠ confirmado)
- Publicar com **Tipo**, **Solicitante** ou **Projetos Impactados** vazios
- Atribuir **Escrever** a uma pessoa fixa; o owner é o usuário atual de `get_user_context`
- Criar label novo em **Tipo**, **Solicitante** ou **Projetos Impactados**
- Criar item “proativamente” para poupar um turno de chat
- Inserir diagramas com `public_url` de mermaid.ink ou qualquer CDN externo no Monday doc
- Gravar `&nbsp;` no `.md` da tarefa, ou publicar o documento Monday sem o parágrafo `&nbsp;` onde o arquivo tem linha em branco entre blocos
- Publicar imagem de diagrama alinhada à esquerda, ou colocar `alignment` no `create_block` do MCP
- Usar `replace_block` como atalho para “mover” imagem entre UCs

## Skills relacionadas

| Skill | Quando |
|-------|--------|
| `escrever-tarefa` | **Antes** — demanda nova ou mudança de fluxo ainda não especificada |
| `reportar-bug` | **Antes** — bug reproduzível; artefato em `docs/tarefas/` sem RFs/UCs |
| `monday-task-info` | Ler tarefa existente (somente leitura) |

**Ordem típica:** `/escrever-tarefa` ou `/reportar-bug` → documento pronto → `/criar-tarefa-no-monday` com o ficheiro ou texto.

## Referência adicional

- Renderização, estado dos renderers e posicionamento de imagens: [reference-mermaid-monday.md](reference-mermaid-monday.md)
- Script obrigatório de diagramas: `render_diagramas.py` (nesta pasta)
