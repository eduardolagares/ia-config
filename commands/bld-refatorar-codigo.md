---
VERSION: "1.0.2"
description: "Refatora ficheiro, pasta, trecho ou branch vs master com regras baladapp em rules/; preserva comportamento; testes focados."
---

# `/bld-refatorar-codigo`

## Meta

- Densidade do texto ≠ relaxar obrigações: **todas** as regras aplicáveis em `rules/` (e `karpathy-guidelines` se instalada) entram na refatoração.
- Refatorar = melhorar estrutura e alinhamento às regras **sem** alterar comportamento observável, salvo se o utilizador pedir mudança funcional na mesma mensagem.

## Modo

- **Write:** permitido e esperado editar ficheiros no escopo.
- **Preservar comportamento** salvo pedido explícito de mudança funcional.

## Entrada do utilizador

O utilizador indica **uma ou mais** formas (podem combinar, ex.: branch + ficheiro dentro do diff):

| Modo | Exemplo | Resolução do escopo |
|------|---------|---------------------|
| **Ficheiro** | `app/models/order.rb`, `@path` no chat | Esse ficheiro + dependências mínimas de extract/move |
| **Pasta** | `app/domains/orders/` | Ficheiros de código na pasta (`.rb`, templates, testes espelhados); **não** subir à árvore inteira salvo import direto do refactor |
| **Trecho** | seleção no editor, bloco colado, `@ficheiro:10-40` | Localizar ficheiro e símbolo (classe/método/módulo) que contém o trecho; escopo = trecho + unidade envolvente mínima |
| **Branch vs master** | `branch feature/foo`, `comparar com master` | Diff `master...<branch>` → paths alterados; escopo = esses paths (ver abaixo) |

Sem nenhuma das formas acima → pedir ficheiro, pasta, trecho ou branch; **não** editar até ter escopo.

### Branch vs master

1. Branch informada: `<branch>` (com ou sem `origin/`).
2. `git fetch origin` se rede disponível.
3. Base fixa: **`master`** — `origin/master` se existir; senão `master` local.
4. Confirmar branch: `git rev-parse --verify origin/<branch>` ou local `<branch>`.
5. Listar escopo: `git diff <base>...<branch> --name-only` (equivalente: `<base>...origin/<branch>`).
6. Incluir no escopo: paths do diff em `app/`, `lib/`, `test/`, `db/migrate/`, views/components — excluir lockfiles, assets gerados, `vendor/`, salvo pedido explícito.
7. Trabalhar sobre o **working tree atual** (idealmente checkout em `<branch>`). Se o checkout for outro branch, avisar numa linha e refactorar os paths como existem no disco **ou** pedir checkout — não mudar branch sem pedido.
8. Ler diff por ficheiro (`git diff <base>...<branch> -- <path>`) para priorizar hunks tocados; refactor alinha regras **em todo o ficheiro** no escopo, não só nas linhas do diff, mas **sem** drive-by noutros ficheiros fora da lista.

Branch + ficheiro/pasta/trecho: intersectar — só o subconjunto pedido que também apareça no diff (ou o path explícito se o utilizador nomear ficheiro dentro do branch).

## Escopo

1. Resultado da resolução de entrada acima — **só** esses ficheiros/símbolos e dependências mínimas (extract class, mover para use case, etc.).
2. Proibido refactor drive-by fora do escopo.

## Fontes (ordem fixa)

1. Código no escopo + testes contraparte.
2. `rules/` do projeto (instaladas em `.cursor/rules/` ou `~/.cursor/rules/` como `baladapp-*.mdc`).
3. `karpathy-guidelines.mdc` (instalada pelo `install/`).
4. Convenções observáveis no código circundante.

Para cada ficheiro no escopo: ler **integralmente** cada regra aplicável (secção **Regras — roteamento** abaixo). Não resumir de memória.

## Regras — roteamento

Paths no repo ia-config: `rules/baladapp-*.mdc`. Após `install/`: `.cursor/rules/baladapp-*.mdc`.

Karpathy (`karpathy-guidelines.mdc`) aplica-se a **todo** refactor — simplicidade, diff cirúrgico, sem over-engineering.

### Tabela por camada

| Regra | Ficheiro | Quando aplicar |
|-------|----------|----------------|
| Ruby | `baladapp-ruby.mdc` | Qualquer `.rb`, `.rake`, `.ru`, `Gemfile`, `Rakefile`, templates Ruby |
| Clean code Rails | `baladapp-clean_code_ruby.mdc` | Idem Ruby — time zones, callbacks, AR boundaries, erros |
| Implementation ↔ testes | `baladapp-implementation.mdc` | Qualquer alteração em `app/**`, `lib/**` — **sempre** no fecho |
| Controllers | `baladapp-controllers.mdc` | `app/controllers/**`, testes de controller/integration ligados |
| Use cases | `baladapp-use_cases.mdc` | `app/domains/**/use_cases/**` |
| Query objects | `baladapp-query_objects.mdc` | `app/domains/**/queries/**` |
| Rule objects | `baladapp-rule_objects.mdc` | `app/domains/**/rules/**` |
| Models | `baladapp-models.mdc` | `app/models/**`, `test/models/**` |
| Migrations | `baladapp-migrations.mdc` | `db/migrate/**` |
| Views | `baladapp-views.mdc` | views, ViewComponents, presenters, helpers |
| Testes Rails | `baladapp-writting-tests-rails.mdc` | `test/**/*.rb` no escopo |
| Testes React | `baladapp-writting-tests-react.mdc` | `**/js-tests/**/*.vitest.{ts,tsx}` |

