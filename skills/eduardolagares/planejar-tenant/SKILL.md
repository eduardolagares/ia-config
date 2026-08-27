---
name: planejar-tenant
description: >-
  Gera plan enxuto em docs/plans/<id>/ neste clone. Brief, estilo, negócio e
  logo ficam na fonte em ingressos-repo/docs/plans/<id>/. Entrevista inicial:
  nomes (produto + clube), estilo, logo, negócio, FAQ, adiamentos. Geração
  posterior consulta a fonte e só escreve o plan. Não implementa, não commita.
  Use com /planejar-tenant.
disable-model-invocation: true
VERSION: "0.8.3"
---

# planejar-tenant

Gera o **plan deste clone** (enxuto). Brief, estilo, negócio e logo são a **fonte** — vivem no **ingressos-repo**, não neste plan. Não implementa, não commita. Um operador.

**Pacote:** `skills/eduardolagares/planejar-tenant/` — instalada pelo `install/` em `{destino}/skills/eduardolagares/planejar-tenant/` (Cursor ou `~/.agents`).

Dois sítios, papéis distintos:

```
# Fonte (partilhada entre clones) — git do ingressos
ingressos-repo/docs/plans/<id>/
  brief.md
  style.md
  negocio.md
  faq.md                # opcional — copy FAQ do site; mock a revisar; não vai para negocio.md
  logo.<ext>            # só se anexou; png | jpg | jpeg | svg | webp

# Plan (deste clone) — git do host
<clone>/docs/plans/<id>/
  .<id>.plan.md         # tasks/config deste tree; aponta para a fonte
```

Exemplo: fonte `ingressos-repo/docs/plans/santos/{brief,style,negocio,logo.png}`; plan `docs/plans/santos/.santos.plan.md`.

**Inicial** (fonte ainda não existe): entrevista neste clone → grava a fonte no ingressos → grava o plan aqui.

**Posterior** (fonte já existe na branch do ingressos): **não** entrevista; lê a fonte; só grava o plan deste clone.

O plan cobre **este** tree (grep + `.vitoria.plan.md` daqui, inclusive `ingressos-repo/` e `baladapp-react-components/` se existirem **neste** clone). Sem ordem entre projetos, sem lista de repos. Pin de submodule = operador na branch de **implementação** (`dev-<id>`), depois do plan validado.

**Espelho (fixo — não perguntar):** ficheiros deste clone a partir de Sport, Cruzeiro e Vitória, por ficheiro: Sport; Cruzeiro se o Sport não existir; Vitória só se nenhum dos dois tiver o ficheiro. Amplitude de **temas:** `.vitoria.plan.md` **deste** repo (se existir). Não há escolha de “qual tenant espelhar”.

## Artefatos e irmãos

Ler só o que a invocação precisa. Paths relativos a esta skill (`{destino}/skills/eduardolagares/planejar-tenant/`): **só** templates e receitas — nunca `tenants/`.

| O quê | Onde |
|---|---|
| Fonte (brief + estilo + negócio + logo) | git do **ingressos**: `docs/plans/<id>/` na `dev-plan-<id>` |
| Plan enxuto | `<clone>/docs/plans/<id>/.<id>.plan.md` na `dev-plan-<id>` **deste** host |
| Formato do guia | [formato-tenant-style.md](formato-tenant-style.md) |
| Fluxo de assets | [fluxo-assets.md](fluxo-assets.md) |
| Como descobrir tasks | [receita-descoberta.md](receita-descoberta.md) |
| Forma da fonte `brief.md` | [template-brief.md](template-brief.md) |
| Forma do plan | [template-plan.md](template-plan.md) |
| Texto das perguntas | [entrevista.md](entrevista.md) |

Código / ponteiro de submodule: operador, no commit de implementação do host.

**Proibido:** pasta `tenants/` no clone; gravar brief/estilo/negócio/logo no home da skill **ou** no `docs/plans/<id>/` do host; embeber anexos integrais no plan; ler o `.<id>.plan.md` de **outro host** (assinaturas, checkout, …). **Permitido:** ler/escrever a fonte no git do ingressos (localizar abaixo).

