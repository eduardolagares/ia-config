# Fluxo de assets

Skill **não** gera mockups, favicon, OG nem emoticon. Wordmark anexada nesta conversa (modo inicial) → `$INGRESSOS/docs/plans/<id>/logo.<ext>`. A cópia para `app/javascript/…` **deste** host é na implementação (`dev-<id>`).

**Extensões aceites:** `png`, `jpg`, `jpeg`, `svg`, `webp` (minúsculas no ficheiro gravado). Recusar qualquer outra (pdf, ico, gif, …).

## Pasta da fonte (git do ingressos)

```
docs/plans/<id>/          # em $INGRESSOS, branch dev-plan-<id>
  brief.md
  style.md
  negocio.md
  faq.md                # opcional — copy FAQ; mock a revisar
  logo.<ext>              # só se o operador anexou; png | jpg | jpeg | svg | webp
```

Exemplo: `ingressos-repo/docs/plans/santos/logo.png`.

**Não** gravar a logo em `<clone>/docs/plans/<id>/`.

## Pasta padrão no repo (execução)

Wordmark do pack (navbar, `planos/show`, consultas):

`app/javascript/<id>/images/logo-site.png`

Erros estáticos / OG: `public/imagens/<id>/`. Mailer: ramo `when '<id>'` no Ingressos — não é o mesmo ficheiro.

## Duas listas no plan (as duas, sempre)

### Propagar a logo

Só se existir `logo.<ext>` na **fonte**. Slots de **wordmark** (o mesmo ficheiro):

- `app/javascript/<id>/images/logo-site.png`
- usos de `image_pack_tag` / `image_pack_path` `…/logo-site.png` neste clone (navbar, show, consultas)

Na implementação: copiar `$INGRESSOS/docs/plans/<id>/logo.<ext>` para esses paths (converter/redimensionar se o espelho exigir, ex. 125×50 PNG).

### Substituir à mão

**Sempre.** Uma wordmark não fecha o inventário.

- `background/` (home, jogos, …)
- cards `beneficios/`
- OG (`metadados.jpg`)
- `icon-social/`
- favicon ICO e emoticon de erro
- heroes / ícones de plano
- qualquer foto ou ilustração do espelho

Se **não** houver `logo.<ext>` na fonte: incluir também `logo-site` e os usos de wordmark nesta lista (ficam mock até o operador mandar).
