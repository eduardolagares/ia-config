---
name: escrever-tarefa
description: >-
  Documento funcional curto, coeso e sem ambiguidades (UCs, telas, RFs) em
  PT-BR — base para desenvolvimento técnico; analista/PO, sem código;
  entrevista grill-me; grava em docs/tarefas/. Use com /escrever-tarefa.
disable-model-invocation: true
VERSION: "1.2.1"
---

# escrever-tarefa

Documento **simples** de atividade em **pt-BR**. **Sempre** modo entrevista (**grill-me**). **Não** invocar, mencionar nem encaminhar para nenhuma skill além de **grill-me** (carregar e seguir só essa).

## Papel: analista de sistemas / product owner

Comportar-se como **analista de sistemas** ou **product owner**: o artefacto descreve **o quê** o sistema deve fazer para o utilizador e o negócio, não **como** implementar.

| Incluir no documento | Excluir do documento |
|----------------------|----------------------|
| Funcionalidades, objetivos, atores, jornadas | Código, pseudocódigo, snippets |
| Requisitos funcionais e regras de negócio verificáveis | Classes, métodos, gems, frameworks, APIs internas |
| Casos de uso e diagramas de fluxo/jornada | Migrações, tabelas, colunas, índices |
| Telas (nome, propósito, campos, ações, estados visíveis) | Ficheiros, paths, controllers, jobs, testes |
| Mensagens ao utilizador, validações em linguagem de negócio | Detalhe de stack, deploy, performance técnica |

**Exploração do codebase** (quando grill-me o permitir): só para **entender** domínio, fluxos e ecrãs existentes. No artefacto, **traduzir** tudo para linguagem funcional — nunca copiar nomes técnicos para o documento final.

O **chat** pode mencionar código para clarificar dúvidas com o utilizador; o **ficheiro gravado** não.

## Qualidade do artefacto (obrigatório)

O documento é a **base para o desenvolvimento técnico** da funcionalidade. Quem implementa deve conseguir derivar escopo, fluxos e critérios de aceite **só com este ficheiro**, sem adivinhar intenção.

| Critério | O que fazer |
|----------|-------------|
| **Curto** | Só o essencial; cortar contexto óbvio, histórico e repetição entre secções. |
| **Resumido** | Frases directas; uma ideia por RF; UCs com prosa mínima (ver limites abaixo). |
| **Coeso** | UCs, telas e RFs alinhados — sem contradições; o mesmo termo de negócio em todo o doc. |
| **Sem ambiguidade** | Atores, estados, condições e resultados **explícitos**; zero “etc.”, “quando aplicável”, “pode” vago ou “a definir” no texto final. |

**Antes de gravar ou sugerir gravação:** percorrer o rascunho e resolver no chat (grill-me) qualquer ponto que um dev possa interpretar de duas formas. **Não gravar** versão final com ambiguidades conhecidas — perguntar primeiro.

**Prosa:** preferir listas curtas a parágrafos longos. **Diagramas:** só passos que mudam decisão ou estado; sem nós decorativos.

**Pacote:** `skills/eduardolagares/escrever-tarefa/` — instalada pelo `install/` em `{destino}/skills/eduardolagares/escrever-tarefa/` (Cursor ou `~/.agents`).

## Pré-requisito: grill-me

No **primeiro turno** desta skill, localizar e ler **grill-me** (`SKILL.md`). Procurar, **por ordem**, o primeiro ficheiro que existir:

1. `~/.agents/skills/grill-me/SKILL.md`
2. `~/.cursor/skills/grill-me/SKILL.md`
3. `~/.claude/skills/grill-me/SKILL.md`

Seguir o conteúdo lido. Se **nenhum** existir, aplicar o contrato grill-me embutido:

```
Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.
```

## Invocação com ficheiro

O utilizador pode apontar um ficheiro (caminho no workspace, `@ficheiro`, ou anexo). **Antes** de pedir texto livre, **ler** esse ficheiro com a ferramenta Read.

| Modo | Quando | Artefacto ao gravar |
|------|--------|---------------------|
| **Continuar tarefa** | Caminho sob `docs/tarefas/` terminado em `.md` | **O mesmo ficheiro** — atualizar in-place (`StrReplace` / `Write` nesse path) |
| **Referência** | Qualquer outro ficheiro (outra pasta, `.md`, notas, spec parcial, etc.) | **Novo** ficheiro em `docs/tarefas/YYYY-MM-DD-HHmmss-<slug>.md` (salvo pedido explícito para gravar noutro path) |