## Pré-condição

Clone da vez na `master` atualizada. **Não** fazer `git pull` / `submodule update`.

## Invocação

```
/planejar-tenant <identificador>
```

Argumento = token do **tenant** (`santos`). Projeto = pasta da IDE. Nunca passar repo (`checkout`, `assinaturas`).

```
# IDE em assinaturas — identificador novo
/planejar-tenant santos
  → entrevista + fonte em ingressos-repo/docs/plans/santos/
    + docs/plans/santos/.santos.plan.md (enxuto)

# IDE em checkout — mesma fonte já na branch do ingressos
/planejar-tenant santos
  → sem entrevista; lê a fonte; só docs/plans/santos/.santos.plan.md
```

- Sem argumento → perguntar o identificador; **não** usar o nome da pasta.
- Argumento = nome de clone (ver recusa abaixo) → recusar: abre a IDE nesse clone e passa o clube.
- Token inválido (`sport_recife`, `ec-santos`) → recusar.
- No passo de estilo: sem anexo `tenant_style` no formato completo **e** sem **skip** → **parar**. **skip** (teste) continua a entrevista com stub. Não aceitar hex soltos. Brief (nomes) pergunta-se **antes** do estilo.

**IDE no clone cujo plan se quer.** Guarda-chuva → parar. Workspace cujo toplevel **é** o ingressos → parar: abre o host (assinaturas, checkout, …). A skill **escreve/lê** a fonte *dentro* do git do ingressos, mas o plan é sempre do host.

## Identificador

Token `[a-z0-9]+` (sem `_` nem hífen): `santos`, `sportrecife`, `vitoria`. Recusar `sport_recife`, `EsporteClubeSantos`. Não chamar de snake_case.

Tem de bater com `identificador:` do tenant_style (inicial) / `brief.md` (posterior).

O mesmo token: hosts, packs, pastas, `when '…'`, `GrupoEmpresa`. Classe Ruby = PascalCase do token (`Santos`, `Sportrecife` — não `SportRecife`).

- Plan do host **e** fonte no ingressos: branch `dev-plan-<id>` (`dev-plan-santos`).
- Implementação (fora da skill): `dev-<id>` (`dev-santos`).
- Proibido: `dev-tenant`, `dev-<id>-plan`, `dev-vitoria-plan`.

**Recusar argumento** se for nome de clone, não tenant: `assinaturas`, `assinaturas-adm`, `auth2`, `auth-adm`, `checkout`, `vitrine-rails`, `produtor`, `ingressos`, `ingressos-api`, `comissarios`, `facial-biometria`, `virtual-waiting-room`, `custom-errors`, `account`, `site-v2`, `baladapp-react-components`, `comissarios-api`, `comissarios-react`, `baladapp-react`, `relatorio-api`, `wait-to-redirect`, `produtor-react-native-app`. **Não** mostrar esta lista na entrevista.

## Detectar o clone

No **primeiro turno**, no workspace atual:

1. `git rev-parse --show-toplevel` e `git remote get-url origin`.
2. Sem git, ou o cwd tem **vários** filhos com `.git` (guarda-chuva) → **parar:** abre o clone do projeto.
3. Basename do toplevel é `ingressos` / `ingressos-repo` **ou** o path do toplevel contém `/ingressos-repo` como **root** (não como submodule de um host) → **parar:** abre o root do host cujo plan se quer.
4. Caso contrário: este toplevel **é** o clone. Nome do repo = basename do toplevel (ou origin). Seguir.

Não recusar plan porque falta `docs/plans/<id>/.<id>.plan.md` noutro **host**.

| Aberto em | Ação |
|---|---|
| Root de um clone host | Modo inicial ou posterior + plan **neste** root |
| Guarda-chuva | Parar: abre o clone do projeto |
| Root do ingressos | Parar: host (assinaturas, checkout, …) |

## Localizar o git do ingressos

Parar no **primeiro** que for um repo git:

1. `<clone>/ingressos-repo` (submodule — típico Assinaturas)
2. Irmão `../ingressos`
3. Irmão `../ingressos-repo`

