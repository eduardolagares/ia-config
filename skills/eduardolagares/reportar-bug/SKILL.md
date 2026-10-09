---
name: reportar-bug
description: >-
  Relatório de bug em português brasileiro (Cenário, Como replicar, Comportamento esperado,
  Impactos). Não elenca regras do processo já definido. Grill-me só quando faltar o que
  impede reproduzir, quando o conserto exigir regra nova, ou para confirmar os repositórios
  impactados. Grava em docs/tarefas/. Após gravar, pode acionar criar-tarefa-no-monday.
  Use com /reportar-bug.
disable-model-invocation: true
VERSION: "1.1.0"
---

# reportar-bug

Relatório de **bug** em **português brasileiro**. O comportamento do produto **já existe** e não está a acontecer como esperado. O artefato descreve o caso, como repetir a falha, se for conhecido o que deveria ter acontecido, e quais repositórios a correção toca.

**Não** é especificação de processo. **Não** elencar regras, requisitos, casos de uso nem critérios de aceite do fluxo em volta.

Durante a entrevista, a única skill extra é **grill-me**. Depois de gravar com aprovação, pode acionar **criar-tarefa-no-monday**.

Pedido de funcionalidade nova ou de mudança de regra de um fluxo que ainda vai ser desenhado → **parar** e apontar `/escrever-tarefa`.

## Papel

Questionar o que impede outra pessoa de repetir o bug, ou o que ainda não está decidido para corrigir. Não presumir regra nova. Não inferir o comportamento esperado quando o usuário não o deu.

Explorar o codebase só para entender a tela, o fluxo e **quais repositórios** a correção toca. No arquivo gravado, linguagem de negócio: sem código, paths, SQL, classes, rotas, jobs, tabelas ou nomes de arquivo. Exceção: slug de repositório Git **somente** em **Impactos**.

## Entrevista

**Grill-me**, uma pergunta de cada vez, só quando faltar algo que bloqueie o relatório:

- quem fez, em que tela, o que falhou
- passos que outra pessoa consiga repetir
- o resultado observado
- se o esperado já é o comportamento do produto, ou se o conserto precisa de uma regra que ainda não existe

Não entrevistar o processo em volta. Não pedir lista de regras existentes nem critérios de aceite do fluxo.

Se o usuário já trouxer cenário, passos e o resultado observado — e o esperado, ou a informação de que não sabe o esperado — e não houver sinal de regra nova: confirmar em prosa curta. Sem entrevista de domínio. Sem rascunho do template. **Não** seguir para gravar enquanto **Impactos** não estiver confirmado — fazer a pergunta da seção **Impactos** nesse momento.

## Regra nova

Regra nova só quando o conserto **não** for restaurar um comportamento que o produto já define. Se couberem duas correções, perguntar. Não escolher em silêncio.

Quando for o caso, grill só essa decisão (estado, recusa, mensagem, o que muda e o que não muda). No documento, essas regras ficam **somente** em **Comportamento esperado**. O resto do processo fica de fora.

## Impactos

Listar os **repositórios Git** que a correção toca — **não** o efeito no usuário e **não** o nome comercial do sistema ou produto.

| Nome comercial (evitar no doc) | Repositório (usar no doc) |
|--------------------------------|---------------------------|
| Assinaturas ADM | `assinaturas-adm` |
| ADM Anúncios | `ingressos` |

No chat, pode-se falar “Assinaturas ADM” ou “ADM Anúncios”; no **arquivo gravado**, converter para o slug do repositório.

Formato da lista:

- Um bullet por repositório: `- assinaturas-adm`
- Tela concreta, quando relevante: `- assinaturas-adm — Tela Faturas` ou `- ingressos — Tela X`

**Sempre** confirmar **impactos** com o usuário antes de considerar o relatório fechado ou gravar.

1. Explorar o codebase só o bastante para sugerir candidatos (repositório e tela).
2. Resumir no chat a lista atual de repositórios/telas (ou “ainda não definida”) — **sem** colar o documento completo, salvo pedido explícito de revisão.
3. **Uma pergunta** (grill-me): quais repositórios (e telas) estão no âmbito; incluir a recomendação. No chat pode usar nome comercial; no doc gravar o slug.

Aceitar a resposta (confirma, ajusta ou “nenhum”). Só então a lista entra no arquivo. Não gravar a sugestão como se já estivesse confirmada.

## Artefato

- **Pasta:** `docs/tarefas/` no workspace atual (criar se não existir).
- **Nome:** `YYYY-MM-DD-HHmmss-<slug>.md` — slug do bug; minúsculas, hífens, sem acentos; `^[a-z0-9]+(-[a-z0-9]+)*$`.
- **Continuar relatório:** caminho sob `docs/tarefas/` terminado em `.md` passado na invocação → atualizar esse arquivo. Não renomear.
- Idioma do arquivo: pt-BR. Evitar pt-PT (utilizador, ficheiro, ecrã, activo).

## Quando gravar