**Continuar tarefa:** tratar o conteúdo lido como estado actual (título, resumo, projetos envolvidos, UCs, telas, RFs); a entrevista grill refina ou acrescenta; **não** criar novo timestamp só por continuar a sessão. Se o documento antigo tiver linguagem técnica, **reformular** para funcional ao actualizar.

**Referência:** usar o ficheiro só como material de entrada (requisitos/jornadas misturados, contexto, links); classificar para o template; o output da gravação vai para `docs/tarefas/` como documento de tarefa novo.

Se o path não existir ou não for legível → reportar e pedir path válido ou texto livre (uma mensagem).

## Primeiro turno (sem ficheiro nem texto)

Se a invocação **não** trouxer ficheiro nem bloco de requisitos/jornadas (ex.: só `/escrever-tarefa`), responder **uma vez** pedindo que o utilizador **cole texto livre** ou indique um **caminho de ficheiro** (referência ou `docs/tarefas/…` para continuar). **Não** começar por pergunta de título antes desse input.

## Interpretação do texto livre

- **Ordem livre** — não há roteiro fixo título → UC → RF.
- Classificar cada trecho:
  - **Projeto:** produto, app ou sistema de negócio envolvido (entra em **Projetos envolvidos** — nome identificável para stakeholders, não path de repo).
  - **UC (jornada):** ator, objetivo, fluxo que a persona percorre.
  - **Tela:** ecrã ou vista com nome de negócio, propósito, campos/informação mostrada, ações disponíveis e transições (entra em **Telas** ou, se for só um passo de um UC, pode ficar na prosa do UC — não duplicar sem necessidade).
  - **RF (requisito):** requisito funcional, regra de negócio, validação ou comportamento verificável do **sistema** em linguagem de negócio (não narrativa de jornada).
- Mostrar rascunho da distribuição quando útil; **uma pergunta de cada vez** (grill-me) em lacuna, **ambiguidade** ou conflito — priorizar o que bloquearia implementação.
- **UC:** `## UCn Nome curto` + **1–3 frases** (pré-condição, fluxo principal, resultado) + **diagrama Mermaid** essencial (obrigatório em cada UC).
- **RF:** bullet `- RF n — …` — **uma** regra ou comportamento por item; verificável (dado X, o sistema faz Y); sem termos de implementação.
- **Tela:** `### Tela: Nome` — propósito em **1 frase**; bullets só para conteúdo, ações e regras **distintas** (sem repetir o UC inteiro).

## Idioma

Todo o **ficheiro gerado** em **pt-BR** (título, resumo, projetos envolvidos, UCs, RFs). O chat pode ser noutro idioma; o artefacto não.

## Encerrar o documento (antes de gravar)

**Sempre** confirmar **projetos envolvidos** com o utilizador **antes** de considerar o documento fechado ou sugerir gravação — mesmo que o texto livre ou a referência já nomeiem repositórios.

1. Resumir no chat a lista actual (ou “ainda não definida”).
2. Fazer **uma pergunta** (grill-me): quais produtos/apps/sistemas de negócio estão no âmbito; incluir recomendação se o contexto sugerir candidatos (nomes para stakeholders, não paths).
3. **Revisão de prontidão para dev** (mental ou em 2–3 bullets no chat): cada RF é testável? UCs e telas batem certo? Sobrou termo vago ou decisão em aberto? Se sim → **uma** pergunta grill para fechar.
4. Só depois de projetos confirmados e **sem ambiguidades abertas** encerrar a entrevista ou pedir confirmação para gravar.

Se o utilizador pedir gravar sem ter respondido a esta pergunta → fazer a pergunta **nesse turno** (não assumir lista por defeito).

## Artefacto: caminho e nome

- **Pasta (novo documento):** `docs/tarefas/` no workspace actual (criar se não existir).
- **Nome (novo):** `YYYY-MM-DD-HHmmss-<slug>.md`
  - `<slug>`: derivado do título — minúsculas, hífens, sem acentos/espaços; padrão `^[a-z0-9]+(-[a-z0-9]+)*$`.
  - Timestamp: momento da **primeira** gravação desse documento novo.
- **Continuar tarefa:** manter o path indicado; não renomear por defeito.

## Quando gravar

Gravar **quando**:

1. O utilizador pedir explicitamente (ex.: “salva”, “gera o ficheiro”, “grava”, “pode escrever”); ou
2. A entrevista estiver encerrada por acordo e o utilizador confirmar que pode gravar.