Chamar esse path de `$INGRESSOS`. **Não** usar o home da skill. **Não** abrir `docs/plans/<id>/.<id>.plan.md` de outro host.

Sem `$INGRESSOS` **e** modo inicial → **parar:** a fonte tem de viver no ingressos; abre um clone com o submodule (Assinaturas) ou o irmão `ingressos`.

## Fonte já existe? (modo)

A fonte está **completa** se existirem os três markdowns (`brief.md`, `style.md`, `negocio.md`). Logo e `faq.md` são opcionais. Copy longa de FAQ (ou equivalente) → `$INGRESSOS/docs/plans/<id>/faq.md`; **não** embeber em `negocio.md` nem no plan do host.

Ordem de consulta (sem `git fetch` / `pull`):

1. Working tree de `$INGRESSOS`: `docs/plans/<id>/{brief,style,negocio}.md`
2. Branch local `dev-plan-<id>`: `git -C "$INGRESSOS" show dev-plan-<id>:docs/plans/<id>/brief.md` (e os outros dois)
3. `origin/dev-plan-<id>` no mesmo `show`

| Resultado | Modo |
|---|---|
| Três ficheiros no working tree **ou** nessa branch | **Posterior** — ler a fonte; **não** entrevistar; **não** escrever na fonte |
| Pasta existe mas falta algum markdown | **Parcial** — entrevistar só o que falta; gravar só os ficheiros em falta; não sobrescrever os que já existem |
| Nada | **Inicial** — entrevista completa; gravar a fonte; gravar o plan |

Ler a fonte: working tree se os ficheiros estiverem lá; senão `git show` na branch (não fazer checkout da branch do ingressos só para ler).

## Plan já existe

Se `docs/plans/<id>/.<id>.plan.md` já existir **neste** clone: avisar, perguntar; **default parar**. Ajuste pontual no chat, sem a skill. Só regenerar se o operador pedir explicitamente. Não usar esse ficheiro para gerar plan noutro host. Não usar o plan de outro host para preencher este.

## Fluxo

Copiar e marcar:

```
- [ ] Identificador válido (não é nome de clone)
- [ ] Clone detectado (não guarda-chuva / não root do ingressos)
- [ ] $INGRESSOS localizado (ou parar se inicial sem git do ingressos)
- [ ] Modo: inicial | parcial | posterior
- [ ] Inicial/parcial: entrevista ([entrevista.md](entrevista.md) — brief → estilo → logo → negócio → FAQ → adiamentos → seed)
- [ ] Posterior: fonte lida (brief/style/negocio; logo se houver)
- [ ] Descoberta deste repo (receita-descoberta.md)
- [ ] Branch dev-plan-<id> no host se tree limpa; senão escrever e pedir checkout -b
- [ ] Inicial/parcial: fonte em $INGRESSOS/docs/plans/<id>/ (+ branch no ingressos se tree limpa)
- [ ] docs/plans/<id>/.<id>.plan.md enxuto neste clone (sem anexos)
```

**Uma pergunta de cada vez** (só no inicial/parcial). Usar o texto de [entrevista.md](entrevista.md) (**negrito** nos termos a preencher). Recomendação numa linha. Estilo / negócio / FAQ: após a resposta, só «Recebido.» — **não** resumir o anexo. Se o anexo **desta** conversa, a fonte no ingressos, ou o código **deste** clone responder, não perguntar.

**Posterior — anunciar e seguir:** «Fonte `<id>` em `$INGRESSOS` (`dev-plan-<id>`). Sem entrevista. A gerar o plan deste clone.»

## Entrevista

**Só** modo inicial (completa) ou parcial (o que falta). **Proibido** no posterior.

**Proibido na entrevista:** perguntar de qual tenant copiar (Sport/Cruzeiro/Vitória) ou se usa `.vitoria.plan.md`; abrir `{destino}/skills/eduardolagares/planejar-tenant/tenants/`; abrir `.<id>.plan.md` de outro host; “já temos isto no Santos das assinaturas”; copiar anexos de outro plan de host; tirar **nome do produto** / **nome do clube** do `style.md`; **resumir** a resposta de estilo / negócio / FAQ antes da próxima pergunta.

