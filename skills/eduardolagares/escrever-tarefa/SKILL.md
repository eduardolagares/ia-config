---
name: escrever-tarefa
description: >-
  Documento funcional resumido em português brasileiro (Cenário, RFs do que muda,
  UCs em passos com referência a RF e diagrama Mermaid, Impactos, Critérios de aceite para
  agentes de IA); analista/PO que questiona e não presume; entrevista grill-me sem rascunho
  até entendimento completo; o DERS descreve o delta e referencia o comportamento atual
  pelo nome; grava em docs/tarefas/; após gravar, pode acionar criar-tarefa-no-monday.
  Use com /escrever-tarefa.
disable-model-invocation: true
VERSION: "2.9.0"
---

# escrever-tarefa

Documento **simples** de atividade em **português brasileiro**. **Sempre** modo entrevista (**grill-me**). Durante a entrevista e até gravar o `.md`, **não** invocar skills além de **grill-me**. Após gravar com aprovação, pode acionar **criar-tarefa-no-monday** conforme § Monday abaixo.

## Papel: analista de sistemas / product owner

Você é um analista de sistemas/ product owner. Você deve sempre questionar e nunca presumir. Não monte e nem apresente qualquer rascunho antes de ter o entendimento completo da necessidade. **Não inferir** intenção: se o texto do usuário (ou o recorte já acordado) admite duas regras, **perguntar**.

Comportar-se como **analista de sistemas** ou **product owner**: o artefato descreve **o quê** o sistema deve fazer para o usuário e o negócio, não **como** implementar.

| Incluir no documento | Excluir do documento |
|----------------------|----------------------|
| Cenário (contexto, relevância, necessidade; `sequenceDiagram` só no gate § Cenário) | Código, pseudocódigo, snippets |
| RFs atômicos, validações e comportamentos verificáveis | Classes, métodos, gems, frameworks, APIs internas, rotas, controllers, jobs, endpoints |
| UCs em passos com referência a RF e diagrama Mermaid | Migrações, tabelas, colunas, índices, factories, nomes de arquivo |
| Impactos (repositório e, se necessário, tela) | Arquivos, paths, testes |
| Critérios de aceite para agentes de IA (caminhos + resultados) | Detalhe de stack, deploy, performance técnica |
| Mensagens ao usuário em linguagem de negócio | |

**Exploração do codebase** (quando grill-me o permitir): só para **entender** domínio, fluxos e telas existentes e separar o que já está em produção do que esta tarefa muda. No artefato, **traduzir** prosa, RFs, UCs e CAs para linguagem funcional. Exceção estreita: se o gate do § Cenário autorizar `sequenceDiagram`, aí classe/método/chamada podem aparecer **só** nesse bloco.

O **chat** pode mencionar código para clarificar dúvidas com o usuário; o **arquivo gravado** não.

## Documento orientado ao delta

O documento descreve **o que muda**. Regra que já existe e não muda vira referência normativa. Não é reescrita.

**Referência válida:** fluxo ou regra nomeados em linguagem de negócio, com o que é reaproveitado e o que fica de fora. Ex.: "segue a compra de jogos até a vitrine, sem a janela de vendas". Quem implementa ou aceita consulta esse fluxo no sistema. O documento não transcreve condições, campos, mensagens nem estados dessa base.

**Referência inválida:** "segue o padrão atual", "como hoje" ou "o de sempre", sem dizer qual fluxo. Também é inválido reaproveitar a base e, no mesmo recorte, criar exceção, precedência ou resultado novo sem escrevê-los.

**Escrever por completo** (estados, recusa, mensagem, o que entra ou sai) somente quando a regra é nova, alterada, ou quando duas regras podem valer no mesmo objeto e a precedência ainda não está na base.

**Uma vez:** permissão, flag ou condição transversal que a tarefa introduz entra num RF. UC e CA citam esse RF. Não repetem a condição em cada item.

Reaproveitar caminho existente:
- Ruim: um RF por etapa já existente, com mensagem e campo de cada uma.
- Bom: um RF de preservação — a compra segue a compra de jogos nessas etapas; o comportamento atual é mantido. Outro RF para o que muda — a janela de vendas do jogo não é exigida.

Permissão transversal:
- Ruim: cada RF, UC e CA repete "com a permissão habilitada".
- Bom: um RF — a ação só ocorre com a permissão habilitada. Os demais itens citam esse RF.

## Entrevista: sem rascunho até entendimento completo

