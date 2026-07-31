---
name: gerar-plano-de-implementacao
description: >-
  Plano de implementação em pt-BR a partir de documento funcional
  (escrever-tarefa): no workspace do projeto a alterar, avalia a estrutura de
  código atual para decidir na entrevista grill-me; garante cobertura de
  Cenário/RFs/UCs/Impactos com nomes concretos — sem impor arquitetura nem
  outras skills. Grava em docs/planos-de-implementacao/. Use com
  /gerar-plano-de-implementacao.
disable-model-invocation: true
VERSION: "1.1.3"
---

# gerar-plano-de-implementacao

Plano de implementação em **português brasileiro** a partir de um documento funcional nos moldes de **escrever-tarefa**. **Sempre** entrevista (**grill-me**). **Não** implementa — só planeja.

## Objetivo (invariante)

Garantir que **tudo o que a tarefa pede** está **contemplado** no plano. O sucesso não é inventar arquitetura “certa”; é **cobertura rastreável** do documento-fonte.

## Nomes concretos (avaliação humana)

Sempre que possível, o plano deve ser **legível por um humano em revisão** sem abrir o chat: nomes reais de classes, módulos, arquivos, testes e demais âncoras do repositório.

| Preferir no artefato | Evitar |
|----------------------|--------|
| `DominioX::UseCases::Y::CriarPedido` | “o use case de pedido”, “uma service” |
| `app/domains/.../criar_pedido.rb` | “arquivo do domínio”, “no backend” |
| `test/.../criar_pedido_test.rb` | “teste unitário correspondente” |
| Método/rota/job/coluna/tabela quando já existirem ou forem o alvo claro | “ajustar a API”, “mexer no model” sem nome |

**Regra:** se a exploração do codebase (ou a entrevista) já revelou o identificador → **escrevê-lo** no plano. Só usar descrição genérica quando o nome ainda for decisão aberta — e nesse caso marcar como proposta (`proposta: NomeSugerido`) ou pergunta em aberto, nunca omitir o slot.

Incluir tudo o que ajude a avaliação humana da cobertura: classes, paths, testes, migrations (nome proposto), rotas/endpoints, jobs, componentes de UI, factories/fixtures tocados — **quando relevantes e conhecidos**.

| Fonte (tarefa) | O plano deve |
|----------------|--------------|
| Cada **RF** | Aparecer no mapeamento com peça de implementação e/ou teste (ou em fora de escopo **com acordo explícito**) |
| Cada **UC** | Ter passos cobertos pelas peças listadas (classes/arquivos/testes) ou referência cruzada clara |
| **Cenário** / **Impactos** | Reflectir-se no resumo e nas peças tocadas (sistemas/telas no âmbito) |

**Antes de gravar:** percorrer RF 1…n (e UCs) e confirmar zero lacuna. Lacuna conhecida → perguntar ou marcar fora de escopo com acordo — **não** gravar como “pronto” com RF órfão.

## Papel

Agent em **modo Plan** **dentro do projeto que será alterado** (workspace atual = código-alvo): traduzir o documento funcional em mapa acionável, com decisões da entrevista **fundamentadas na estrutura de código existente**.

| Incluir no plano | Excluir do plano |
|------------------|------------------|
| Classes/módulos a criar/alterar (nome, responsabilidade, RFs) | Código completo, snippets longos |
| Arquivos a criar/alterar | Recontar o documento funcional em prosa de negócio |
| Testes a criar/alterar (o que protege; RF/UC) | Estimativas de esforço |
| Ordem e dependências entre passos | Decisões de produto abertas (devolver a `escrever-tarefa`) |
| Lacunas / fora de escopo explícitos | Escopo extra sem acordo |

**Esta skill não define** padrão de camadas, naming, TDD, guards nem stack. **Não** obriga ler nem seguir rules/skills do projeto ou do agent como parte deste fluxo. O que manda é o **código que já está no repo** — observar e espelhar; não importar checklist de arquitetura externo.

## Estrutura de código atual (obrigatório)

Esta skill **normalmente corre no repositório a alterar**. Antes e **durante** a entrevista, avaliar a estrutura atual o suficiente para decidir com evidência — não planejar “no vazio”.

| Avaliar | Para quê |
|---------|----------|
| Layout de pastas / domínios / apps tocados pelos Impactos e RFs | Onde encaixar peças novas |
| Classes, módulos e pontos de entrada existentes (controllers, jobs, models, …) | Reusar vs criar; nomes concretos |
| Testes espelho e padrões de teste do projeto | O que criar/alterar com path real |
| Fluxos vizinhos parecidos com os UCs | Precedente a seguir na recomendação grill |
| Schema / rotas / contratos já expostos quando o RF depende deles | Evitar proposta que ignore o que já existe |