Texto e ordem: [entrevista.md](entrevista.md). Resumo:

1. **Token** — só se faltar/inválido.
2. **Brief** — **nome do produto** + **nome do clube** (ex. Sócio Maior do Nordeste / Sport Clube do Recife).
3. **Guia de estilo** — anexo completo **ou** **skip** (teste). Sem anexo e sem skip → **parar**. Paleta/tema vêm do guia; skip → stub, sem improvisar paleta.
4. **Logo** — anexo ou **mock**.
5. **Negócio** — anexo ou texto. Filtro tipo assinatura: **inferir** (1 tipo → não; homem/mulher/jovem → sim). FAQ **não** vai aqui.
6. **FAQ** — anexo/texto **ou** **adiar**.
7. **Adiamentos** — **landings de planos** / **marca** / **outra coisa**. O que não adiar: pedir dados.
8. **Seed neste clone** — sim/não (+ nome do repo se não).

Mockups: **não perguntar** dimensões/arte. Fundo `#999999`, texto `#000000`, rótulo **MOCK — Nome**. Proibido copiar arte de outro tenant.

**Posterior (sem grill):** inferir `cadastro_neste_repo` deste tree (seed/`rotinas_auxiliares` presentes → sim). Espelho: regra fixa (Sport / Cruzeiro / Vitória + `.vitoria.plan.md`). Adiamentos, nomes, logo, FAQ e `filtro_tipo_assinatura`: da fonte `brief.md` / `negocio.md`. Omitir adiamentos que não existem neste clone (ex. landing de planos no checkout).

## Depois da entrevista (ou da leitura da fonte)

1. Seguir [receita-descoberta.md](receita-descoberta.md) **neste** clone, consultando a fonte (não colar anexos no plan).
2. Git (abaixo).
3. **Inicial / parcial:** criar `$INGRESSOS/docs/plans/<id>/` se faltar. Escrever os markdowns em falta: `brief.md` a partir de [template-brief.md](template-brief.md) (nomes da entrevista, não do `style.md`); `style.md` = guia anexado (inteiro) **ou** stub se **skip** ([formato-tenant-style.md](formato-tenant-style.md)); `negocio.md` = negócio colado (inteiro). Logo anexada → `logo.<ext>` **só** na fonte. FAQ colado → `faq.md`; se **adiar**, não criar `faq.md`. Não gravar cópia no host.
4. Criar `<clone>/docs/plans/<id>/` se faltar. Escrever `.<id>.plan.md` a partir de [template-plan.md](template-plan.md). Preencher com **este** repo. Apontar para a fonte; **não** embeber estilo nem negócio. Cadastro canónico: receita completa **só** se este plan marcar cadastro neste clone; senão uma linha com o nome de repo — **sem** abrir outro plan de host. Omitir **Regras pendentes** se a regra já estiver no `brief.md` da fonte.

Idioma do plan: **pt-BR**. `.vitoria.plan.md` intocado. Paths **deste clone** são a partir da raiz do host. Paths da fonte: `ingressos-repo/docs/plans/<id>/…` quando o submodule está neste tree; senão `docs/plans/<id>/…` no git do ingressos, branch `dev-plan-<id>`.

Validação de negócio/marca e “executor segue sem conversa” são **humanas** — a skill só elabora a fonte (inicial) e o plan.

## Git

**Host** — working tree **limpa:** criar branch `dev-plan-<id>` a partir de `origin/master`. Sem `git commit`.

Working tree **suja:** não cria branch; escreve o plan e pede `git checkout -b dev-plan-<id>`.

**Ingressos (só inicial/parcial, ao gravar a fonte):** mesma regra **dentro de `$INGRESSOS`**. Tree limpa → `git -C "$INGRESSOS" checkout -b dev-plan-<id>` a partir de `origin/master` (se a branch ainda não existir). Tree suja → escrever a fonte e pedir o `checkout -b` no ingressos. **Não** alterar o ponteiro do submodule no host (`git add ingressos-repo`). **Não** fazer checkout da branch do ingressos só para **ler** (posterior).

