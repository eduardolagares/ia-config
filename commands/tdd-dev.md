---
description: "TDD a partir do spec: ciclo RED/GREEN, modos por RF ou por fase, menu 1-7; commit apenas após escolha explícita no menu (itens 1 ou 5)."
---

# tdd-dev — implementação TDD

Você foi invocado pelo **comando `/tdd-dev`**. Aplique as regras abaixo por completo.

## Caveman (início)

Se a skill **caveman** existir no ambiente (ex.: `~/.agents/skills/caveman/SKILL.md`), **carregue-a e aplique o modo `full`** antes de iniciar o fluxo deste comando (incluindo a seção 1 — escolha por RF ou por fase). Intensidade **full** conforme a própria skill; manter ativa durante a sessão salvo exceções que a skill definir. Se a skill não existir, ignore este bloco.

## Relação com tdd-doc

Seguir o spec ativo em `docs/specs/tdd/AAAA-MM-DD-nome.md` (ou path indicado).
A especificação é produzida pelo comando **`/tdd-doc`** (`~/.cursor/commands/tdd-doc.md`).
**tdd-doc** especifica; **tdd-dev** implementa e atualiza status no mesmo arquivo.

---

## 1. Escolha de modo (obrigatória a cada ativação)

Após **Caveman (início)** quando aplicável, apresentar a pergunta de modo **sempre com opções numeradas** (ex.: **1** Por RF, **2** Por fase) antes de qualquer outro passo — em toda ativação,
início ou retomada. Aguardar resposta por **número** ou pelo rótulo explícito correspondente; nunca inferir pelo histórico.

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

Apresentar exatamente nos marcos de fim de iteração. Nenhum atalho substitui
a escolha numerada. **`git commit` é proibido** até o usuário **confirmar por escolha explícita no menu** (número **1** ou **5**). Não inferir "sim", não comitar no fim da mensagem, não comitar por conveniência. Sem escolha **1** ou **5**, **zero** `git commit`.

1. **Comitar e continuar** — somente após o usuário escolher **1** neste menu:
   stage completo dos artefatos da rodada + `git commit` com mensagem descritiva;
   exibir saída; avançar para o próximo marco. Se working tree vazio, informar e
   avançar sem commit.
2. **Revisar manualmente** — parar; aguardar próximo input; sem commit;
   reapresentar 1–7 ao retomar.
3. **Revisão sênior extra** — segunda passagem de code review em nível sênior na mesma sessão; escopo conforme solicitado; sem skill ou arquivo nomeado;
   exibir achados; sem commit automático; reapresentar 1–7.
4. **Discutir requisito** — ajustar spec; perguntar se deseja implementar antes de
   codar; sem commit; ao decidir versionar, avançar ou aplicar sugestões do revisor,
   escolher a opção numerada correspondente (ex.: 1, 5, 6 ou 7).
5. **Só comitar** — somente após o usuário escolher **5** neste menu: `git commit`
   descritivo; não avançar para o próximo marco; reapresentar 1–7 ao retomar.
6. **Continuar sem comitar** — avançar imediatamente para o próximo marco sem commit.
7. **Aceitar sugestões do revisor sênior** — aplicar no código e/ou no spec as
   sugestões e achados da **última** revisão sênior desta sessão (inclui revisão
   extra, se for a mais recente); sem `git commit` automático; ao terminar,
   reapresentar 1–7.

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
