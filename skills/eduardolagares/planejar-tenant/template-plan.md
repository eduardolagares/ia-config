# Plano: Tenant <Nome comercial>

Plano para `<token>` no projeto **<repo>**. A skill não commita. Branch deste artefato: `dev-plan-<id>`. Implementação: `dev-<id>`, depois de validado.

Ficheiro: `docs/plans/<id>/.<id>.plan.md`. Paths **deste clone** são a partir da **raiz deste host**.

**Fonte (brief / estilo / negócio / logo):** `ingressos-repo/docs/plans/<id>/` (branch `dev-plan-<id>`). Se este tree não tiver o submodule, o mesmo path no git do ingressos.
**Ordem de cópia (ficheiros):** Sport; Cruzeiro se o Sport não existir neste repo; Vitória só se nem Sport nem Cruzeiro tiverem o ficheiro. **Não** copiar landings de planos (ver Fora / adiado).
**Amplitude (temas):** `.vitoria.plan.md` deste repo (obrigatório consultar se existir).
**Visual:** [style.md](../../ingressos-repo/docs/plans/<id>/style.md) na fonte — **não** redefinir paleta neste plan. Se o brief tiver `style: skip`, o ficheiro é stub de teste: **não** colar `:root` / paleta; pack visual e mailer de cores ficam em Fora / adiado até o guia real.
**Negócio:** [negocio.md](../../ingressos-repo/docs/plans/<id>/negocio.md) na fonte.
**FAQ:** [faq.md](../../ingressos-repo/docs/plans/<id>/faq.md) na fonte, se existir — mock a revisar; **não** colar neste plan. Se `faq: fora` no brief, omitir este ponteiro.
**Logo:** `ingressos-repo/docs/plans/<id>/logo.<ext>` se existir na fonte (`png`, `jpg`, `jpeg`, `svg` ou `webp`); senão mock.

<!-- Ajustar os links da fonte se o submodule não estiver neste tree: citar path + branch, sem copiar o conteúdo. -->

## Neste clone

- identificador: <token>
- nome_comercial:          # produto — da fonte brief.md (entrevista)
- nome_clube:              # da fonte brief.md (entrevista)
- fonte: ingressos-repo/docs/plans/<id>/   # branch dev-plan-<id>
- style: completo | skip
- logo: ausente | ingressos-repo/docs/plans/<id>/logo.<ext>
- filtro_tipo_assinatura: sim | nao   # inferido do negocio.md
- cadastro_neste_repo: sim | nao
- cadastro_nota:  # se nao: nome do repo onde o seed vive (texto; a skill não abre esse plan)
- adiamentos_primeira_entrega:  # da fonte brief.md + o que for só deste app
  - landing_planos: fora
  - marca:
  - faq:

## Regras

- Identificador `<token>` em hosts, packs, pastas, `when`, `GrupoEmpresa`.
- Multi-tenant: não quebrar clubes existentes.
- Identidade visual: só a fonte `style.md` — não redefinir paleta/tokens neste plan. Se `style: skip`, não inventar hex. **Nome do produto** / **nome do clube**: `brief.md`, não o YAML do estilo.
- Mockups: `#999999` / `#000000`, rótulo **MOCK — <Nome>**. Proibido copiar arte de outro tenant.
- Dados de negócio: só a fonte `negocio.md` + **Regras pendentes** se ainda não estiverem no `brief.md`.
- Filtro tipo assinatura: se `nao`, **não** gerar tasks/testes de filtro nem seed Homem/Mulher/Juvenil. Se `sim`, espelhar o filtro do Sport/Vitória com os tipos do `negocio.md`.
- Commits / submodules: do operador, na branch de implementação.

## Ordem de onboarding

- Sequência explícita (melhorar clareza vs Vitória): cadastro mínimo → domínio/hosts → config → rotas/controllers → layout/pack por último, salvo o que estiver em **Fora / adiado**.
- **Cadastro noutro repo:** não repetir seed. Uma linha com o nome que o operador deu. Neste app: hosts → pack/tema → toques deste clone.

## Configurações

- Hosts / `config.hosts` / `allowed_hosts` (espelho deste repo).
- Pack, tema, whitelist de layout, i18n de nome.
- Identidade visual: **não** colar `:root` / paleta aqui. Uma linha + ponteiro para `style.md` (usar o bloco colável do guia se ajudar o executor, sem o documento inteiro).
- Dados de negócio: slugs/resumo **só** se `cadastro_neste_repo: sim`; senão ponteiro para `negocio.md`.
- **Se cadastro_neste_repo: sim:** Seed / domínios — receita completa (grupo, empresa, `Dominio`, malha de URLs); script Ruby só na implementação. Planos/preços: conforme a fonte `negocio.md`.
- **Se não:** «grupo/empresa/domínio/seed: no repo `<cadastro_nota>`» (texto). Só `config.hosts` **deste** Rails se faltar na malha.

## Fora / adiado (1ª entrega)

- Landings de planos: **não** copiar `app/views/<espelho>/planos/beneficios/<slug>/` (ex.: `cruzeiro/planos/beneficios/cabuloso`) se `landing_planos: fora` **ou** se faltarem dados do operador.
- FAQ / marca / outros listados no brief.

## Tasks

- [ ] …  # uma por toque; teste só ao lado se a análise o exigir; nada do que está em Fora / adiado
- [ ] Seed / domínios — **omitir** se `cadastro_neste_repo: nao`

## Inventário de mockups

- **<repo>-01:** `path` — dimensões do espelho — rótulo **MOCK — <Nome>**

## Assets — propagar a logo

- Só se existir `logo.<ext>` na **fonte**. Wordmark neste repo (ex.: `app/javascript/<id>/images/logo-site.png`, navbar, consultas). Na implementação: copiar a logo da fonte para esses paths.

## Assets — substituir à mão

- Sempre. Tudo que não é a wordmark: fundos, cards `beneficios/`, OG, `icon-social`, favicon, emoticon de erro, heroes de plano.
- Se não houver logo na fonte: incluir também `logo-site` (mock até o operador mandar).

## Checklist de prontidão

- [ ] Executor consegue seguir **este plan** + a **fonte** no ingressos (`docs/plans/<id>/`) sozinho
- [ ] Este ficheiro **não** duplica `style.md` / `negocio.md` / `brief.md` / `faq.md`
- [ ] Identidade visual da fonte não contradiz as tasks
- [ ] Pendências de negócio estão explícitas na fonte (nada inventado)
- [ ] Adiamentos e exclusões estão nesta secção, não implícitos
- [ ] Lista de assets a substituir à mão está preenchida (mesmo com logo)
- [ ] Se cadastro noutro repo: seed/grupo/domínio são uma linha de texto (sem JSON copiado de outro plan)
- [ ] Implementação será noutra branch (`dev-<id>`), com submodules alinhados pelo operador

## Regras pendentes

- Omitir se já estiver no `brief.md` da fonte
- planos: pendente — ver fonte `negocio.md`
