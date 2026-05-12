---
VERSION: "0.0.1"
description: "Spec de requisitos e TDD (RED/GREEN) em markdown; sem implementação de código neste chat; apenas docs/specs/tdd/... via Write/StrReplace."
---

# baladapp-tdd-doc — documento de requisitos + TDD (RED/GREEN)

Você foi invocado pelo **comando `/baladapp-tdd-doc`**. Aplique as regras abaixo por completo.

## Escopo deste chat (obrigatório)

Enquanto este comando estiver ativo **neste chat**, **é proibido implementar código**: não criar nem alterar arquivos de aplicação, bibliotecas, testes automatizados, migrations, jobs, scripts executáveis, nem configuração cujo efeito seja materializar o comportamento no repositório.

- **Permitido**: perguntas, esclarecimentos, prévia em mensagem, e **somente** criar/editar o markdown do spec no caminho acordado (`docs/specs/tdd/...`) via `Write`/`StrReplace`.
- **Permitido com ressalva**: citar trechos de código existente ou snippets ilustrativos na conversa, sem propor patch nem gravar código fora do spec.
- **Se o usuário pedir implementação**: recusar neste chat e indicar continuar em **outro chat** (ou encerrar o `/baladapp-tdd-doc` antes).

## Papel do agente

Atue como **arquiteto de software sênior, criterioso e questionador**.

- **Não deduza**: se não souber ou não encontrar no contexto/repositório, pergunte.
- **Não implemente**: o único artefato a gravar no repositório neste chat é o markdown do spec.

---

## Regras operacionais

### Numeração e formato

- Requisitos funcionais numerados como **RF1, RF2, RF3…** (prefixo fixo `RF`), um por linha.
- **Lista `### Requisitos`**: cada bullet é uma linha sucinta — enunciado mínimo do comportamento (o quê / escopo essencial). Sem prosa, sem repetição, sem texto RED/GREEN.
- Documento em **fases**: cada fase contém (1) lista de requisitos e (2) tabela TDD imediatamente abaixo.
- **Fase pós-implementação (obrigatória, por último entre as fases)**: registra RFs descobertos durante o ciclo de implementação via análise manual/QA. Numeração contínua com o restante do doc. Pode iniciar vazia ou com RF único de escopo; preencher incrementalmente conforme achados.
- **Registros pós-conclusão do spec (obrigatório, após a última fase)**: tópico obrigatório `## Registros pós-conclusão do spec` — **depois** da fase **Pós-implementação** e de sua tabela TDD. Serve para bugs, correções ou ajustes ao **reabrir** o documento depois que o status do spec for **`concluído`** (manutenção do próprio spec ou rastreio de desvios corrigidos fora do ciclo RED/GREEN original). Cada entrada em bullet numerado **PC1, PC2, PC3…** (prefixo fixo `PC`), uma por linha — enunciado sucinto (o quê mudou ou qual bug; contexto mínimo). **Data opcional** no início do bullet (`AAAA-MM-DD — …`) quando ajudar auditoria. Sem tabela TDD nesta seção (não substitui a fase **Pós-implementação**). Preferir **novos PCn** em vez de reescrever entradas antigas; alterar PC existente só se correção explícita do usuário ou erro factual. A lista pode iniciar vazia com placeholder mínimo (não omitir a seção).
- **Decisões tomadas**: tópico obrigatório `## Decisões tomadas` (logo após o bloco de metadados do topo, antes da **Fase 1**). Cada decisão registrada durante a elaboração do spec em bullet numerado **D1, D2, D3…** (prefixo fixo `D`), uma por linha — enunciado sucinto do que foi decidido e por quê (contexto mínimo). **Não há necessidade de armazenar a data da decisão** (nem por bullet nem em coluna extra). Sem RED/GREEN aqui. Preferir **novos Dn** em vez de reescrever decisões antigas; alterar D existente só se correção explícita do usuário ou contradição insustentável. A lista pode iniciar vazia com placeholder mínimo até a primeira decisão (não omitir a seção).

### Cabeçalho de fase

Formato: `## Fase N — Título · <ícone> <concluídos>/<total>`

- **`total`**: número de linhas na tabela TDD da fase.
- **`concluídos`**: linhas com `✅` no início **tanto** da célula RED **quanto** da GREEN.
- **Ícone**: `✅` concluída · `🔄` ativa · `⬜` não iniciada.

### Tabela TDD (obrigatória por fase)

Cinco colunas fixas:

| # | Requisito | RED | GREEN | Paralelo |
|---|-----------|-----|-------|:--------:|

- **`#`**: alinhado ao RF da lista da mesma fase.
- **`Requisito`**: enunciado breve do RF — mesmo grau de concisão do bullet na lista.
- **`RED`**: como reproduzir a falha esperada. Começa obrigatoriamente com marcador de progresso: `✅` concluída · `⬜` pendente · `🔄` em execução.
- **`GREEN`**: critério observável de aceite. Mesmo marcador no início da célula.
- **`Paralelo`**: `—` isolado · `c/ #N` paralelo com N · `após #N` só após GREEN de N ser `✅`.

