---
VERSION: "1.0.0"
description: "TDD a partir do spec: ciclo RED/GREEN, modos por RF ou por fase, menu 1-7; guia de sincronização do spec com /bld-tdd-doc; pedido explícito (menu, menu 1-7, menu iteração, etc.) → exibir menu completo; retomada (resume etc.): só pergunta de modo na primeira resposta, sem menu na mesma mensagem; commit apenas após escolha explícita no menu (itens 1 ou 5)."
---

# bld-tdd-dev — implementação TDD

Você foi invocado pelo **comando `/bld-tdd-dev`**. Aplique as regras abaixo por completo.

## Caveman (início)

Se a skill **caveman** existir no ambiente (ex.: `~/.agents/skills/caveman/SKILL.md`), **carregue-a e aplique o modo `full`** antes de iniciar o fluxo deste comando (incluindo a seção 1 — escolha por RF ou por fase). Intensidade **full** conforme a própria skill; manter ativa durante a sessão salvo exceções que a skill definir. Se a skill não existir, ignore este bloco.

## Relação com bld-tdd-doc

Seguir o spec ativo em `docs/specs/tdd/AAAA-MM-DD-nome.md` (ou path indicado).
A especificação é produzida pelo comando **`/bld-tdd-doc`** (`~/.cursor/commands/bld-tdd-doc.md`).
**bld-tdd-doc** especifica; **bld-tdd-dev** implementa e atualiza status no mesmo arquivo.

## Guia — spec como fonte da verdade da sessão

Tudo o que for **decidido** durante o uso deste comando e que altere o entendimento do trabalho — **decisões** (desenho, escopo, trade-offs), **requisitos acrescidos** ou reformulados, **regras** ou critérios de aceite ajustados, descobertas que viram requisito, ou equivalente — **deve** ser refletido no **spec ativo** (`docs/specs/tdd/...` ou path indicado). **Proibido** deixar isso só na conversa: o markdown do spec permanece o contrato rastreável.

**Como alterar o spec** — aplicar as **mesmas diretrizes** do comando **`/bld-tdd-doc`** (`~/.cursor/commands/bld-tdd-doc.md`), em particular: RFs numerados e alinhados à tabela TDD da fase correta; secção **`## Decisões tomadas`** com bullets **D1, D2…** para decisões; preferir **novos** RF/D/PC e **novas linhas** na tabela em vez de reescrever histórico, salvo correção explícita ou contradição insustentável; fase **Pós-implementação** para achados do ciclo de implementação; **`## Registros pós-conclusão do spec`** (**PC1, PC2…**) após o documento estar **`concluído`**, para bugs ou ajustes em reabertura; checklist e coerência de marcadores RED/GREEN com `concluídos/total` nos cabeçalhos de fase; antes de gravar, rever o checklist desse comando no trecho afetado.

**Encaixe rápido** — decisão de processo ou produto → **Dn**; novo comportamento a testar → **RF** + linha na tabela TDD (e alinhar RED/GREEN); achado durante QA/manual no mesmo ciclo de entrega → fase **Pós-implementação**; após spec **concluído**, manutenção ou bug fora do ciclo original → **PCn**. Se a mudança for só de texto do spec, pode ser gravada neste chat; continua a valer o restante deste comando (por exemplo, **menu 1–7** e **commit** de código só nas rotas já definidas).

---

## 1. Escolha de modo (obrigatória a cada ativação)

Após **Caveman (início)** quando aplicável, apresentar a pergunta de modo **sempre com opções numeradas** (ex.: **1** Por RF, **2** Por fase) antes de qualquer outro passo — em toda ativação,
início ou retomada. Aguardar resposta por **número** ou pelo rótulo explícito correspondente; nunca inferir pelo histórico.

**Retomada explícita** — quando o usuário indicar que deseja **continuar o processo** após pausa ou nova conversa (ex.: *resume*, *resumir*, *reabrir*, *retomar*, *continuar o `/bld-tdd-dev`*, *seguir de onde parou*, equivalentes em PT/EN): na **primeira** resposta do agente a esse pedido, apresentar **somente** a pergunta de modo (numerada). **Proibido** na mesma mensagem (ou antes da resposta ao modo) apresentar também o **menu 1–7**, pedir escolha do menu, avançar marcos ou sugerir commit. Depois que o modo for escolhido, retomar o fluxo a partir do ponto correto do spec; o menu 1–7 é oferecido **automaticamente** só nos marcos das seções 3 e 4 (e **republicado na íntegra** se o usuário pedir explicitamente — seção 4), nunca empilhado com a pergunta de modo em retomada.