| Permitido no chat (antes do entendimento completo) | Proibido até entendimento completo |
|----------------------------------------------------|-------------------------------------|
| Uma pergunta grill de cada vez (com recomendação) | Rascunho do documento ou seções do template |
| Confirmar fatos já acordados em prosa mínima | Lista numerada de RFs, UCs, Impactos ou CAs |
| Explorar codebase para responder à pergunta | “Distribuição” ou pré-visualização do artefato |

**Entendimento completo:** o usuário confirma que não há decisões em aberto **ou** a entrevista grill cobriu todos os ramos necessários (as cinco perguntas do § Cenário, fluxos, validações, impactos, cobertura de caminhos visíveis para CA e o gate de aceite). Só então montar o documento (no chat para revisão ou diretamente ao gravar, conforme pedido).

**Gatilhos grill (uma pergunta; priorizar o que bloquearia implementação):**

- Qualquer uma das cinco perguntas do § Cenário sem resposta inequívoca no que já foi acordado.
- Duas regras que podem valer no **mesmo objeto** (ex.: situação do ingresso e marcação de utilizado) — perguntar **qual vence em cada transição**; não escrever “qualquer mudança” / “sempre” se o comportamento atual diferencia destinos.
- Antes de perguntar o miolo de uma regra, identificar se ela já existe. Se existir e não mudar, não entrevistar os ramos internos: nomear o fluxo e seguir para o que muda.
- Recorte toca regra **já existente**: vai mudar? **Não** → um RF de preservação, “o comportamento atual é mantido”, com o fluxo nomeado; **não** reescrever tabela, mapa, campos, mensagens nem estados. **Sim** → escrever a regra nova por completo (estados, recusa, mensagem).
- Recusa / bloqueio **novo ou alterado**: qual mensagem e o que **não** muda (registro, estado). Recusa que já existe e não muda fica na referência; não pedir a mensagem de novo.
- Tarefa **não** deve quebrar um fluxo existente visível no recorte → um CA de regressão que compare com a base nomeada. Não abrir UC por ramo interno dessa base.

## Qualidade do artefato (obrigatório)

O documento é a **base para o desenvolvimento técnico**, junto com as referências normativas que ele nomeia. Quem implementa deriva o que muda deste arquivo e consulta no sistema o fluxo nomeado. Não adivinha regra nova.

| Critério | O que fazer |
|----------|-------------|
| **Compreensão** | O texto (Cenário **ou** RF/UC) responde às cinco perguntas do § Cenário; **não inferir** o que falta |
| **Gate de aceite** | Antes de gravar, as duas perguntas da § Encerrar têm de ser **sim** (salvo insistência do usuário após o aviso) |
| **Caminho visível** | Toda ramificação **nova ou alterada** tem CA; todo UC tem CA; família de bloqueios inalterados pode ter um CA representativo |
| **Resumido** | Só o essencial; não reescrever regra existente; declarar condição transversal uma vez e citar o RF nas outras seções; não descrever regras/ações **implícitas** no conceito do sistema |
| **Atômico (RF)** | Decisão **nova ou alterada**: um comportamento por RF. Teste do “e”: dois resultados que são decisões independentes → dois RF. Consequências da mesma decisão podem ficar juntas. RF de preservação pode reunir várias etapas já existentes. Pode haver 50+ RFs quando o delta for grande |
| **Encadeado (RF)** | Numeração sequencial global RF 1, RF 2, …; agrupar com **título curto em negrito terminado em `:`** em linha própria (sem prefixo fixo; não substitui itens RF) |
| **Caminho (CA)** | Um CA = um caminho completo (feliz ou alternativo) + resultado esperado; **não** precisa ser atômico — detalhe e pré-condições são bem-vindos |
| **Interpretável por IA (CA)** | Caminho **novo ou alterado**: pré-condições, fluxo e resultado explícitos. Caminho **preservado**: o resultado pode ser a comparação com o fluxo nomeado (“a tela e a mensagem são as da compra de jogos”). Não completar o delta com Cenário, UC ou memória. Não exigir a transcrição da base |
| **Cobertura (CA)** | Caminhos dos UCs **e** ramificações **novas ou alteradas**; RF de recusa nova ou alterada tem CA de recusa; invariante e preservação podem estar embutidos noutro CA; um CA representativo cobre uma família de bloqueios inalterados; não abrir CA por ramo interno da base; não inventar escopo sem base |
| **Espaçamento** | Quebra de linha **somente entre blocos** — nunca entre título, subtítulo e corpo do mesmo bloco |
| **Passos (UC)** | Um passo por item de lista; referenciar o RF **certo** nos passos (`RF n`); diagrama Mermaid essencial por UC |
| **Coeso** | Mesmo vocabulário de negócio em Cenário, RF, UC e CA; **proibido contradizer** outro RF/UC/Cenário; **proibido duplicar** o mesmo requisito com outras palavras (fundir); UC não inventa regra fora dos RF nem ignora RF obrigatório do fluxo |
| **Sem ambiguidade** | Atores, estados, condições e resultados explícitos; zero “etc.”, “quando aplicável”, “pode” vago ou “a definir” no texto final; exceção tem **escopo** (“nas mudanças que não cancelam”), nunca “sempre” se outro RF reserva outro destino |