Gravar quando o usuário pedir (ex.: «salva», «grava») **ou** quando o relatório estiver fechado e ele confirmar.

Até lá, só entrevista no chat. Não criar arquivo por iniciativa própria.

**Antes de gravar**, as quatro têm de ser sim:

1. Outra pessoa consegue repetir o bug só com **Como replicar**.
2. O resultado observado está explícito.
3. **Comportamento esperado** não reescreve o fluxo. Regra listada ali é decisão nova, não repetição de regra que já existe.
4. **Impactos** foi confirmado pelo usuário (lista de repositórios, ou “nenhum”).

Se pedirem gravar com **Como replicar** vazio → avisar e perguntar. Gravar mesmo assim só se insistirem na mesma mensagem depois do aviso. Seções em falta: `_A preencher._`. **Comportamento esperado** desconhecido e não exigido → omitir a seção. Não inventar.

Se pedirem gravar sem impactos confirmados → fazer a pergunta de **Impactos** nesse turno (não assumir a lista sugerida). Só gravar depois da resposta, ou se insistirem na mesma mensagem depois do aviso. Sem essa confirmação e sem insistência: `- _A confirmar com o usuário._`. Confirmado “nenhum”: `- nenhum`.

## Após gravar — monday (criar-tarefa-no-monday)

**Somente depois** de gravar o `.md` com aprovação explícita do usuário:

1. Confirmar o path gravado (uma linha).
2. **Perguntar:** deseja criar a tarefa no monday? (recomendação: sim, se o relatório está pronto para correção).
3. Resposta **positiva** → localizar e seguir **`criar-tarefa-no-monday`** (`~/.agents/skills/eduardolagares/criar-tarefa-no-monday/SKILL.md` ou equivalente instalado). Grupo, colunas e demais defaults do board ficam **somente** nessa skill. Esse «sim» **não** autoriza MCP Monday: a skill Monday exige a entrevista de parâmetros e **«Posso criar no Monday exatamente com os parâmetros acima?»** antes de publicar.
4. Passar o **`.md` gravado** como documentação. Não reabrir entrevista do bug.

Resposta negativa ou silêncio → encerrar. Não criar tarefa no monday.

## Formato do documento

Headings `###` em negrito, terminados em `:`. Quebra de linha só **entre** seções, nunca entre o título e o corpo da mesma seção.

Ordem fixa. **Comportamento esperado** só entra se houver texto. **Impactos** entra sempre, por último.

```markdown
### **Cenário:**
[Quem, onde e o que falhou. Prosa curta — 2–4 frases. O resultado errado que a pessoa viu.]

### **Como replicar:**
1. [passo concreto]
2. [passo concreto]
Resultado observado: [o que aconteceu, em uma frase].

### **Comportamento esperado:**
[Omitir a seção inteira se ninguém souber. Não inventar.]
[Comportamento já definido: um parágrafo do que deveria ter acontecido. Sem lista de regras existentes.]
[Regra nova necessária para corrigir: só essas regras, uma por item. Cada item é uma decisão que o produto ainda não tem.]

### **Impactos:**
- [slug-do-repositorio]
- [slug-do-repositorio — Tela Nome]
```

## Proibido

- Elencar regras, RFs, UCs, critérios de aceite ou diagramas do processo já definido.
- Tratar bug como tarefa nova de `/escrever-tarefa`.
- Inventar comportamento esperado ou regra nova.
- Gravar regra existente dentro de **Comportamento esperado**.
- Gravar **Impactos** com nome comercial de sistema em vez do slug do repositório.
- Gravar a lista de repositórios sem a confirmação do usuário.
- Descrever em **Impactos** o efeito no usuário ou no negócio — a seção é só repositório e, se couber, tela.
- No arquivo: código, pseudocódigo, paths, SQL, rotas, controllers, jobs, tabelas, colunas, classes. Slug de repositório só em **Impactos**.
- Chamar **criar-tarefa-no-monday** antes de gravar o `.md`, ou sem o «sim» à pergunta de criar no monday.
- Mencionar skills além de **grill-me** (entrevista) e **criar-tarefa-no-monday** (só depois da gravação aprovada).
- Implementar código, migração ou teste neste fluxo.
- Gravar fora de `docs/tarefas/` sem pedido explícito.
- Duplicar defaults de board do monday nesta skill.

## Exemplos de invocação

```
/reportar-bug
/reportar-bug <texto livre do bug>
/reportar-bug docs/tarefas/2026-05-26-143052-falha-ao-cancelar.md
```

Com texto ou arquivo na mesma mensagem: ler de imediato. Se já der para repetir o bug, confirmar em prosa curta e fazer a pergunta de **Impactos**. Se faltar um fato bloqueante, a primeira resposta é **uma** pergunta grill — sem rascunho do template.

**Pacote:** `skills/eduardolagares/reportar-bug/` — instalada pelo `install/` em `{destino}/skills/eduardolagares/reportar-bug/`.