**Como:** explorar o codebase (listar, buscar, ler) **antes** de cada pergunta cuja resposta o código possa dar — regra grill-me. Preferir recomendação grounded (“hoje X faz Y em `path`; proponho estender Z”) a opinião genérica.

**Profundidade:** cobrir as áreas impactadas pela tarefa com rigor; alargar a varredura quando a tarefa for transversal. Não precisa ler o monorepo inteiro linha a linha — precisa **conhecer a estrutura relevante** antes de fechar decisões.

Se o workspace **não** for o projeto a alterar → perguntar uma vez o path/repo correto antes de aprofundar a entrevista técnica.

O **chat** pode citar trechos curtos; o **arquivo gravado** lista nomes, paths e responsabilidades — sem implementações.

## Entrada: documento funcional

Pré-requisito: documento no formato **escrever-tarefa** (Cenário, RFs, UCs, Impactos).

| Modo | Quando | Artefato ao gravar |
|------|--------|-------------------|
| **Novo plano** | Path sob `docs/tarefas/*.md`, `@ficheiro`, ou texto no template v2 | **Novo** em `docs/planos-de-implementacao/YYYY-MM-DD-HHmmss-<slug>.md` |
| **Continuar plano** | Path sob `docs/planos-de-implementacao/` terminado em `.md` | **O mesmo arquivo** — atualizar in-place |

**Antes** de pedir texto livre, **ler** o ficheiro indicado.

Sem ficheiro nem texto → **uma vez** pedir path de `docs/tarefas/…` (ou colar o documento). **Não** começar grill sem a fonte.

Ambiguidade de **negócio** → não inventar RF; perguntar ou apontar `/escrever-tarefa`. Esta skill **não** reescreve o documento funcional.

## Pré-requisito: grill-me

No **primeiro turno**, localizar e ler **grill-me** (`SKILL.md`), por ordem:

1. `~/.agents/skills/grill-me/SKILL.md`
2. `~/.cursor/skills/grill-me/SKILL.md`
3. `~/.claude/skills/grill-me/SKILL.md`

Seguir o conteúdo lido. Se nenhum existir, aplicar:

```
Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.
```

Até gravar o plano, **não** invocar outras skills (só **grill-me** nesta entrevista).

## Entrevista: cobertura + estrutura existente

**Uma pergunta de cada vez**, com recomendação **baseada no que o código atual mostrou**. Priorizar o que deixaria RF/UC sem peça no plano **ou** decisão desalinhada da estrutura existente.

| Perguntar quando | Exemplos |
|------------------|----------|
| RF sem âncora no código | Após explorar: criar novo vs estender `ClassName` em `path`? |
| UC com passo sem dono | Qual classe/arquivo/teste existente (ou proposto) cobre este passo? |
| Impacto de sistema/tela vago | O que muda nesse impacto no layout atual? |
| Conflito com precedente do repo | Seguir o padrão de `path` vizinho ou desviar (porquê)? |
| Conflito ou duplicata entre RFs | Qual prevalece no plano? |
| Fora de escopo tentador | Confirmar exclusão explícita |

**Antes da primeira pergunta técnica** (com documento-fonte já lido): varrer a estrutura relevante aos Impactos/RFs e só então perguntar — ou perguntar só o que a varredura não resolveu.

**Permitido antes do entendimento completo:** perguntas grill, síntese curta do que a estrutura atual mostrou, confirmação de cobertura já acordada.

**Proibido até entendimento completo:** template completo como “final”; implementar; decidir peças principais **sem** ter olhado o código tocado.

**Entendimento completo:** cada RF (e UCs no âmbito) tem destino no plano **ou** fora de escopo acordado, com nomes ancorados na estrutura avaliada. Só então montar o documento para revisão/gravação.

## Idioma — português brasileiro (obrigatório)

Todo o **arquivo gerado** em **pt-BR**.

| Evitar (pt-PT) | Usar (pt-BR) |
|----------------|--------------|
| ficheiro, secção, utilizador | arquivo, seção, usuário |
| actualizar, excepto, ecrã | atualizar, exceto, tela |

Identificadores de código (classes, paths) como no projeto.

## Artefato: caminho e nome

- **Pasta (novo):** `docs/planos-de-implementacao/` (criar se não existir).
- **Nome (novo):** `YYYY-MM-DD-HHmmss-<slug>.md` — `^[a-z0-9]+(-[a-z0-9]+)*$`.
- **Continuar plano:** manter o path.
- **Fonte:** no topo, path do `docs/tarefas/…`.