**Antes de gravar:** resolver no chat qualquer ponto **novo ou alterado** que um dev possa interpretar de duas formas. **Não gravar** com referência vaga, ambiguidade no delta, nem regra nova ou alterada não escrita. Referência válida não é buraco.

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

## Cenário (no documento)

Prosa curta (2–4 frases). O conjunto **Cenário + RF/UC** (não exige as duas para cada item) tem de responder, **sem inferir**:

1. Qual o **problema de negócio**?
2. Qual a **demanda** (o que muda)?
3. Qual o **objetivo final verificável**?
4. **Onde** isso ocorre (jornada ou formulário nomeados nos RF bastam; não exige nome comercial da tela no Cenário)?
5. O que o desenvolvedor deve **entregar sem adivinhar** — falha se um recorte **novo ou alterado** já colocado no RF/UC exige decisão de negócio não escrita (valor inicial, obrigatoriedade, recusa, estado, mensagem, critério de cálculo, o que entra ou sai). Referência válida a fluxo existente não é falha. Referência vaga é falha.

Ordem da prosa: problema → demanda → objetivo verificável. **Não** listar regras no Cenário. **Não** falar de stack. **Não** começar com “O que deve ser feito”, lista solta ou código.

Se qualquer uma das cinco estiver aberta na entrevista → **uma pergunta grill**; **não gravar**.

**Diagrama de sequência — default omitir.** Não colocar `sequenceDiagram` no Cenário nem em UC. O template **não** inclui esse bloco; não copiar o exemplo abaixo “por completar a seção”.

**Gate (as três têm de ser verdadeiras):** só então **um** `sequenceDiagram` no Cenário, **depois do parágrafo**, **sem linha em branco** entre a prosa e ` ```mermaid `.

1. **≥ 3 participantes distintos** que trocam mensagem (pessoa + pelo menos dois sistemas/papéis). User + uma tela **não** passa.
2. O miolo da mudança **é a ordem e o resultado** dessas mensagens (dois tempos, callback, parceiro no meio, sucesso vs falha no meio do caminho).
3. Um `flowchart` no UC **não** bastaria para o mesmo entendimento.

**Fora do gate (omitir):** CRUD, campo, texto, flag, filtro, listagem, tela isolada, um formulário sem chamada a outro papel, “só para ilustrar”. Em dúvida → omitir. **Nunca** `sequenceDiagram` em UC.

O diagrama, se existir, **resume** o Cenário; não substitui RFs nem UCs. Classe, método e participante técnico **só** nesse bloco (ex.: `RegistrationContainer`, `consultar(cpf:)`). Prosa, RFs, passos de UC e CAs continuam em linguagem de negócio.

Exemplo **somente** se o gate passou (não é o formato padrão do Cenário):

```mermaid
sequenceDiagram
  participant User
  participant Form as RegistrationContainer
  participant Auth as Auth2
  participant Bureau as AdaptadorCPF
  User->>Form: Digita CPF
  Form->>Auth: POST consulta CPF
  Auth->>Bureau: consultar(cpf:)
  alt Sucesso
    Bureau-->>Auth: nome, data_nascimento
    Auth-->>Form: dados
    Form->>Form: Preenche e trava o que veio
  else Falha
    Bureau-->>Auth: not_found / error
    Auth-->>Form: erro
    Form->>Form: Não avança
  end