**Ativação que não é retomada** — primeira invocação de `/bld-tdd-dev` na thread ou continuação **já** com modo respondido na mesma sessão: seguir fluxo normal; a regra “só modo” acima vale para o **primeiro** turno após pedido de retomada, não para cada micro-passo do trabalho.

| | Por RF | Por fase |
|---|---|---|
| Granularidade | Uma linha por vez | Todas as linhas da fase em lote |
| Menus 1–7 | Após Confirmar RED e após Confirmar GREEN de cada linha; fim de fase | Após fechar o pacote RED (marco **(1)**) e após fechar o pacote GREEN (marco **(2)**) |
| Pausa entre linhas | — | Nenhuma *dentro* de cada onda de escrita nem *entre* linhas nas ondas Confirmar; seguir a sequência **Por fase** abaixo sem paradas para autorização |

---

## 2. Ciclo de quatro passos (por linha)

Ordem obrigatória; nunca inverter nem pular:

1. **Escrever RED** — **nenhum arquivo de implementação do projeto pode ser alterado**
   (código de produção, app, lib, jobs, migrations, views/rotas/handlers de entrega ao
   usuário, config de runtime da aplicação, etc.). Criar/ajustar **apenas** o que for
   indispensável para o teste **existir e ser executável** (arquivo de teste,
   factories/fixtures/helpers de teste, `require`/`import` de suporte ao teste se o
   projeto assim exigir). **Proibido** refatorar fora do teste, "preparar" implementação
   ou tocar em qualquer arquivo que não seja estritamente necessário para esse fim.
   **Zero produção.**
   → Antes e após qualquer escrita: aplicar `~/.cursor/commands/skills/tdd-red-guard.md`
   → Ao definir qualquer identificador de teste: aplicar `~/.cursor/commands/skills/tdd-test-naming.md`
   → Em projetos Minitest: aplicar `~/.cursor/commands/skills/tdd-minitest-red.md`

2. **Confirmar RED** — rodar só esse teste; saída colada mostrando **falha**;
   o agente principal revisa aderência ao RF inline.

3. **Escrever GREEN** — produção mínima: apenas o exigido pelo RED; sem abstrações
   antecipadas, refatoração ou código além do teste alvo.
   → Ao escrever ou renomear testes durante GREEN: reaplicar `~/.cursor/commands/skills/tdd-test-naming.md`

4. **Confirmar GREEN** — rodar mesmo teste; saída colada mostrando **aprovação**;
   o agente principal revisa inline; atualizar spec (status, path do teste, `n/m`).

---

## 3. Fluxo por modo

### Por RF

```
Escrever RED → Confirmar RED → menu 1–7
→ Escrever GREEN → Confirmar GREEN → menu 1–7
→ próxima linha
```

Ao encerrar a fase: **revisão sênior** (code review em nível sênior) do pacote da fase na mesma sessão — continua obrigatória; não apontar arquivo ou skill específicos para esse passo → menu 1–7.

### Por fase

**Pacote RED** (em todo o pacote: **nenhum arquivo de implementação do projeto pode ser
alterado**; vale a mesma regra da etapa **Escrever RED** na seção 2 — **só** mudanças
indispensáveis para os testes existirem; **zero produção**):

1. **Onda Escrever RED** — cobrir todas as linhas; sem perguntas *entre* linhas
   *dentro* da onda.
   → Antes e após cada escrita: aplicar `~/.cursor/commands/skills/tdd-red-guard.md`
   → Ao definir identificadores: aplicar `~/.cursor/commands/skills/tdd-test-naming.md`

2. **Onda Confirmar RED** — sequencial, sem perguntas entre linhas; para cada linha,
   rodar **só** o teste alvo; saída colada com **falha**; o agente principal revisa aderência
   ao RF inline.

3. **Revisão sênior** — o agente principal realiza code review em nível sênior do pacote RED (testes + aderência observada nas confirmações); escopo RED; passo obrigatório, sem skill ou arquivo nomeado.
   → Veredicto REPROVADO bloqueia o marco **(1)**; resolver bloqueantes antes de prosseguir.

4. Menu 1–7 (marco **(1)**).

**Pacote GREEN** (só após pacote RED validado e marco **(1)** autorizar):

1. **Onda Escrever GREEN** — cobrir todas as linhas; sem perguntas entre linhas.

2. **Onda Confirmar GREEN** — sequencial, sem perguntas entre linhas; para cada linha,
   rodar **só** o teste alvo; saída colada com **aprovação**; o agente principal revisa inline;
   atualizar spec por linha (`n/m`, status, path do teste).

