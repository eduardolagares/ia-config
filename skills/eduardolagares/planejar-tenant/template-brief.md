# Brief — tenant <token>

Fonte partilhada (ingressos). Ficheiro: `docs/plans/<id>/brief.md` na branch `dev-plan-<id>` do **ingressos**. Não vai para o plan do host.

Nomes: **entrevista** (não o `style.md`). Filtro: **inferido** do `negocio.md`.

- identificador: <token>
- nome_comercial:          # produto — ex. Sócio Maior do Nordeste
- nome_clube:              # ex. Sport Clube do Recife
- style: completo | skip   # skip = teste, stub em style.md; não improvisar paleta
- logo: ausente | docs/plans/<id>/logo.<ext>   # png | jpg | jpeg | svg | webp; path relativo à raiz do ingressos
- filtro_tipo_assinatura: sim | nao   # 1 tipo → nao; homem/mulher/jovem → sim
- adiamentos_primeira_entrega:
  - landing_planos: fora | sim
  - marca: fora |
  - faq: fora |
- regras:
- regras_pendentes:
  - planos:
  - seed:
  - cadastro:
  - bordero:
  - contato:
  - razao_social:

Estilo: `docs/plans/<id>/style.md`. Negócio: `docs/plans/<id>/negocio.md`. FAQ: `docs/plans/<id>/faq.md` se não adiado. Cadastro **deste** app: secção **Neste clone** no plan do host. Espelho de ficheiros: regra fixa da skill (Sport / Cruzeiro / Vitória + `.vitoria.plan.md`) — não vai para o brief.