```

## Requisitos funcionais (no documento)

Monte uma lista encadeada de requisitos/validações referenciadas por RF 1, RF 2 etc. Quebre os requisitos/validações em partes pequenas fáceis de validar individualmente (atômico). Os requisitos não devem ser agrupados, cada requisito deve ser um item. Não tem problema de ter 50 requisitos.

**Teste do “e”:** vale para decisões **novas ou alteradas**. Dois resultados visíveis que são decisões independentes (ex.: cancela os ativos **e** recusa o marcado como utilizado) → **dois RF**. Consequências da mesma decisão ficam juntas (ex.: não exigir a janela de vendas, não exibir a mensagem dessa janela e não usar a tela de jogo indisponível). Recusa nova ou alterada: mensagem no RF ou no CA estruturado.

**Comportamento atual:** se a regra existente **não muda**, um RF nomeia o fluxo e diz “o comportamento atual é mantido”. Pode reunir várias etapas já existentes. **Não** redefinir mapa, tabela, campos, mensagens nem estados. As regras mantidas não são escritas neste documento. Se **muda**, escrever a regra nova por completo.

**Conflito:** proibido contradizer outro RF, UC ou o Cenário. Proibido o mesmo requisito com outras palavras — fundir. Exceção com **escopo** explícito.

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

Monte casos de uso das jornadas **novas, alteradas ou de regressão essencial**. Agrupe ramos que terminam no mesmo resultado visível. Não recrie os caminhos internos do fluxo referenciado. Um caso de uso pode relacionar com outro e esse relacionamento deve ser descrito. Os casos de uso devem ser narrados em passos. Ex quando o usuário clicar em salvar o sistema terá que verificar o valor X e exibir o resultado em Y. Escreva o caso de uso em forma de lista simples com um passo por item. Use referencias para os Requisitos funcionais durante as etapas do caso de uso.

**UC não inventa** regra que não está nos RF. **UC não ignora** RF obrigatório do fluxo. O passo cita o **RF certo** daquela ramificação.

Formato por UC:

- Título: `**UC n — Nome**` em linha própria.
- Linha opcional `Relacionamento: …` **na linha imediatamente abaixo** do título, **sem linha em branco** entre título e relacionamento.
- Passos: bullets `-`; **um passo por item**; **sem linha em branco** entre relacionamento (se houver) e primeiro passo, nem entre passos; citar RFs como `(RF n)` ou “conforme RF n” nos passos que aplicam regras.
- **Não** repetir no passo o texto integral do RF — referenciar.
- **Diagrama Mermaid** (obrigatório em cada UC): bloco ` ```mermaid ` **na linha imediatamente após** o último passo, **sem linha em branco** entre lista de passos e abertura do bloco; um diagrama por UC.
  - **Sempre** `flowchart LR`. **Proibido** `sequenceDiagram` no UC (sequência, se o gate do § Cenário passar, fica **só** no Cenário).
  - `flowchart` **sempre** na horizontal: `flowchart LR`. **Nunca** `flowchart TD` — no Monday a imagem entra com largura fixa e diagrama vertical vira uma tira alta e ilegível, obrigando a converter depois.
  - Rótulos em pt-BR; refletir passos principais e resultado; citar RFs nos nós quando aplicável (ex.: `RF 3`).
  - Em `flowchart`: nomes de **telas** ou **funcionalidades**, nunca classes ou arquivos; só nós que mudam decisão ou estado.
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

**Obrigatório:** os critérios de aceite devem ser **interpretáveis por agentes de IA**. Caminho novo ou alterado: condições, ações e resultado inequívocos no próprio CA. Caminho preservado: a comparação com o fluxo nomeado no DERS é resultado verificável. **Não** completar o delta com memória solta, com o Cenário nem com o UC. **Não** transcrever a base para tornar o CA “autossuficiente”.

Caminho no escopo = ramificação **nova ou alterada** já escrita em RF ou UC que **muda o resultado visível** (exibe, some, exige, recusa, registra, estado, o que entra ou sai). Ramo interno de fluxo só referenciado não entra nesse escopo.

