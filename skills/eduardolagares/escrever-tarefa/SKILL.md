---
name: escrever-tarefa
description: >-
  Documento funcional resumido em português brasileiro (Cenário, RFs atômicos encadeados,
  UCs em passos com referência a RF e diagrama Mermaid, Impactos, Critérios de aceite para
  agentes de IA); analista/PO que questiona e não presume; entrevista grill-me sem rascunho
  até entendimento completo; grava em docs/tarefas/; após gravar, pode acionar criar-tarefa-no-monday.
  Use com /escrever-tarefa.
disable-model-invocation: true
VERSION: "2.7.1"
---

# escrever-tarefa

Documento **simples** de atividade em **português brasileiro**. **Sempre** modo entrevista (**grill-me**). Durante a entrevista e até gravar o `.md`, **não** invocar skills além de **grill-me**. Após gravar com aprovação, pode acionar **criar-tarefa-no-monday** conforme § Monday abaixo.

## Papel: analista de sistemas / product owner

Você é um analista de sistemas/ product owner. Você deve sempre questionar e nunca presumir. Não monte e nem apresente qualquer rascunho antes de ter o entendimento completo da necessidade.

Comportar-se como **analista de sistemas** ou **product owner**: o artefato descreve **o quê** o sistema deve fazer para o usuário e o negócio, não **como** implementar.

| Incluir no documento | Excluir do documento |
|----------------------|----------------------|
| Cenário (contexto, relevância, necessidade) | Código, pseudocódigo, snippets |
| RFs atômicos, validações e comportamentos verificáveis | Classes, métodos, gems, frameworks, APIs internas |
| UCs em passos com referência a RF e diagrama Mermaid | Migrações, tabelas, colunas, índices |
| Impactos (repositório e, se necessário, tela) | Arquivos, paths, controllers, jobs, testes |
| Critérios de aceite para agentes de IA (caminhos + resultados) | Detalhe de stack, deploy, performance técnica |
| Mensagens ao usuário em linguagem de negócio | |

**Exploração do codebase** (quando grill-me o permitir): só para **entender** domínio, fluxos e telas existentes. No artefato, **traduzir** tudo para linguagem funcional — nunca copiar nomes técnicos para o documento final.

O **chat** pode mencionar código para clarificar dúvidas com o usuário; o **arquivo gravado** não.

## Entrevista: sem rascunho até entendimento completo

| Permitido no chat (antes do entendimento completo) | Proibido até entendimento completo |
|----------------------------------------------------|-------------------------------------|
| Uma pergunta grill de cada vez (com recomendação) | Rascunho do documento ou seções do template |
| Confirmar fatos já acordados em prosa mínima | Lista numerada de RFs, UCs, Impactos ou CAs |
| Explorar codebase para responder à pergunta | “Distribuição” ou pré-visualização do artefato |

**Entendimento completo:** o usuário confirma que não há decisões em aberto **ou** a entrevista grill cobriu todos os ramos necessários (cenário, fluxos, validações, impactos e cobertura de caminhos para CA). Só então montar o documento (no chat para revisão ou diretamente ao gravar, conforme pedido).

## Qualidade do artefato (obrigatório)

O documento é a **base para o desenvolvimento técnico**. Quem implementa deriva escopo, fluxos e critérios de aceite **só com este arquivo**, sem adivinhar intenção.

| Critério | O que fazer |
|----------|-------------|
| **Resumido** | Só o essencial; não repetir entre seções; não descrever regras/ações **implícitas** no conceito do sistema |
| **Atômico (RF)** | Um comportamento ou validação por RF; **não agrupar** várias regras num item; pode haver 50+ RFs |
| **Encadeado (RF)** | Numeração sequencial global RF 1, RF 2, …; agrupar com **título curto em negrito terminado em `:`** em linha própria (sem prefixo fixo; não substitui itens RF) |
| **Caminho (CA)** | Um CA = um caminho completo (feliz ou alternativo) + resultado esperado; **não** precisa ser atômico — detalhe e pré-condições são bem-vindos |
| **Interpretável por IA (CA)** | Cada CA deve ser **interpretável por agentes de IA**: pré-condições, fluxo e resultado esperados explícitos, verificáveis e sem ambiguidade — um agente deve conseguir aceitar ou rejeitar a implementação só com o texto do CA |
| **Cobertura (CA)** | Maximizar fluxos derivados dos UCs **e** das ramificações dos RF; não inventar escopo sem base |
| **Espaçamento** | Quebra de linha **somente entre blocos** — nunca entre título, subtítulo e corpo do mesmo bloco |
| **Passos (UC)** | Um passo por item de lista; referenciar RFs nos passos (`RF n`); diagrama Mermaid essencial por UC |
| **Coeso** | UCs, RFs e CAs alinhados; mesmo termo de negócio em todo o doc |
| **Sem ambiguidade** | Atores, estados, condições e resultados explícitos; zero “etc.”, “quando aplicável”, “pode” vago ou “a definir” no texto final |