### Onde colocar código

| Situação | Destino | Regra |
|----------|---------|-------|
| Mutação / orquestração multi-passo | Use case | `baladapp-use_cases.mdc` |
| Leitura composta (filtros, joins, agregação read-only) | Query object | `baladapp-query_objects.mdc` |
| Pergunta de domínio sim/não ou primitivo | Rule object | `baladapp-rule_objects.mdc` |
| Filtro one-liner reutilizável no model | Scope no model | `baladapp-models.mdc` |
| HTTP, auth, params, render | Controller magro | `baladapp-controllers.mdc` |
| Formatação para UI | Presenter / ViewComponent | `baladapp-views.mdc` |

### Ordem de leitura (ficheiro multi-camada)

1. `baladapp-implementation.mdc`
2. Regra da camada principal
3. `baladapp-ruby.mdc` + `baladapp-clean_code_ruby.mdc`
4. Regras das camadas de destino se houver extração
5. `baladapp-writting-tests-rails.mdc` ou `baladapp-writting-tests-react.mdc` nos testes tocados

## Fluxo

```
Task Progress:
- [ ] 0. Resolver entrada (ficheiro | pasta | trecho | branch vs master)
- [ ] 1. Inventariar escopo (paths, camada, testes ligados)
- [ ] 2. Mapear regras aplicáveis (secção Regras — roteamento)
- [ ] 3. Listar violações por regra (interno; não inflar chat)
- [ ] 4. Refatorar — diff mínimo, uma preocupação de cada vez
- [ ] 5. Sincronizar testes (baladapp-implementation + writting-tests-*)
- [ ] 6. Rodar testes focados nos ficheiros alterados
- [ ] 7. Responder ao utilizador (formato abaixo)
```

### Passo 0 — Resolver entrada

- Identificar modo(s): ficheiro, pasta, trecho, branch.
- Modo **branch:** executar secção *Branch vs master*; guardar lista de paths e resumo do diff (não colar diff integral no chat).
- Modo **trecho:** se path desconhecido, `rg`/busca por assinatura ou pedir ficheiro ao utilizador.

### Passo 1 — Inventário

- Classificar cada path: controller, use case, query, rule object, model, migration, view/component, presenter, teste Rails, teste React.
- Localizar testes contraparte (`test/...` ↔ `app/...`; ver `baladapp-implementation.mdc`).
- Modo **branch:** incluir testes contraparte dos paths do diff mesmo que o diff não os liste.

### Passo 2 — Regras

- **Sempre** (qualquer `.rb` no escopo): `baladapp-ruby`, `baladapp-clean_code_ruby`, `baladapp-implementation`.
- **Por camada:** secção *Regras — roteamento*.
- **Extração:** lógica de negócio fora do sítio certo → mover para use case / query / rule object conforme regra da camada de destino; aplicar também as regras do destino.

### Passo 3 — Plano de refactor (interno)

Por violação: regra citada (path) → alteração concreta. Prioridade:

1. Fronteiras erradas (negócio em controller/model/view/callback).
2. Contratos de API de domínio (use case / query / rule object).
3. Estilo Ruby e clean code.
4. Views e apresentação.

### Passo 4 — Edição

- Diff **cirúrgico**; match estilo do ficheiro.
- Sem features novas, sem error handling especulativo, sem abstrações de uso único.
- Migrations no escopo → seguir `baladapp-migrations.mdc`; preferir refactor de código a migration salvo pedido explícito.

### Passo 5 — Testes

- Comportamento preservado → ajustar só setup/estrutura se o refactor exigir; **proibido** enfraquecer asserções.
- Extractions / renomeações → atualizar paths e referências nos testes contraparte.
- Testes novos só se o refactor expuser comportamento antes sem cobertura direta.

### Passo 6 — Verificação

- Rodar testes **focados** nos ficheiros tocados (ficheiro ou filtro por linha/nome) — não suite completa salvo pedido.
- Falha → corrigir antes de declarar concluído.

## Saída para utilizador

- **Língua:** pt-BR (narrativa); não traduzir paths, símbolos, logs, output de ferramentas.
- **Proibido:** parágrafos longos; colar ficheiros inteiros; elogio genérico.

### Formato

```text
Refatoração concluída — <escopo resumido>
Entrada: <ficheiro|pasta|trecho|branch <nome> vs master> — <N> ficheiro(s)

Alterações:
- <path>: <uma linha — o que mudou e regra baladapp-* citada>

Testes: <comando rodado> → <passou|falhou + resumo seule>
```

Se parcial ou bloqueado:

```text
Refatoração incompleta — <motivo>

Feito:
- ...

Pendente:
- ...

Próximo passo: <ação concreta>
```

Secção vazia de alterações → `Nenhuma alteração necessária — código já alinhado às regras aplicáveis.`

## Proibido (global)

- Refatorar fora do escopo indicado.
- Mudar comportamento sem pedido explícito do utilizador.
- `git commit` / `git push` salvo pedido na mesma mensagem.
- Omitir sincronização de testes quando `baladapp-implementation.mdc` se aplica.
- Declarar concluído sem rodar testes focados quando testes contraparte existem.

## Comandos relacionados

- Revisão read-only pós-refactor: `/bld-code-review`
- Ciclo TDD com refactor explícito na fase GREEN: `/bld-tdd-dev`
