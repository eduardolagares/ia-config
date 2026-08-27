# Entrevista (inicial / parcial)

**Uma** pergunta de cada vez. Texto curto. **Negrito** nos termos a preencher. Recomendação numa linha. Saltar o passo se o ficheiro correspondente **já** estiver na fonte.

**Ack (estilo, negócio, FAQ):** depois da resposta válida, **só** «Recebido.» (ou «Recebido — skip.» / «Recebido — adiar.»). **Não** resumir, parafrasear nem listar planos/cores/itens do anexo. Validar em silêncio e seguir à pergunta seguinte.

Passos curtos (nomes, logo, adiamentos, seed): ack de uma linha ok; sem relatório.

**Não perguntar:** paleta, fontes, tema, theme-color, mockups, de qual tenant copiar, filtro tipo assinatura (inferir no passo 5).

**Não** tirar **nome do produto** / **nome do clube** do `style.md` — o brief da entrevista manda.

## 1. Token

Só se o argumento faltar ou for inválido.

**Identificador** do tenant (`[a-z0-9]+`, ex. `santos`)?

## 2. Brief — nomes

**Nome do produto** (ex.: Sócio Maior do Nordeste) e **nome do clube** (ex.: Sport Clube do Recife)?

Destino: `brief.md` — `nome_comercial` = produto; `nome_clube` = clube. O resto do brief (tema, `titulo_padrao` visual) pode vir do guia de estilo no passo 3.

## 3. Guia de estilo

Anexa o **guia de estilo** completo (`tenant_style_<id>.md`), ou responde **skip** (teste).

- Anexo válido → gravar inteiro em `$INGRESSOS/docs/plans/<id>/style.md`. Validar com [formato-tenant-style.md](formato-tenant-style.md); `identificador` = token.
- **skip** → gravar o **stub** do mesmo ficheiro (formato-tenant-style.md § Skip); `brief.md` `style: skip`; **não** parar; **não** improvisar paleta; **não** copiar outro tenant.
- Sem anexo e sem **skip** → **parar**. Não aceitar hex soltos.
- Ack: «Recebido.» — sem sumário do guia.

## 4. Logo

Anexa a **logo** (wordmark: `png` `jpg` `jpeg` `svg` `webp`) ou responde **mock**.

Anexo → `$INGRESSOS/docs/plans/<id>/logo.<ext>`. **mock** → lista de substituição. Recusar outras extensões. Não gerar mockups/favicon/OG. Listas: [fluxo-assets.md](fluxo-assets.md).

## 5. Negócio

Cola ou anexa os **dados de negócio** (planos, preços, contato, razão social, hosts/URLs). O que não tiveres: **pendente**. Não abrir o site.

Destino: `$INGRESSOS/docs/plans/<id>/negocio.md`. **Não** misturar FAQ aqui. Ack: «Recebido.» — sem sumário dos planos.

### Inferir filtro (não perguntar)

| No negócio | `brief.md` / plan |
|---|---|
| **1 tipo** (`socio-torcedor` ou outro nome único) | `filtro_tipo_assinatura: nao` — sem tasks/testes de filtro |
| Distinções **homem / mulher / jovem** (ou equivalente) | `filtro_tipo_assinatura: sim` — filtro na vitrine |

## 6. FAQ

Cola ou anexa o **FAQ**, ou responde **adiar** (1ª entrega).

- Texto/anexo → `$INGRESSOS/docs/plans/<id>/faq.md` (não colar em `negocio.md` nem no plan)
- **adiar** → `brief.md` `faq: fora`; **não** criar `faq.md`
- Ack: «Recebido.» / «Recebido — adiar.» — sem sumário do FAQ.

## 7. Adiamentos da 1ª entrega

A 1ª entrega **adia** **landings de planos**, **marca** e/ou **outra coisa**? Lista o que entra em adiamentos.

- O que **adiar** → `brief.md` + Fora / adiado do plan
- O que **não** adiar → pedir os **dados** (anexo ou texto), **uma** pergunta por item em falta

Landings (`app/views/<espelho>/planos/beneficios/<slug>/`): tasks **só** se **não** adiado **e** houver dados do operador. Sem dados, não inventar.

## 8. Cadastro neste clone

Só no **plan** deste clone (não vai para a fonte).

Este plan documenta o **seed** canónico (grupo, empresa, `Dominio`, `planos.json`)? **Sim** se este tree tiver `rotinas_auxiliares`. Senão: **não** + **nome do repo** do seed.