| Aspecto | Regra |
|---------|--------|
| **Granularidade** | Um CA = um caminho completo (feliz ou alternativo) + resultado esperado. **Não** atômico: detalhe, pré-condições e contexto são bem-vindos |
| **Interpretável por IA** | Caminho novo ou alterado: linguagem verificável, sem “etc.”, “quando aplicável”, “pode” vago ou dependência de contexto implícito. Caminho preservado: “igual ao fluxo nomeado” basta; “como hoje”, sem nome, não basta |
| **Cobertura** | **Todo UC** tem CA. Toda ramificação **nova ou alterada** tem **pelo menos um CA**. RF de **bloqueio/recusa novo ou alterado**: CA de recusa (mensagem + o que não muda); UC sozinho não basta. Família de bloqueios inalterados: um CA representativo. **Não** inventar fluxo sem base em RF/UC |
| **Invariante** | RF de definição, invariante ou “permanece como está” **não** exige CA próprio se o critério já estiver embutido num CA de caminho |
| **Comportamento atual** | Se o caminho não muda: o RF nomeia o fluxo e diz que o comportamento atual é mantido. O CA pode afirmar o resultado por comparação com esse fluxo, sem reescrever mapa, mensagem ou estado |
| **Fluxo não mapeado** | Se ao montar um CA surgir caminho incompleto/ausente no restante do doc → **alertar no chat** (uma pergunta grill) para decidir se entram novos RF/UC. Não fechar esse CA como escopo sem a decisão |
| **Referências** | Opcional citar `(UC n)` / `(RF n)` quando esclarecer; o CA deve bastar sozinho |
| **Linguagem** | Verificável em negócio: estados, mensagens, registros criados/não criados, telas. Sem código, paths, classes, rotas, jobs, tabelas, colunas, endpoints, factories ou nomes de arquivo |
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

**Bloqueio já existente, aplicado na jornada nova:**
- CA 3:
  - Pré-condições: cliente que a compra de jogos já impediria de abrir a vitrine
  - Fluxo: o cliente compra a experiência
  - Resultado esperado: a vitrine não abre e a autorização de compra não é registrada; a tela e a mensagem são as da compra de jogos
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

**Sempre** confirmar **impactos** com o usuário antes de considerar o documento fechado ou sugerir gravação. **Não** exigir confirmação explícita da lista de CAs — montá-los a partir dos fluxos já acordados, cobrindo UCs e ramificações **novas ou alteradas**, mais um CA representativo para a família de bloqueios inalterados. Se um CA revelar fluxo não mapeado → alertar e resolver **antes** de gravar.

1. Resumir no chat a lista atual de repositórios/telas (ou “ainda não definida”) — **sem** colar o documento completo, salvo pedido explícito de revisão.
2. **Uma pergunta** (grill-me): quais repositórios (e telas) estão no âmbito; incluir recomendação se o contexto sugerir candidatos — no chat pode usar nome comercial; no doc gravar slug do repositório.
3. Revisão mental — **gate de aceite** (as duas têm de ser **sim** antes de gravar):
   1. Dá para implementar o recorte **sem inventar regra nova ou alterada**, com este arquivo e as referências normativas nomeadas? (valor inicial, obrigatoriedade, recusa, estado, mensagem, critério de cálculo, o que entra ou sai — só do que muda)
   2. Dá para aceitar ou rejeitar **cada caminho novo ou alterado** com os CA e essas referências, sem inventar cenário? Caminho preservado pode ser aceito por comparação com o fluxo nomeado.
   - **Não** bloquear gravação só por: RF de preservação que agrupa etapas existentes; consequências da mesma decisão no mesmo RF; CA que compara com a base nomeada; objetivo repetido entre Cenário e CA quando o RF não é copiado inteiro; RF de jornada sem UC se o RF já descreve o comportamento **e** o CA cobre o resultado; “pode”; termo técnico isolado com efeito de negócio já escrito; invariante já embutido noutro CA.
   - Bloquear se a referência for vaga, se uma condição transversal for repetida em todo RF/UC/CA, ou se a base for reescrita.
   - Também: cada decisão nova é testável isoladamente? UCs citam o RF certo? Algum CA aponta fluxo novo não mapeado? Texto 100% pt-BR? Headings `###` e agrupamentos RF/CA em negrito com `:`? Espaçamento só entre blocos? Vocabulário único? Exceção nova com escopo? Sobrou regra nova implícita?
4. Só depois de impactos confirmados, gate de aceite **sim**, alertas de CA resolvidos e **entendimento completo** → montar documento e gravar ou pedir confirmação para gravar.

Se o usuário pedir gravar sem impactos confirmados **ou** com qualquer pergunta do gate em **não** → fazer a pergunta **nesse turno** (não assumir lista por defeito). Só gravar depois da resposta ou se insistirem na mesma mensagem após o aviso.

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
3. Resposta **positiva** → localizar e seguir **`criar-tarefa-no-monday`** (`~/.agents/skills/eduardolagares/criar-tarefa-no-monday/SKILL.md` ou equivalente instalado) — grupo, colunas e demais defaults do board ficam **somente** nessa skill. Esse **“sim” não autoriza MCP Monday**: a skill Monday exige entrevista de parâmetros + **“Posso criar no Monday exatamente com os parâmetros acima?”** antes de publicar.
4. Passar o **`.md` gravado** como documentação para **criar-tarefa-no-monday** — não reler grill-me nem reabrir entrevista de requisitos.