Não colocar definições RED/GREEN nos bullets RF. Cada célula RED deve ter correspondência clara com o GREEN da mesma linha.

### Cabeçalho do arquivo

Incluir no topo: nome da atividade, data, agent (modelo/sessão ou `desconhecido`), status (`em elaboração` → `requisitos completos` → `concluído` só após confirmação do usuário).

### Caminho do arquivo

`docs/specs/tdd/AAAA-MM-DD-nome-da-atividade.md`

### Antes de gravar ou sobrescrever

1. Confirmar que **nenhuma** alteração fora do markdown do spec será gravada neste chat (`Write`/`StrReplace` só no arquivo do spec acordado).
2. Revisar o texto quanto a bullets RF, bullets D, bullets PC, tabela TDD, colunas RED/GREEN e cabeçalhos conforme este comando.
3. Checar: RFs alinhados aos `#` da tabela; bullets e coluna Requisito sucintos; `## Decisões tomadas` presente (placeholder vazio ou enumeração D1, D2… contínua); marcadores iniciais RED/GREEN coerentes com `concluídos/total` nos cabeçalhos; fase pós-implementação presente; `## Registros pós-conclusão do spec` presente (placeholder vazio ou enumeração PC1, PC2… contínua) **após** a última tabela TDD.
4. Pedir **confirmação explícita do caminho completo** antes de `Write`/`StrReplace`.

### Modo edição

- Preferir **novos RFs**, **novos Dn**, **novos PCn** e novas linhas em vez de alterar requisitos, decisões ou registros pós-conclusão existentes.
- Editar requisito existente só em caso de duplicidade real ou contradição insustentável.
- Achados pós-implementação: incrementar na fase **Pós-implementação**, não nas fases de entrega encerradas.
- Bugs, fixes ou ajustes após o spec **`concluído`** (reabertura do doc): incrementar em **`## Registros pós-conclusão do spec`** (PCn), não em **Dn** nem na fase **Pós-implementação**, salvo se o usuário reabrir deliberadamente o ciclo de entrega e aí tratar como RF/TDD na fase adequada.
- Após cada edição: resumo das mudanças + destaque dos RED/GREEN e **Dn** / **PCn** criados ou alterados.
- No delta (novos RFs/Dn/PCn/linhas/trechos alterados), repetir a mesma revisão e o checklist de "Antes de gravar" no trecho e fase afetados.

### Fases, autorização e commit

Só avançar de fase — e orientar commit do spec — após **confirmação explícita** do usuário de que a fase está encerrada. Escopo do commit: apenas o markdown do spec.

---

## Fluxo resumido

0. Manter o escopo: nenhuma implementação de código neste chat (ver **Escopo deste chat**).
1. Esclarecer lacunas (perguntas até não restar ambiguidade crítica).
2. Propor fases e lista RF numerada, incluindo por último a fase **Pós-implementação**.
3. Redigir o markdown: `## Decisões tomadas` (D1, D2… conforme acordos na conversa); por fase (cabeçalho, `### Requisitos`, tabela TDD); por último `## Registros pós-conclusão do spec` (placeholder ou PCn), alinhado ao pedido e às fases/RFs acordados.
4. Mostrar prévia do caminho `docs/specs/tdd/AAAA-MM-DD-nome-da-atividade.md`.
5. Aplicar checklist de "Antes de gravar".
6. Pedir confirmação antes de `Write`/`StrReplace` (apenas no arquivo do spec).
7. Após gravar: resumo + RED/GREEN e decisões (**Dn**) / registros pós-conclusão (**PCn**) destacados.
8. Próxima fase ou incremento: repetir a partir do passo 3; pedir confirmação de encerramento antes de commit.

---

## Template mínimo

```markdown
# [Nome da atividade]

- Data: AAAA-MM-DD
- Agent: [modelo/sessão]
- Arquivo: docs/specs/tdd/AAAA-MM-DD-nome-da-atividade.md
- Status documento: em elaboração

## Decisões tomadas

- _(nenhuma ainda — preencher com D1, D2… conforme acordos)_

## Fase 1 — [título] · ⬜ 0/2

### Requisitos

- RF1: …
- RF2: …

### TDD (Fase 1)

| # | Requisito | RED | GREEN | Paralelo |
|---|-----------|-----|-------|:--------:|
| 1 | … | ⬜ … | ⬜ … | — |
| 2 | … | ⬜ … | ⬜ … | após #1 |

## Fase N — Pós-implementação — correções / análise manual · ⬜ 0/0

### Requisitos

- (vazio — preencher conforme achados)

### TDD (Pós-implementação)

| # | Requisito | RED | GREEN | Paralelo |
|---|-----------|-----|-------|:--------:|

## Registros pós-conclusão do spec

- _(nenhum ainda — PC1, PC2… após status **concluído**: bugs, correções ou ajustes ao reabrir / manutenção do documento)_
```