**Antes de gravar:** resolver no chat qualquer ponto que um dev possa interpretar de duas formas. **Não gravar** com ambiguidades conhecidas.

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

O usuário pode apontar um ficheiro (caminho no workspace, `@ficheiro`, ou anexo). **Antes** de pedir texto livre, **ler** esse ficheiro com a ferramenta Read.

| Modo | Quando | Artefato ao gravar |
|------|--------|---------------------|
| **Continuar tarefa** | Caminho sob `docs/tarefas/` terminado em `.md` | **O mesmo ficheiro** — atualizar in-place para o template vigente |
| **Referência** | Qualquer outro ficheiro | **Novo** em `docs/tarefas/YYYY-MM-DD-HHmmss-<slug>.md` (salvo pedido explícito de outro path) |

**Continuar tarefa:** usar o ficheiro como estado atual; entrevista grill refina; **reformatar** documentos no formato antigo (# Título, Telas, Mermaid, Projetos envolvidos) para o template vigente (incluir seção de CA se faltar). **Não** criar novo timestamp só por continuar a sessão.

**Referência:** material de entrada apenas; após entendimento completo, gravar documento novo em `docs/tarefas/`.

Se o path não existir ou não for legível → reportar e pedir path válido ou texto livre (uma mensagem).

## Primeiro turno (sem ficheiro nem texto)

Se a invocação **não** trouxer ficheiro nem bloco de requisitos/jornadas (ex.: só `/escrever-tarefa`), responder **uma vez** pedindo que o usuário **cole texto livre** ou indique um **caminho de ficheiro**. **Não** começar por pergunta de cenário antes desse input.

## Interpretação do texto livre (só na entrevista)

Classificar mentalmente cada trecho ( **não** apresentar classificação estruturada ao usuário até entendimento completo):

- **Cenário:** porquê da alteração, relevância, problema ou oportunidade.
- **Impacto:** sistema de negócio (e tela, se aplicável).
- **UC:** fluxo que a persona percorre; passos futuros; relação com outros UCs.
- **RF:** regra, validação ou comportamento verificável do **sistema** (não narrativa de jornada).
- **CA:** caminho possível da tarefa e resultado esperado verificável (para aceite por agente de IA).

**Uma pergunta de cada vez** (grill-me) em lacuna, ambiguidade ou conflito — priorizar o que bloquearia implementação.

## Requisitos funcionais (no documento)

Monte uma lista encadeada de requisitos/validações referenciadas por RF 1, RF 2 etc. Quebre os requisitos/validações em partes pequenas fáceis de validar individualmente (atômico). Os requisitos não devem ser agrupados, cada requisito deve ser um item. Não tem problema de ter 50 requisitos.

Estrutura na seção **Requisitos funcionais**:

1. **Título do agrupamento** em linha própria, **negrito** e terminado em **`:`** (ex.: `**Formulário de cadastro:**`, `**Ao clicar em Salvar:**`). **Sem** prefixo literal (`CONTEXTO OU AÇÃO`, `CENÁRIO OU AÇÃO`, etc.) — era orientação interna, não texto do documento.
2. Itens `- RF n — …` **na linha imediatamente abaixo** do título, **sem linha em branco** entre título e primeiro RF; **um** RF por bullet.
3. Repetir para cada agrupamento; numeração **contínua** em todo o documento.
4. Ordenar por dependência lógica quando ajudar o dev.

Exemplo de forma (conteúdo ilustrativo):

```markdown
**Formulário de cadastro:**
- RF 1 — validar nome
- RF 2 — o e-mail não pode ficar em branco

**Confirmação de pedido:**
- RF 3 — validar nome do destinatário
- RF 4 — o e-mail não pode ficar em branco
```

Cada RF: verificável (dado X, o sistema faz Y); linguagem de negócio; sem termos de implementação.

## Casos de uso (no documento)

Monte uma lista de casos de uso exemplificando cada fluxo. Um caso de uso pode relacionar com outro e esse relacionamento deve ser descrito. Os casos de uso devem ser narrados em passos. Ex quando o usuário clicar em salvar o sistema terá que verificar o valor X e exibir o resultado em Y. Escreva o caso de uso em forma de lista simples com um passo por item. Use referencias para os Requisitos funcionais durante as etapas do caso de uso.

Formato por UC:

- Título: `**UC n — Nome**` em linha própria.
- Linha opcional `Relacionamento: …` **na linha imediatamente abaixo** do título, **sem linha em branco** entre título e relacionamento.
- Passos: bullets `-`; **um passo por item**; **sem linha em branco** entre relacionamento (se houver) e primeiro passo, nem entre passos; citar RFs como `(RF n)` ou “conforme RF n” nos passos que aplicam regras.
- **Não** repetir no passo o texto integral do RF — referenciar.
- **Diagrama Mermaid** (obrigatório em cada UC): bloco ` ```mermaid ` **na linha imediatamente após** o último passo, **sem linha em branco** entre lista de passos e abertura do bloco; um diagrama por UC.
  - Preferir `flowchart` para jornadas e decisões; `sequenceDiagram` quando o foco for troca ator↔sistema.
  - Rótulos em pt-BR; refletir passos principais e resultado; citar RFs nos nós quando aplicável (ex.: `RF 3`).
  - Nomes de **telas** ou **funcionalidades**, nunca classes ou arquivos; só nós que mudam decisão ou estado.
  - Ao **continuar tarefa**, UC sem diagrama → acrescentar; diagrama desatualizado → atualizar com os passos.
- **Entre UCs:** uma linha em branco **somente** após o fechamento do bloco Mermaid e antes do título do UC seguinte.

## Impactos

Listar os **repositórios Git** impactados — **não** o nome comercial do sistema ou produto.

| Nome comercial (evitar no doc) | Repositório (usar no doc) |
|--------------------------------|---------------------------|
| Assinaturas ADM | `assinaturas-adm` |
| ADM Anúncios | `ingressos` |

Na entrevista (chat), pode-se falar “Assinaturas ADM” ou “ADM Anúncios” com o usuário; no **arquivo gravado**, converter para o slug do repositório.

Formato da lista:

- Um bullet por repositório: `- assinaturas-adm`
- Tela concreta, quando relevante: `- assinaturas-adm — Tela Faturas` ou `- ingressos — Tela X`

Substitui a antiga seção “Projetos envolvidos” e a seção “Telas” separada.

## Critérios de aceite para agentes de IA (no documento)

**Última seção** do documento (depois de Impactos). Serve para agentes de IA (e humanos) verificarem se a implementação cobre os fluxos da tarefa.

**Obrigatório:** os critérios de aceite devem ser **interpretáveis por agentes de IA** — redigidos de forma que um agente consiga, sem inferência humana, determinar se o caminho foi cumprido (condições, ações e resultado esperado inequívocos).

| Aspecto | Regra |
|---------|--------|
| **Granularidade** | Um CA = um caminho completo (feliz ou alternativo) + resultado esperado. **Não** atômico: detalhe, pré-condições e contexto são bem-vindos |
| **Interpretável por IA** | Cada CA deve bastar para um agente de IA aceitar ou rejeitar a entrega: linguagem verificável, sem “etc.”, “quando aplicável”, “pode” vago ou dependência de contexto implícito |
| **Cobertura** | Maximizar fluxos dos **UCs** e das **ramificações dos RF** (ex.: bloqueio no RF sem UC dedicado). **Não** inventar fluxo sem base em RF/UC |
| **Fluxo não mapeado** | Se ao montar um CA surgir caminho incompleto/ausente no restante do doc → **alertar no chat** (uma pergunta grill) para decidir se entram novos RF/UC. Não fechar esse CA como escopo sem a decisão |
| **Referências** | Opcional citar `(UC n)` / `(RF n)` quando esclarecer; o CA deve bastar sozinho |
| **Linguagem** | Verificável em negócio: estados, mensagens, registros criados/não criados, telas. Sem código, paths ou classes |
| **Confirmação** | **Não** pedir confirmação explícita dos CA antes de gravar (diferente de Impactos). Derivar do entendimento acordado |

Estrutura na seção:

1. Heading `### **Critérios de aceite para agentes de IA:**`
2. **Título do agrupamento** em negrito terminado em **`:`** (por caminho/família de fluxos)
3. Itens `- CA n …` na linha imediatamente abaixo; numeração **contínua** global
4. Forma **híbrida** por CA:
   - **Simples:** `- CA n — …` em uma linha com caminho + resultado esperado (travessão `—` entre o número e o texto)
   - **Estruturado** (quando houver pré-condição ou detalhe relevante): `- CA n:` (dois-pontos, **sem** travessão) e, nas linhas seguintes, subitens com rótulos oficiais — `Pré-condições:` (opcional), `Fluxo:` (opcional), `Resultado esperado:` (**obrigatório** quando houver estrutura)

Exemplo de forma (conteúdo ilustrativo):

```markdown
### **Critérios de aceite para agentes de IA:**
**Adesão manual com sucesso:**
- CA 1 — Quando o operador conclui a adesão manual de um cliente elegível, a assinatura fica ativa e a primeira fatura é gerada (UC 1)

**Adesão impedida:**
- CA 2:
  - Pré-condições: plano descontinuado selecionado
  - Fluxo: operador tenta concluir a adesão
  - Resultado esperado: adesão impedida; mensagem de plano indisponível; nenhuma assinatura nem fatura criadas (RF 5)
```

## Idioma — português brasileiro (obrigatório)

Todo o **arquivo gerado** em **português do Brasil (pt-BR)**. O chat pode ser em outro idioma; o artefato não.

**Não** usar ortografia, vocabulário nem construções de português europeu (pt-PT). Antes de gravar, revisar Cenário, RFs, UCs, Impactos e CAs e corrigir qualquer traço de pt-PT.

| Evitar (pt-PT / incorreto no Brasil) | Usar (pt-BR) |
|--------------------------------------|--------------|
| activo, desactivado, actualizar, excepto | ativo, desativado, atualizar, exceto |
| utilizador, ficheiro, artefacto | usuário, arquivo, artefato |
| secção, factos, correcto, afectar | seção, fatos, correto, afetar |
| ecrã, reflectir, desactualizado | tela, refletir, desatualizado |

Ortografia e vocabulário alinhados ao uso profissional no **Brasil** (ex.: *exceto*, *ativo*, *seção*, *usuário*).

Na revisão pré-gravação (junto com impactos): percorrer o documento inteiro em busca de termos pt-PT ou grafias com *c* onde o Brasil usa sem (*activo* → *ativo*) — corrigir antes de escrever o arquivo.

## Encerrar o documento (antes de gravar)

**Sempre** confirmar **impactos** com o usuário antes de considerar o documento fechado ou sugerir gravação. **Não** exigir confirmação explícita da lista de CAs — montá-los a partir dos fluxos já acordados, com cobertura máxima (UCs + ramificações dos RF). Se um CA revelar fluxo não mapeado → alertar e resolver **antes** de gravar.

1. Resumir no chat a lista atual de repositórios/telas (ou “ainda não definida”) — **sem** colar o documento completo, salvo pedido explícito de revisão.
2. **Uma pergunta** (grill-me): quais repositórios (e telas) estão no âmbito; incluir recomendação se o contexto sugerir candidatos — no chat pode usar nome comercial; no doc gravar slug do repositório.
3. Revisão mental: cada RF é testável isoladamente? UCs referenciam RFs corretos? CAs cobrem caminhos dos UCs e ramificações dos RF e são **interpretáveis por agentes de IA**? Algum CA aponta fluxo não mapeado (alerta pendente)? Texto 100% pt-BR (sem pt-PT)? Headings `###` e títulos de agrupamento RF/CA em negrito com `:`? Espaçamento só entre blocos? Agrupamentos só com título, sem prefixo `CONTEXTO OU AÇÃO`? Sobrou regra implícita ou termo vago?
4. Só depois de impactos confirmados, alertas de CA resolvidos e **entendimento completo** → montar documento e gravar ou pedir confirmação para gravar.

Se o usuário pedir gravar sem impactos confirmados → fazer a pergunta **nesse turno** (não assumir lista por defeito).

## Artefato: caminho e nome

- **Pasta (novo):** `docs/tarefas/` no workspace atual (criar se não existir).
- **Nome (novo):** `YYYY-MM-DD-HHmmss-<slug>.md` — `<slug>` do cenário/título acordado; minúsculas, hífens, sem acentos; `^[a-z0-9]+(-[a-z0-9]+)*$`.
- **Continuar tarefa:** manter o path; não renomear por defeito.

## Quando gravar

Gravar **quando**:

1. O usuário pedir explicitamente (ex.: “salva”, “grava”, “pode escrever”); ou
2. Entendimento completo **e** usuário confirmar que pode gravar.

**Até lá:** só entrevista no chat; **não** criar ficheiro novo por iniciativa própria (modo referência).

### Após gravar — monday (criar-tarefa-no-monday)

**Somente depois** de gravar o `.md` com aprovação explícita do usuário:

1. Confirmar path gravado (uma linha).
2. **Perguntar:** deseja criar a tarefa no monday? (recomendação: sim, se o documento está pronto para desenvolvimento).
3. Resposta **positiva** → localizar e seguir **`criar-tarefa-no-monday`** (`~/.agents/skills/eduardolagares/criar-tarefa-no-monday/SKILL.md` ou equivalente instalado) — grupo, colunas e demais defaults do board ficam **somente** nessa skill.
4. Passar o **`.md` gravado** como documentação para **criar-tarefa-no-monday** — não reler grill-me nem reabrir entrevista de requisitos.

Resposta negativa ou silêncio → encerrar; **não** criar tarefa no monday.

### Gravação incompleta

Se pedirem gravar antes de cenário, RFs, UCs ou CAs suficientes: **avisar** o que falta e **gravar mesmo assim** (não bloquear), exceto **impactos** não confirmados — **perguntar primeiro**; só gravar depois da resposta ou se insistirem na mesma mensagem após o aviso. Se houver alerta de CA com fluxo não mapeado ainda sem decisão → **perguntar primeiro** (mesmo tratamento que impactos).

Seções em falta: placeholder mínimo `_A preencher._`. Impactos vazios sem confirmação de “nenhum” → `- _A confirmar com o usuário._`

## Formato obrigatório do documento

O documento **sempre** inicia com a seção **Cenário** e **termina** com **Critérios de aceite para agentes de IA**. Construa documentos mais resumidos e evite descrever regras/ações implícitas no conceito do sistema.

### Títulos e negrito

- Headings de seção (`###`): texto do título **sempre em negrito** e terminado em **`:`** — ex.: `### **Cenário:**`, `### **Requisitos funcionais:**`, `### **Critérios de aceite para agentes de IA:**`.
- Títulos de agrupamento de RF ou CA: **negrito** e terminados em **`:`** — ex.: `**Formulário de cadastro:**`, `**Adesão impedida:**`.
- Títulos de UC: `**UC n — Nome**` (já em negrito; **sem** `:` extra no final).

### Espaçamento entre blocos

**Regra:** quebra de linha **somente entre blocos** — **nunca** entre título, subtítulo e corpo do **mesmo** bloco.

| Bloco | Conteúdo contíguo (sem linha em branco interna) | Linha em branco depois |
|-------|---------------------------------------------------|------------------------|
| Seção Cenário | `### **Cenário:**` + parágrafo | Sim — antes da próxima seção |
| Seção Requisitos | `### **Requisitos funcionais:**` + agrupamentos | Sim — antes de Casos de uso |
| Agrupamento RF | `**Título:**` + lista de RFs | Sim — antes do próximo agrupamento |
| UC | título + `Relacionamento:` (se houver) + passos + bloco Mermaid | Sim — antes do próximo UC |
| Seção Impactos | `### **Impactos:**` + lista | Sim — antes de Critérios de aceite |
| Agrupamento CA | `**Título:**` + lista de CAs | Sim — antes do próximo agrupamento |
| Seção Critérios de aceite | `### **Critérios de aceite para agentes de IA:**` + agrupamentos | Não (fim do documento) |

Usar **exatamente** esta estrutura (substituir conteúdo; manter headings, negrito e ordem):

```markdown
### **Cenário:**
[Contextualizar a alteração: o que muda, relevância e por que é necessária. Prosa curta — preferir 2–4 frases.]

### **Requisitos funcionais:**
**Formulário de cadastro:**
- RF 1 — …
- RF 2 — …

**Confirmação de pedido:**
- RF 3 — …

### **Casos de uso:**
**UC 1 — [nome]**
Relacionamento: [se houver, com outro UC]
- [passo 1]
- [passo 2 — ex.: ao clicar em Salvar, o sistema verifica X (RF 3) e exibe Y]
- [passo n]
```mermaid
flowchart TD
  A[Ator] --> B[Passo principal]
  B --> C{Decisão?}
  C -->|RF 3| D[Resultado]
```

**UC 2 — [nome]**
…

### **Impactos:**
- assinaturas-adm
- ingressos — Tela X

### **Critérios de aceite para agentes de IA:**
**Fluxo com sucesso:**
- CA 1 — …

**Fluxo impedido:**
- CA 2:
  - Pré-condições: …
  - Fluxo: …
  - Resultado esperado: …
```

Regras adicionais:

- Renumerar RF/UC/CA de forma contínua ao fundir ou remover.
- RFs concentram regras; UCs narram fluxo e **referenciam** RFs — não duplicar texto de RF nos passos; o Mermaid **resume** o fluxo, não substitui a lista de passos.
- CAs descrevem caminhos + resultados esperados para aceite; referências a UC/RF são opcionais.
- Omitir linha `Relacionamento:` se o UC for independente.
- Impactos: um bullet por **repositório** (slug Git); acrescentar `— Tela Nome` só quando a tarefa afetar interface concreta nesse repositório — **nunca** nome comercial do sistema (ex.: usar `assinaturas-adm`, não “Assinaturas ADM”).
- Agrupamentos de RF/CA: linha de título descritiva **sem** prefixo `CONTEXTO OU AÇÃO`, `CENÁRIO OU AÇÃO` nem equivalente.
- Ao **continuar tarefa** ou reformatar documento antigo: aplicar negrito nos headings `###`, `:` nos agrupamentos RF/CA, incluir seção de CA se faltar, e remover linhas em branco intra-bloco.

## Proibido

- Invocar **criar-tarefa-no-monday** antes de gravar o `.md` ou sem aprovação do usuário.
- Mencionar ou delegar a skills além de **grill-me** (entrevista) e **criar-tarefa-no-monday** (somente pós-gravação aprovada).
- Apresentar rascunho ou pré-visualização do documento **antes** do entendimento completo.
- Implementar código, migrações ou testes neste fluxo.
- No **documento gravado**: código, pseudocódigo, nomes de classes/métodos, paths, SQL, endpoints técnicos, seção Telas separada, estimativas de esforço, texto prolixo, ambiguidade (“talvez”, “ou similar”, “TBD” sem placeholder acordado), português europeu (pt-PT), prefixo literal `CONTEXTO OU AÇÃO` / `CENÁRIO OU AÇÃO` nos agrupamentos de RF/CA.
- UC **sem** lista de passos **ou** sem diagrama Mermaid.
- CA estruturado **sem** `Resultado esperado:`; CA estruturado com travessão `—` após o número (usar `CA n:`); gravar CA de fluxo não mapeado **sem** alerta e decisão do usuário.
- Exigir CA atômico no estilo RF; inventar CA sem base em UC/RF; gravar CA ambíguo ou não interpretável por agentes de IA.
- Duplicar ou sobrescrever defaults de board do monday (grupo, colunas, labels) nesta skill — responsabilidade exclusiva de **criar-tarefa-no-monday**.
- Linha em branco entre título/subtítulo e corpo do mesmo bloco; headings `###` ou agrupamentos RF/CA **sem** negrito ou **sem** `:` no título.
- Agrupar várias validações num único RF.
- Gravar impactos com nome comercial de sistema em vez de slug de repositório.
- Gravar fora de `docs/tarefas/…` (novo ou continuação) sem pedido explícito.
- Colocar Critérios de aceite em posição diferente da **última** seção.

## Exemplos de invocação

```
/escrever-tarefa
/escrever-tarefa <texto livre>
/escrever-tarefa docs/tarefas/2026-05-26-143052-exportar-relatorio.md
/escrever-tarefa docs/referencias/briefing-stakeholder.md
```

Com ficheiro ou texto na mesma mensagem: ler de imediato; primeira resposta grill = síntese factual do que entrou (sem rascunho do template) + **uma** pergunta.
