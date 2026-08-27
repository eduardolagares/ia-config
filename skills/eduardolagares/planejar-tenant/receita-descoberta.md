# Receita de descoberta

Não é replace do Vitória. Um plan por invocação (Assinaturas ≠ checkout). Idioma pt-BR. `.vitoria.plan.md` intocado.

Estilo, negócio e brief **partilhados** vêm da **fonte** em `$INGRESSOS/docs/plans/<id>/` (working tree ou branch `dev-plan-<id>`). **Não** colar esses ficheiros no plan. **Não** ler `.<id>.plan.md` de outro host. **Não** ler o home da skill.

## Passos (neste clone)

1. **Master** — grep `vitoria` / `sportrecife` / `cruzeiro` em `app/`, `config/`, `public/`, `lib/` **deste** clone. Excluir `test/`, `node_modules/`, `vendor/`. **Incluir** `ingressos-repo/` e `baladapp-react-components/` se estiverem neste tree — são toques **deste** plan (o operador pina na implementação). Não tratar `ingressos-repo/docs/plans/<id>/` como task de produto (é a fonte). Cópia por ficheiro: Sport → Cruzeiro se o Sport não tiver → Vitória se nenhum dos dois tiver. **Não** perguntar qual tenant espelhar.
2. **`.vitoria.plan.md`** — índice de **temas** deste repo (amplitude). Sempre consultar se existir. Não copiar tasks `[x]`. Melhorar clareza da **ordem de onboarding** em relação ao Vitória.
3. **Estilo e negócio** — ler `style.md` e `negocio.md` da fonte. No plan: ponteiros + resumo mínimo (bloco colável do guia, slugs se cadastro neste clone). **Não** anexar os documentos. Se `style.md` for stub de **skip** (ou `brief.md` `style: skip`): **não** colar `:root` / `theme_colors` / mailer de marca; adiar essas tasks; mockups cinza ok.
4. **Brief** — ler `brief.md` da fonte. No plan: secção **Neste clone** ([template-plan.md](template-plan.md)) com cadastro **deste** tree. `nome_comercial` / `nome_clube` da entrevista, não do `style.md`. `filtro_tipo_assinatura`: se o brief não tiver, inferir de `negocio.md` (1 tipo → `nao`; homem/mulher/jovem → `sim`). Tasks/testes de filtro **só** se `sim`.
5. **Cadastro canónico (seed)** — só se este plan marcar `cadastro_neste_repo: sim`: receita completa (`GrupoEmpresa`, `Empresa`, `Dominio`, seed, mailer `when '<id>'`). Task de seed **só aqui**. Planos/preços conforme `negocio.md` (não duplicar tabelas). Se `nao`: **não** copiar JSON/`ensure!`/`planos.json`/blob de `Empresa.config`/mailer de marca; **não** abrir o outro plan de host. Uma linha com o `cadastro_nota`. `config.hosts` **deste** Rails continua neste plan. Toques de `ingressos-repo/` que **não** são cadastro (ex. imagens de relatório no adm) continuam neste plan.
6. **Depois das tasks de produção:** counterpart de teste do espelho **neste** repo.

Preencher [template-plan.md](template-plan.md) com o que esta varredura achar. Não inventar seções de topo. **Não** criar anexos de estilo/negócio neste ficheiro. Omitir **Regras pendentes** se a regra já estiver no `brief.md` da fonte.

O plan deixa **exclusões e adiamentos explícitos**, sem o executor ter de inferir. Inclui **checklist de prontidão** para execução isolada (**este plan + a fonte**).

**Landings de planos:** **não** gerar tasks nem testes para copiar `app/views/<espelho>/planos/beneficios/<slug>/` (ex.: `cruzeiro/planos/beneficios/cabuloso`) se o brief tiver `landing_planos: fora` **ou** se o operador não tiver dado os dados das landings.

Assets: preencher as duas listas de [fluxo-assets.md](fluxo-assets.md) a partir do grep de `logo-site`, `images/`, `public/imagens/` neste clone. Origem da wordmark = logo da fonte, não `docs/plans/` do host.

## Testes no plan

Não há seção “Testes” nem pergunta. O teste entra **na task de produção** só se: (1) o toque cria/altera tela, rota, controller de tenant ou componente React com superfície própria; **e** (2) o espelho neste repo já tem counterpart **ou** a superfície está órfã. Um status HTTP, nome em português; ou “estender `foo_test.rb` com `santos`”.

Não entra: pack/SCSS/mockup/fonte/`config.hosts` de dev; whitelist já coberta pelo request da tela pai; suíte de planos/cancelar do Vitória; teste de “não explodiu”. Host em `test.rb` (padrão auth2) é config, se o espelho local já o tiver.

| Toque típico | Teste no plan? |
|---|---|
| checkout/auth2: pack + tema + hosts | Não |
| assinaturas: `Santos::IndexController` + rotas (se **não** adiado) | Sim: par do espelho (index/páginas públicas). Não os 20 request de negócio |
| react-components neste tree: ramo com spec no espelho | Sim, Vitest em `js-tests/` |
| só mailer/hosts | Não |

## Git (plan vs implementação)

Skill não puxa, não commita, não atualiza submodule, não cria `dev-<id>`.

No plan, uma linha de regra — não uma task de pin:

> Implementação: o operador abre `dev-<id>` **depois** deste plan validado; aí alinha submodules (`ingressos-repo`, `baladapp-react-components`, …) nos commits de código. Este plan não pina ponteiro.