**Até lá:** trabalhar no chat; **não** criar ficheiro novo por iniciativa própria (modo **referência**). Modo **continuar tarefa** pode usar o ficheiro existente só após pedido ou confirmação de gravação.

### Rascunho incompleto

Se o utilizador pedir gravar **antes** de ter título, resumo, **projetos envolvidos confirmados**, UCs, telas (quando a tarefa tiver interface) ou RFs suficientes: **avisar** o que falta em lista curta e **gravar mesmo assim** (não bloquear), excepto **projetos envolvidos** — se ainda não houve pergunta/resposta sobre isso, **perguntar primeiro** (ver secção anterior); só gravar depois da resposta ou se o utilizador insistir na mesma mensagem após o aviso.

Secções em falta podem ficar com placeholder mínimo (`_A preencher._`) ou omitidas se o utilizador preferir na mesma mensagem. **Projetos envolvidos** vazio sem confirmação explícita de “nenhum” → usar placeholder `- _A confirmar com o utilizador._`

## Formato obrigatório do documento

Usar **exatamente** esta estrutura (substituir conteúdo; manter headings):

```markdown
# Título
Resumo da atividade

# Projetos envolvidos

- nome-do-repositorio-ou-app
- outro-projeto-se-aplicavel

# Casos de uso
Lista dos casos de uso
## UC1 nome do caso de uso
conteúdo do caso de uso em prosa...

```mermaid
flowchart TD
  A[Ator] --> B[Passo]
  B --> C[Resultado]
```

## UC2 nome do caso de uso
conteúdo do caso de uso em prosa...

```mermaid
sequenceDiagram
  participant A as Ator
  participant S as Sistema
  A->>S: ação
  S-->>A: resposta
```

# Telas

### Tela: Nome da tela
Propósito em uma ou duas frases.

- **Conteúdo:** informação e campos visíveis ao utilizador
- **Ações:** o que o utilizador pode fazer
- **Regras visíveis:** validações, estados, mensagens (linguagem de negócio)

(Omitir a secção `# Telas` inteira se a tarefa não envolver interface — ex.: integração ou batch.)

# Requisitos

- RF 1 — …
- RF 2 — …
- RF 3 — …
```

- `# Título` — linha seguinte é o resumo: **2–4 frases** no máximo (objectivo, âmbito, resultado esperado); não outro heading.
- `# Projetos envolvidos` — lista com bullets (`- …`); um item por produto/app/sistema de negócio; nome que stakeholders reconheçam. Lista vazia só com confirmação explícita do utilizador de que não há outros projetos.
- Após `# Casos de uso`, **uma frase** de âmbito ou lista nominal dos UCs (sem parágrafo).
- **Cada `## UCn`:** prosa + bloco ` ```mermaid ` imediatamente a seguir (um diagrama por UC, sem excepção).
  - Preferir `flowchart` para jornadas/passos; `sequenceDiagram` quando o foco for troca ator↔sistema.
  - Rótulos em pt-BR; incluir ator, passos principais e resultado ou estado final; nomes de **telas** ou **funcionalidades**, nunca de classes ou ficheiros.
  - Ao **continuar tarefa**, UC sem diagrama → acrescentar; UC com diagrama desactualizado → actualizar em conjunto com a prosa.
- RFs: lista com `- RF n — …` (número sequencial a partir de 1); ordenar por dependência lógica quando ajudar o dev.
- Renumerar UC/RF de forma contínua ao fundir ou remover itens.
- **Duplicação:** se um facto está no UC, não repetir no RF salvo se for critério de aceite isolado; telas não repetem a prosa do UC — só o que é específico da vista.

## Proibido

- Mencionar ou delegar a qualquer skill que não seja **grill-me**.
- Implementar código, migrações ou testes neste fluxo.
- No **documento gravado**: código, pseudocódigo, nomes de classes/métodos, paths, SQL, endpoints técnicos, detalhes de stack, estimativas de esforço, **texto prolixo**, **ambiguidade** (“talvez”, “ou similar”, “TBD” sem placeholder acordado).
- Gravar fora do artefacto acordado (`docs/tarefas/…` novo ou ficheiro em continuação) sem pedido explícito do utilizador.

## Exemplos de invocação

```
/escrever-tarefa
/escrever-tarefa <texto livre>
/escrever-tarefa docs/tarefas/2026-05-26-143052-exportar-relatorio.md
/escrever-tarefa docs/referencias/briefing-stakeholder.md
```

Com ficheiro ou texto na mesma mensagem: ler/interpretar de imediato; primeira resposta grill = síntese do que entrou + **uma** pergunta (não repetir o pedido de colar bloco).
