---
name: revisar-ders
description: >-
  Revisa o Documento de Especificação de Requisitos de Software (DERS) de uma
  tarefa Monday pelo título idêntico. Avalia coesão RF/UC/CA, Cenário,
  suficiência do delta e se cada caminho novo ou alterado é testável por CA
  e pelas referências normativas nomeadas, sem implementação e sem consultar
  o codebase. Não julga o título do item contra o documento. Use com
  /revisar-ders ou quando o usuário pedir para revisar DERS, especificação
  de requisitos ou o documento da tarefa no Monday.
disable-model-invocation: true
VERSION: "1.5.0"
---

# `/revisar-ders`

Revisor de DERS escrito a partir de `/escrever-tarefa`. Só lê, julga e devolve o relatório. Não implementa, não entrevista requisitos do zero, não altera o Monday.

```
/revisar-ders <título idêntico do item no Monday>
```

Sem título na invocação → pedir o título e parar.

## Monday

Quadro **Dia a dia** (`4571892384`). Servidor MCP típico: `user-monday-mcp`. Se `needsAuth` → parar e pedir Settings → MCP → Monday.

1. `get_board_items_page` — `boardId: 4571892384`, `searchTerm` = título informado, `includeColumns: true`, `limit: 25`.
2. Filtrar itens cujo `name` seja **igual caractere a caractere** ao título (após `trim` das pontas; sem normalizar caixa, acento ou pontuação).
3. Zero no quadro → `search` `ITEMS` com o mesmo título; aplicar o mesmo filtro de igualdade. Continuar só com match exato.
4. Um item → ler o DERS da coluna **Documento** (`monday_doc` → `objectId`) com `read_docs` (`mode: content`, `type: object_ids`, `ids: [<objectId>]`).
5. MCP falhou → parar. Não usar token, GraphQL direto nem inventar o documento.

| Resultado | Ação |
|-----------|------|
| 0 match exato | Avisar que não encontrou. Pedir título válido. **Parar.** Não sugerir vizinho. |
| 2+ match exato | Listar `id` + url. Pedir qual. **Parar.** |
| 1 item, sem Documento | Impeditivo: item encontrado, DERS ausente. Não completar com updates, descrição ou memória. |
| 1 item com Documento | Revisar só esse texto. |

Nunca supor a demanda a partir de conversa anterior, branch, MR ou codebase. Não abrir o repositório para completar ou conferir regra ausente: o veredito sai só do texto do DERS.

## Referência normativa

O DERS descreve o que muda. Fluxo existente nomeado em linguagem de negócio é fonte normativa e oráculo comparativo. O revisor não transcreve nem audita essa base.

**Válida:** nomeia o fluxo e delimita o reaproveitamento e a exceção. Ex.: "segue a compra de jogos até a vitrine, sem a janela de vendas". Comparar tela, mensagem ou estado com esse fluxo é aceite executável.

**Inválida:** "segue o padrão atual", "como hoje" ou "o de sempre", sem dizer qual fluxo. Também é inválido o delta — exceção, precedência ou resultado novo — ficar só na referência.

**Não é defeito:** um RF de preservação reunir várias etapas já existentes; consequências da mesma decisão no mesmo RF; um CA representativo para uma família de bloqueios inalterados; objetivo no Cenário e resultado no CA do caminho novo, desde que o RF não seja copiado inteiro em todas as seções.

**É defeito:** reescrever a base; repetir condição transversal em cada RF, UC e CA; regra nova ou alterada sem texto; caminho novo ou alterado sem CA.

## Regras

Papel: revisor. O DERS descreve **o quê** o sistema deve fazer para o usuário e o negócio. Classes, gems, rotas, tabelas, jobs, paths e ferramentas internas no documento são defeito.

### Teste de compreensão (antes de qualquer outro julgamento)

Responder em silêncio (a resposta pode estar no Cenário **ou** nos RF/UC; não exige as duas):

- Qual o problema de negócio?
- Qual a demanda (o que muda)?
- Qual o objetivo final verificável?
- Onde isso ocorre (sistema/tela/jornada em linguagem de negócio)?
- O que o desenvolvedor deve entregar, sem adivinhar?

Pergunta 4: jornada ou formulário nomeados nos RF bastam; não exige nome comercial da tela no Cenário.

Pergunta 5: falha só se um recorte **novo ou alterado já colocado no RF/UC** exige decisão de negócio não escrita (valor inicial, obrigatoriedade, recusa, estado, mensagem, critério de cálculo). Referência válida não é falha. Referência vaga é falha. Falta da transcrição da base não é falha. Falta de UC ou de diagrama **não** é falha desta pergunta.