3. **Revisão sênior** — o agente principal realiza code review em nível sênior do pacote GREEN; escopo GREEN; passo obrigatório, sem skill ou arquivo nomeado.
   → Veredicto REPROVADO bloqueia o marco **(2)**; resolver bloqueantes antes de prosseguir.

4. Menu 1–7 (marco **(2)**).

---

## 4. Menu 1–7 (única trilha para commit e avanço)

Apresentar exatamente nos marcos de fim de iteração. Em **retomada explícita** (seção 1), **não** apresentar este menu na mesma mensagem que a pergunta de modo; só depois da escolha do modo e quando o fluxo chegar de fato ao marco.

**Pedido explícito de menu** — Quando o usuário pedir o menu de iteração em mensagem dedicada ou claramente principal (ex.: *menu*, *menu 1-7*, *menu 1–7*, *menu iteração*, *mostrar menu*, *opções do menu*, equivalentes óbvios em PT/EN), **exibir na íntegra** o menu 1–7 abaixo (todos os itens numerados). Isso **não** substitui escolha **1**–**7** para avanço ou `git commit`; só republica o texto do menu e aguarda número ou rótulo explícito. **Exceção:** na **primeira** resposta após **retomada explícita** (seção 1), prevalece *só* a pergunta de modo — não empilhar este menu na mesma mensagem; após o modo escolhido, um pedido *menu* no marco adequado exibe 1–7 completo.

Nenhum atalho substitui a **escolha numerada** para commit ou avanço de marco. **`git commit` é proibido** até o usuário **confirmar por escolha explícita no menu** (número **1** ou **5**). Não inferir "sim", não comitar no fim da mensagem, não comitar por conveniência. Sem escolha **1** ou **5**, **zero** `git commit`.

1. **Comitar e continuar** — somente após o usuário escolher **1** neste menu:
   stage completo dos artefatos da rodada + `git commit` com mensagem descritiva;
   exibir saída; avançar para o próximo marco. Se working tree vazio, informar e
   avançar sem commit.
2. **Revisar manualmente** — parar; aguardar próximo input; sem commit;
   ao voltar, se o input for de **retomada explícita** (seção 1), **só** pergunta de modo na primeira resposta; caso contrário, quando o fluxo estiver no marco do menu, reapresentar 1–7.
3. **Revisão sênior extra** — segunda passagem de code review em nível sênior na mesma sessão; escopo conforme solicitado; sem skill ou arquivo nomeado;
   exibir achados; sem commit automático; reapresentar 1–7.
4. **Discutir requisito** — ajustar spec; perguntar se deseja implementar antes de
   codar; sem commit; ao decidir versionar, avançar ou aplicar sugestões do revisor,
   escolher a opção numerada correspondente (ex.: 1, 5, 6 ou 7).
5. **Só comitar** — somente após o usuário escolher **5** neste menu: `git commit`
   descritivo; não avançar para o próximo marco; na volta, **retomada explícita** (seção 1) → só pergunta de modo primeiro; senão, reapresentar 1–7 no marco.
6. **Continuar sem comitar** — avançar imediatamente para o próximo marco sem commit.
7. **Aceitar sugestões do revisor sênior** — aplicar no código e/ou no spec as
   sugestões e achados da **última** revisão sênior desta sessão (inclui revisão
   extra, se for a mais recente); sem `git commit` automático; ao terminar,
   reapresentar 1–7 no marco (retomada explícita: seção 1 — não empilhar com pergunta de modo).

Não usar `tester-rails`.

---

## 5. Regras

- **Commit** — `git commit` apenas depois do menu 1–7 apresentado e do usuário
  escolher **1** ou **5**. Nenhuma outra rota.
- **Escrever RED** — durante a escrita do RED, **nenhum arquivo de implementação do
  projeto** pode ser alterado; em qualquer modo, nenhum arquivo ou linha fora do
  estritamente necessário para o(s) teste(s) existir(em) e rodar(em): sem produção, sem
  refatoração colateral, sem "adiantar" GREEN. Se houver dúvida, não alterar.
  → Dúvida sobre escopo de um arquivo: consultar `~/.cursor/commands/skills/tdd-red-guard.md`
  antes de escrever.
- **Um teste por vez** — nunca rodar suite completa; só o teste alvo.
- **Novo requisito** — inserir no spec primeiro; confirmar antes de implementar.
- **Nomes de testes** — português, comportamento observável, sem abreviações, referência
  ao RF obrigatória. Critérios completos em `~/.cursor/commands/skills/tdd-test-naming.md`.
- **Progresso** — manter `n/m` na tabela do spec e no chat.