Skill não puxa, não commita, não atualiza submodule, não cria `dev-<id>`.

No plan, uma linha de regra (não task de pin):

> Implementação: o operador abre `dev-<id>` **depois** deste plan validado; aí alinha submodules (`ingressos-repo`, `baladapp-react-components`, …) nos commits de código. Este plan não pina ponteiro.

## Faz / não faz

| Faz | Não faz |
|---|---|
| Inicial: entrevista ([entrevista.md](entrevista.md)); gravar fonte no ingressos | Posterior: reentrevistar estilo/negócio/logo/nomes |
| Plan enxuto neste clone, apontando para a fonte | Embeber guia/negócio/brief integral no plan; logo no `docs/plans/` do host |
| Posterior: ler fonte no `$INGRESSOS` (tree ou `dev-plan-<id>`) | Ler `.<id>.plan.md` de outro host; cache no home da skill |
| Logo anexada → fonte `logo.<ext>` + duas listas no plan | Gerar mockups/favicon/OG; copiar `planos/beneficios/<slug>/` se adiado ou sem dados |
| Branch `dev-plan-<id>` no host (e no ingressos se gravar fonte) | `git commit` / `pull` / `submodule update`; criar `dev-<id>` |
| Dados de negócio que o operador colar **nesta** conversa (inicial) | Consultar site oficial; inventar planos/contato/razão social |
| Seed completo só se este plan marcar cadastro neste clone | Abrir outro plan de host para copiar JSON/`ensure!` |
| Teste na task de produção só se a análise deste repo o exigir | Implementar código; gerar seed Ruby; copiar suíte Vitória; seção “Testes”; pin de submodule |
| Espelho fixo: Sport → Cruzeiro → Vitória + `.vitoria.plan.md` | Perguntar de qual tenant copiar ficheiros |
| **skip** no guia de estilo (teste) → stub + entrevista segue | Parar no estilo quando o operador disser **skip**; copiar paleta de outro tenant |

## Proibido

- Pasta `tenants/` no clone. Brief/estilo/negócio/logo no `docs/plans/<id>/` **do host**.
- Gravar ou ler `{destino}/skills/eduardolagares/planejar-tenant/tenants/`.
- Embeber anexos **Guia de estilo** / **Dados de negócio** no `.<id>.plan.md`.
- Ler `docs/plans/<id>/.<id>.plan.md` de **outro host** (incluindo irmãos `../assinaturas/`, `../checkout/`).
- Sobrescrever ficheiros da fonte que já existem, salvo pedido explícito (modo parcial só preenche buracos).
- Implementar código, testes, mockups gerados ou config de produto (a wordmark na **fonte** é exceção).
- Gerar script de seed Ruby (só documentar receita no plan).
- Copiar `app/views/<espelho>/planos/beneficios/<slug>/` se landing estiver adiada **ou** sem dados do operador (ex. `cabuloso`).
- `git commit`, `git pull`, `submodule update`; `git add` do ponteiro do submodule.
- Editar `.vitoria.plan.md`.
- Sobrescrever `docs/plans/<id>/.<id>.plan.md` sem pedido explícito (default parar).
- Grill de planos / preços / seed; abrir o site oficial.
- Perguntar mockups, paleta, fontes, tema, filtro tipo assinatura, ou de qual tenant copiar ficheiros.
- Usar `produto` / `titulo_padrao` do `style.md` como **nome do produto** ou **nome do clube**.
- Aceitar hex soltos no chat no lugar do tenant_style (no passo de estilo). **skip** não é paleta — é stub de teste.
- Copiar o `style.md` de outro tenant quando o operador disser **skip**.
- Argumento = nome de clone; identificador = nome da pasta.
- Recusar plan porque falta plan noutro **host**.
- Inicial sem conseguir localizar `$INGRESSOS` — parar; não gravar a fonte no host.
- Repetir receita de seed / `GrupoEmpresa` / `Dominio` / `empresas.config` / mailer de marca se este plan marcar cadastro **noutro** repo.
- Seção “Testes” no plan.
- Branch `dev-tenant`, `dev-<id>` (implementação), `dev-<id>-plan`.