Se **qualquer** pergunta ficar sem resposta inequívoca no texto → documento **mal escrito**. Isso é **impeditivo**. Não inferir a intenção. Citar o trecho que falta.

### Aceite por agente (depois da compreensão)

O DERS não pode deixar caminho **novo ou alterado** não testável. Quem valida aceita ou rejeita com os CA e as referências normativas declaradas no DERS, sem inventar cenário e sem consultar o codebase.

Caminho no escopo = ramificação **nova ou alterada** já escrita em RF ou UC que **muda o resultado visível** (exibe, some, exige, recusa, registra, estado, o que entra ou sai). Cada um desses caminhos precisa de **pelo menos um CA**. Ramo interno de fluxo só referenciado não é caminho deste escopo.

Caminho novo ou alterado: pré-condições e resultado inequívocos no CA. Caminho preservado: “a tela e a mensagem são as do fluxo nomeado” é comparação executável.

Não exige CA próprio: RF de definição, invariante ou “permanece como está”, se o critério já estiver embutido em CA de caminho. Família de bloqueios inalterados: um CA representativo basta. Não exige UC 1:1 com RF.

Sem CA cobrindo caminho **novo ou alterado** → **impeditivo**. Não completar o delta com UC, Cenário, conversa ou memória. Não exigir a transcrição da base.

### Título

O título do item (e do doc, se houver) serve **só** para localizar o item no Monday e identificá-lo no relatório. **Não** comparar título com Cenário, RF, UC ou CA. **Não** julgar sucinto, jargão, slogan, recorte ou se o título descreve outra demanda. Divergência título ↔ documento **não** é achado.

### Cenário

O documento **começa** pela seção **Cenário** (2–4 frases): problema → demanda → objetivo final verificável.

Não lista regras. Não fala de stack. Começar por “O que deve ser feito”, lista solta ou código → falha de estrutura.

### Coesão RF ↔ UC ↔ CA

Mesmo vocabulário de negócio em Cenário, RF, UC e CA. Não incluir o título nessa coesão.

**RF:** decisão nova ou alterada = um comportamento por item; numeração RF 1, RF 2, …; verificável (dado X, o sistema faz Y). Proibido agrupar decisões novas independentes, duplicar o mesmo requisito com outras palavras, ou contradizer outro RF/UC/Cenário. RF de preservação pode reunir etapas já existentes. Consequências da mesma decisão podem ficar no mesmo RF. RF de bloqueio **novo ou alterado** precisa de **CA** de recusa (UC sozinho não basta). Bloqueio preservado não exige um CA por motivo.

**UC:** um passo por item; referencia `RF n` sem copiar o RF; tem passos **e** diagrama. UC que inventa regra fora dos RF, ou que ignora RF obrigatório do fluxo → incoerência. RF de jornada sem UC, com o comportamento já no RF e com CA, **não** é impeditivo (Alta).

**CA:** um caminho completo + resultado esperado. Caminho novo ou alterado: pré-condições e resultado sem ambiguidade. Caminho preservado: comparação com o fluxo nomeado. CA sem base em UC/RF → incoerência. **Todo UC** e **toda ramificação nova ou alterada** precisam de CA correspondente. Falta disso → **impeditivo**. “Como hoje”, sem nomear o fluxo, também é impeditivo.

### Suficiência (sem como técnico)

RF + UC devem bastar para entender o problema, **onde** no produto (tela, jornada, ator) e **o que muda**. O comportamento mantido basta estar nomeado. Os **CA**, com as referências declaradas no DERS, devem bastar para validar cada caminho novo ou alterado. “Como” é comportamento, não solução técnica.

Defeito: classe, método, gem, framework, rota, controller, job, migration, tabela, coluna, path, endpoint, factory, nome de arquivo. Não exigir performance, deploy ou stack. Não sugerir desenho de código.

### Qualidade do texto

Português brasileiro. Sem “etc.”, “quando aplicável”, “pode”, “a definir”. Problema de repetição: redefinir a base ou repetir condição transversal em cada RF, UC e CA. Objetivo no Cenário e resultado no CA do caminho novo não são esse problema. Se o dev precisa saber de regra **nova ou alterada**, está escrita. Regra mantida está referenciada, não reescrita. Impactos, se existirem: slug do repositório e tela — não nome comercial no lugar do slug.

### Calibração do impeditivo

