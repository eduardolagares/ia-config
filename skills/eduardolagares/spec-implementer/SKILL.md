---
name: spec-implementer
description: >-
  Use sempre que o usuário colar um documento de requisitos estruturado como
  Cenário / RF (Requisito Funcional, numerado) / Critério de aceite / UC (Caso
  de Uso, numerado, referenciando RFs) e pedir para implementar. Também dispara
  em frases como "implementa esse documento", "segue esse RF", "bora implementar
  isso". Otimiza para entrega correta e rápida: implementa direto, só pergunta o
  genuinamente crítico, salva plano e decisões em docs/specs/, e nunca reporta
  pronto sem os testes passando.
disable-model-invocation: true
VERSION: "1.1.0"
---

# Spec Implementer

Transforma um doc Cenário/RF/UC em código funcionando e testado, o mais rápido
possível dentro do correto. Agir, não perguntar: leia o código antes de
questionar o usuário. Processo (TDD, etc.) não é o objetivo — siga o que as
skills/regras do projeto já definem; essa skill não prescreve convenção de
implementação, só o fluxo doc → plano → código → teste → relatório.

## 0. Rules são lei — carregar antes de implementar

Rules do **agente** (ex.: `~/.cursor/rules/`, `~/.agents/rules/`) e do **projeto**
(ex.: `.cursor/rules/`, `AGENTS.md`, conventions no repo) são **lei**, não
sugestão. **Antes** de criar o spec e de escrever código:

1. Localize e **leia** as rules aplicáveis (globais do agente + específicas do
   projeto / stack / camada tocada).
2. Implemente **só** dentro delas — naming, camadas, testes, estilo, escopo.
3. Conflito entre RF e rule → não ignore a rule; decida com a menor mudança
   compatível ou pergunte (fechada) se o RF exige violar a rule.

Não começar a codar sem ter carregado essas rules.

## 1. Ler o doc e criar o spec antes de codar

Extraia Cenário (contexto), RFs (unidades de implementação), Critérios de
aceite (viram casos de teste dos RFs que referenciam, não itens à parte) e UCs
(fluxos ponta a ponta).

Crie `docs/specs/<slug>.md` (slug do Cenário, kebab-case) como fonte única da
verdade — plano e log de decisões, não só no chat. Estrutura espelha o doc de
entrada, mesma numeração, mais uma seção de código:

````markdown
# <Título>

## Cenário
<resumo, 2-4 linhas>

## Requisitos funcionais
- RF 1 — <requisito> — Status: <status>

## Critérios de aceite
- RF N — <critério> — Status: <status>

## Casos de uso
- UC 1 — <caso de uso> — Status: <status>

## Decisões e código implementado
### RF 1
- Arquivo(s): <caminho>
- Abordagem: <direto / teste antes>
- Suposição/decisão (se houver): <o quê e por quê>
- Código alterado:
  ```diff
  <trecho real da mudança — não só descrever em prosa>
  ```
- Teste: <o que cobre> | ou: não automatizável → ver Casos de teste para QA

## Perguntas feitas ao usuário
- <pergunta> → <resposta>

## Casos de teste para QA
- RF N — <o que testar> — valores de exemplo: <...> — resultado esperado: <...>
````

Cada RF/critério/UC do doc original aparece com seu próprio status — sem
resumir vários numa linha. Todo trecho de código alterado ou criado precisa
estar explícito na seção de código, com diff. Atualize o arquivo conforme
implementa; o relatório no chat (§5) só aponta pra ele.

**Código / comportamento sem teste automatizado:** qualquer pedaço que não
puder ser travado por teste automático **deve** constar em "Casos de teste
para QA" no spec (o quê, valores de exemplo, resultado esperado) — nunca só
no chat. Status do RF: "aguardando QA", nunca "pronto".

## 2. Responder suas próprias perguntas primeiro

Antes de perguntar, procure no código: onde a view/classe já mora, convenções
e padrões já usados em lógica parecida, testes existentes na área.

Só pergunte ao usuário quando **tudo** isso for verdade: (1) o código não
responde, (2) duas implementações razoáveis dariam resultados visivelmente
diferentes, (3) errar sai caro de refazer. Cada pergunta: fechada ("A ou
B?"), registrada em "Perguntas feitas ao usuário". Caso contrário, decida
sozinho, registre a suposição na subseção do RF, e siga.

**Lote de perguntas:** se precisar de **mais de uma**, liste **todas** de uma
vez no mesmo turno (numeradas, cada uma fechada). Não faça pingue-pongue
pergunta → resposta → próxima pergunta. Espere as respostas do lote e só
então continue.

## 3. Implementar

Priorize velocidade de entrega correta — sem metodologia fixa. Teste-primeiro
só quando for genuinamente o caminho mais rápido (lógica arriscada, componente
compartilhado com pouca cobertura). Agrupe por RF em pedaços pequenos e
revisáveis. Não altere nada fora do que os RFs pedem — RFs que travam
comportamento atual (ex. "não mudar a fonte") são guardrail, não sugestão.
Não commite automaticamente.

Para RFs (ou trechos) não traváveis por teste automatizado (ex. posicionamento
visual), escreva o teste que for possível e **obrigatoriamente** registre o
resto em "Casos de teste para QA" no spec — caso pronto pra QA rodar, não
lembrete. Status: "aguardando QA", nunca "pronto".

## 4. Gate de teste — nunca pular

Rode os testes da área tocada. Todos verdes antes de reportar qualquer coisa
como pronta; se algo falhar, corrija ou diga claramente o que está vermelho e
por quê. O que ficou sem automação já deve estar listado no spec (§1 / Casos
de teste para QA).

## 5. Relatório final

Em pt-BR, curto — detalhe mora no spec:
- Caminho do `docs/specs/<slug>.md`.
- Status por RF (pronto / aguardando QA / bloqueado por pergunta).
- Suposições tomadas.
- Quais RFs/trechos têm caso de teste manual no spec e por quê (não automatizável).

Não re-renderize o conteúdo do spec no chat.