Resposta negativa ou silêncio → encerrar; **não** criar tarefa no monday.

### Gravação incompleta

Se pedirem gravar antes de cenário, RFs, UCs ou CAs suficientes: **avisar** o que falta e **gravar mesmo assim** (não bloquear), exceto **impactos** não confirmados, **gate de aceite** em não, ou alerta de CA com fluxo não mapeado ainda sem decisão — **perguntar primeiro**; só gravar depois da resposta ou se insistirem na mesma mensagem após o aviso.

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
| Seção Cenário | `### **Cenário:**` + parágrafo (+ `sequenceDiagram` **só** se o gate do § Cenário passar) | Sim — antes da próxima seção |
| Seção Requisitos | `### **Requisitos funcionais:**` + agrupamentos | Sim — antes de Casos de uso |
| Agrupamento RF | `**Título:**` + lista de RFs | Sim — antes do próximo agrupamento |
| UC | título + `Relacionamento:` (se houver) + passos + bloco Mermaid | Sim — antes do próximo UC |
| Seção Impactos | `### **Impactos:**` + lista | Sim — antes de Critérios de aceite |
| Agrupamento CA | `**Título:**` + lista de CAs | Sim — antes do próximo agrupamento |
| Seção Critérios de aceite | `### **Critérios de aceite para agentes de IA:**` + agrupamentos | Não (fim do documento) |

Usar **exatamente** esta estrutura (substituir conteúdo; manter headings, negrito e ordem):

```markdown
### **Cenário:**
[Contextualizar a alteração: problema, demanda e objetivo verificável. Prosa curta — preferir 2–4 frases.]
_(Não incluir `sequenceDiagram` aqui. Só acrescentar o bloco mermaid se o gate do § Cenário — ≥3 participantes, ordem/resultado das mensagens, flowchart do UC insuficiente — for verdadeiro.)_

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
flowchart LR
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
- Cenário: prosa. `sequenceDiagram` **só** se o gate do § Cenário passar (default omitir). UC: só `flowchart LR`.
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
- No **documento gravado**: código, pseudocódigo, paths, SQL, rotas, controllers, jobs, tabelas, colunas, endpoints, factories, nomes de arquivo, seção Telas separada, estimativas de esforço, texto prolixo, ambiguidade (“talvez”, “ou similar”, “TBD” sem placeholder acordado), português europeu (pt-PT), prefixo literal `CONTEXTO OU AÇÃO` / `CENÁRIO OU AÇÃO` nos agrupamentos de RF/CA. Nomes de classe/método **só** em `sequenceDiagram` — não na prosa, RFs, passos de UC nem CAs.
- UC **sem** lista de passos **ou** sem diagrama Mermaid; `sequenceDiagram` em UC; `flowchart TD` em UC.
- `sequenceDiagram` no Cenário **sem** as três condições do gate (§ Cenário); copiar o exemplo de sequência “por ter seção Cenário”.
- CA estruturado **sem** `Resultado esperado:`; CA estruturado com travessão `—` após o número (usar `CA n:`); gravar CA de fluxo não mapeado **sem** alerta e decisão do usuário.
- Exigir CA atômico no estilo RF; inventar CA sem base em UC/RF; gravar CA de caminho novo ou alterado ambíguo ou não interpretável por agentes de IA; gravar “como hoje” sem nomear o fluxo.
- Gravar com recorte que exige **regra nova ou alterada não escrita**; gravar UC ou ramificação **nova ou alterada** **sem CA** correspondente (exceto invariante já embutido noutro CA).
- Reescrever no documento regras cujo comportamento atual é mantido; repetir condição transversal em cada RF, UC e CA.
- Inferir qual regra vence quando duas se aplicam ao mesmo objeto; gravar “qualquer mudança” / “sempre” se outro RF reserva outro destino.
- Duplicar ou sobrescrever defaults de board do monday (grupo, colunas, labels) nesta skill — responsabilidade exclusiva de **criar-tarefa-no-monday**.
- Linha em branco entre título/subtítulo e corpo do mesmo bloco; headings `###` ou agrupamentos RF/CA **sem** negrito ou **sem** `:` no título.
- Agrupar várias validações **novas ou alteradas** e independentes num único RF (teste do “e”). RF de preservação e consequências da mesma decisão não entram nessa proibição.
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