Duas perguntas, **antes** de classificar cada achado:

1. **Dá para implementar o recorte sem inventar regra nova ou alterada, com o texto e as referências normativas declaradas?**
2. **Dá para aceitar ou rejeitar cada caminho novo ou alterado com os CA e essas referências, sem inventar cenário de teste?**

Qualquer **não** → **Pontos críticos**. `Pronto: não`.
Os dois **sim** → **Demais problemas**. Não subir para crítico por rigor de estilo.

Regra de negócio = valor inicial, obrigatoriedade, recusa, estado, mensagem, critério de cálculo, o que entra ou sai do recorte.

Não é regra de negócio **nem** falha de aceite (logo **não** é impeditivo): RF de preservação que agrupa etapas existentes; consequências da mesma decisão no mesmo RF; comparação com fluxo nomeado; um CA para família de bloqueios inalterados; ausência da transcrição da base; RF repetido; RF de fluxo sem UC quando o RF já descreve o comportamento **e** o CA cobre o resultado; UC sem diagrama; “pode”; termo técnico isolado; script/deploy/pipeline quando o efeito de negócio já está escrito; RF de definição/invariante já embutido noutro CA. Título do item ou do doc **nunca** entra nesta calibração.

Continua impeditivo: referência vaga; delta sem regra; caminho novo ou alterado sem CA; contradição; exceção ou precedência não escrita.

**Estabilidade:** o mesmo texto DERS → o mesmo veredito. Na dúvida entre crítico e alta, repetir as duas perguntas. Não rebaixar buraco de regra **nova ou alterada** nem caminho **novo ou alterado** sem CA para alta. Não promover a crítico a falta de transcrição da base.

`Pronto: sim` só se **Pontos críticos** = nenhum.

### Gravidade

| Gravidade | Quando |
|-----------|--------|
| **Impeditivo** | Qualquer das duas perguntas deu não: DERS ausente; Cenário inexistente ou incompleto; teste de compreensão falhou; referência vaga; contradição RF/UC; duplicata que muda o escopo; documento só técnico; UC sem CA; ramificação **nova ou alterada** sem CA; exceção ou precedência não escrita. Vai em **Pontos críticos impeditivos**. Título do item **não** gera impeditivo. Ausência da transcrição da base **não** gera impeditivo. |
| **Não impeditivo** | As duas perguntas deram sim; o trecho precisa correção. Vai em **Demais problemas**, com prioridade **alta**, **média** ou **baixa**. Não é “opcional de estilo”: é problema. |

Prioridade (só para não impeditivos):

| Prioridade | Quando |
|------------|--------|
| **Alta** | Coesão fraca (sem título), UC sem RF, RF de jornada sem UC **quando o RF já basta e o CA cobre o resultado**, Cenário frouxo, como técnico (script/deploy) com efeito de negócio já escrito |
| **Média** | Decisão nova não atômica, redefinição da base, repetição de condição transversal, termo técnico isolado, UC sem diagrama |
| **Baixa** | Clareza, recorte, ordem, vocabulário, “pode”/“etc.”, impacto com nome comercial |

Não inventar escopo. Achado só a partir do que está escrito (ou da falta explícita).

**Sugestões** não são achados novos. Cada item aponta para um problema já listado (impeditivo ou demais) e oferece **opções** de correção. Se a ideia ainda não apareceu como problema, promovê-la para **Pontos críticos** ou **Demais problemas** — nunca só em Sugestões.

## Relatório

Única saída, em pt-BR. Não reescrever o DERS. Não colar o documento. Não propor patch de código.

```markdown
## Veredito
- Item Monday: [título exato] ([id] / url)
- Pronto para desenvolver: sim | não
- Uma frase: [se o DERS deixa claro problema, demanda, objetivo, onde e o quê]

## Pontos críticos impeditivos
- [achado] — [trecho ou seção] — [por que impede]

## Demais problemas
### Alta
- [achado] — [trecho ou seção] — [por que corrigir]

### Média
- [achado] — [trecho ou seção] — [por que corrigir]

### Baixa
- [achado] — [trecho ou seção] — [por que corrigir]

## Sugestões
- [problema X]: [opção A] | [opção B]
```

Seções vazias: `Nenhum.` (em Demais problemas, heading de prioridade sem itens: `Nenhum.`). Não omitir o heading.

Em **Sugestões**, citar o problema pelo achado (ou RF/UC/seção) já usado acima. Uma ou mais opções por problema; não listar problema sem opção, nem opção sem problema. Não sugerir mudança de título.