## Quando gravar

1. Pedido explícito do utilizador; ou
2. Entendimento completo **e** confirmação para gravar — **e** checklist de cobertura OK.

**Até lá:** não criar arquivo novo por iniciativa própria.

Após gravar: confirmar path (uma linha). **Não** acionar outras skills automaticamente.

## Formato obrigatório do documento

Headings `###` com título **em negrito** terminado em **`:`**. Quebra de linha **somente entre blocos**.

```markdown
### **Fonte:**
- Documento: docs/tarefas/YYYY-MM-DD-HHmmss-slug.md
- Plano: docs/planos-de-implementacao/YYYY-MM-DD-HHmmss-slug.md
- Status: em elaboração | pronto para implementação

### **Resumo:**
[2–4 frases: o que o plano cobre face à tarefa.]

### **Cobertura da tarefa:**
- RF 1 — contemplado: `ClassName` + `path/arquivo.rb` + `path/teste.rb`; lacuna: nenhuma
- RF 2 — …
- UC 1 — contemplado: `ClassName` / `path/…`
- Impactos — …

### **Decisões:**
- D1 — … (só o necessário para fechar cobertura; citar RF/UC; nomes quando couber)

### **Classes e módulos:**
**Criar:**
- `Namespace::ClassName` — responsabilidade; RFs/UCs
**Alterar:**
- `Namespace::ClassName` — o que muda (método/associação/coluna se souber); RFs/UCs

### **Arquivos:**
**Criar:**
- `app/.../nome.rb`
**Alterar:**
- `app/.../existente.rb` — alteração resumida (1 linha, com símbolo se souber)

### **Testes:**
- `test/.../nome_test.rb` — protege [comportamento observável]; RF/UC; criar|alterar

### **Ordem de implementação:**
1. `path` / `ClassName` — …
2. …

### **Riscos e fora de escopo:**
- Risco: … — mitigação: …
- Fora de escopo: … (RF/UC acordado como excluído, se houver)
```

Regras:

- Secção **Cobertura da tarefa** é obrigatória e deve listar **todos** os RFs (e UCs/impactos relevantes) do documento-fonte.
- Referenciar `RF n` / `UC n` — não colar o texto integral.
- **Nomes concretos** (§ acima): classes, arquivos e âncoras relevantes sempre que conhecidos; cobertura e listas usam identificadores, não só prosa.
- Nomes/paths ancorados no que o repo mostrou quando existir precedente; propostas novas escritas como nome completo sugerido.
- Status `pronto para implementação` só com cobertura completa e confirmação do utilizador.

## Qualidade (antes de gravar)

| Critério | O que fazer |
|----------|-------------|
| **Cobertura** | Nenhum RF no âmbito sem linha na cobertura / mapeamento |
| **Estrutura** | Decisões principais reflectem o código atual do workspace (não plano genérico) |
| **Nomes** | Humano consegue auditar classes/arquivos/testes citados sem adivinhar |
| **Acionável** | Peças com nome/path suficientes para outro agent executar |
| **Sem código** | Sem corpos de método |
| **pt-BR** | Prosa do artefato em português do Brasil |

## Proibido

- Implementar código, testes, migrations ou config neste fluxo.
- Gravar sem ter lido o documento-fonte (quando path foi dado).
- Inventar regras de negócio ausentes da tarefa.
- Deixar RF/UC no âmbito sem contemplação nem exclusão acordada.
- Impor ou checklistar rules, guards, skills ou padrão de arquitetura do pacote/projeto como requisito desta skill.
- Invocar outras skills (exceto grill-me na entrevista).
- Apresentar o plano “final” antes do entendimento de cobertura.
- No artefato: snippets longos, estimativas, pt-PT, “TBD” sem acordo.
- Plano só com rótulos vagos (“o service”, “os testes”, “o controller”) quando o nome já era conhecido ou proponível.
- Fechar o plano sem avaliar a estrutura de código relevante do workspace atual.
- Gravar fora de `docs/planos-de-implementacao/…` sem pedido explícito.

## Exemplos de invocação

```
/gerar-plano-de-implementacao
/gerar-plano-de-implementacao docs/tarefas/2026-05-26-143052-exportar-relatorio.md
/gerar-plano-de-implementacao docs/planos-de-implementacao/2026-05-26-150011-exportar-relatorio.md
```

Com ficheiro na mesma mensagem: ler a tarefa; **avaliar a estrutura** das áreas impactadas; primeira resposta = o que o código atual implica para a cobertura + **uma** pergunta grill (com recomendação grounded) sobre a maior lacuna.
