# Formato do tenant style

Única fonte de identidade visual. Vive em `$INGRESSOS/docs/plans/<id>/style.md` (branch `dev-plan-<id>`). O plan do host **não** redefine paleta: uma linha + ponteiro; **não** anexa o guia.

O operador anexa o guia **nesta** conversa (modo **inicial**, ou **parcial** se `style.md` ainda não existir). **Não** ler cache no home da skill nem o `.<id>.plan.md` de outro host.

Referência de forma: `tenant_style_santos.md`.

## Aceitar só anexo `.md` completo

Mínimo obrigatório:

- YAML / cabeçalho: `identificador`, `produto`, `titulo_padrao`, `tema` (claro/escuro), `theme_color`, `cores` (primária / secundária / terciária + canvas se houver), `fontes` (title / text)
- Invariantes e o que é **proibido** copiar de outro tenant (contraste, tokens sobrecarregados)
- `:root` **completo** (mesmo conjunto de chaves do espelho) **ou** mapeamento token a token — não só duas cores
- Exceções SCSS / mailer / erros estáticos quando o produto tiver
- Bloco colável **Identidade visual** (o plan do host pode citar 1–2 frases disto, não o documento)
- Checklist só de estilo

`identificador` do ficheiro = token do argumento.

`produto` / `titulo_padrao` no YAML são **visuais**. **Nome do produto** e **nome do clube** do plan/brief vêm da entrevista ([entrevista.md](entrevista.md)) — **não** copiar estes nomes a partir deste guia.

## Recusar

- Três hex no chat
- “Usa o dourado do Santos” (ou equivalente)
- Guia só com primária/secundária
- Ficheiro cujo `identificador` ≠ argumento
- “Copia do plan das assinaturas” / abrir outro plan de host para preencher o estilo
- **skip** seguido de copiar o `style.md` de outro tenant

Sem anexo válido **e** sem **skip** no modo inicial (e sem `style.md` já na fonte) → **parar**. Não improvisar paleta. Não perguntar cores, fontes, tema, theme-color.

## Skip (teste)

O operador responde **skip** no passo de estilo. Continuar a entrevista. Gravar **só** este stub em `$INGRESSOS/docs/plans/<id>/style.md` (`identificador` = token; nomes do brief se já existirem):

```
# tenant_style_<id>

> **Skip (teste):** operador não anexou o guia. **Não** implementar `:root`, paleta, mailer de marca nem `theme-color` até existir o `tenant_style_<id>.md` real.

identificador: <id>
produto: <nome_comercial do brief>
titulo_padrao: <nome_comercial do brief>
tema: pendente
```

`brief.md`: `style: skip`. No plan: ponteiro para o stub; tasks de SCSS / `:root` / `theme_colors` / mailer de cores **adiadas**; mockups cinza ok. **Não** colar paleta de outro clube.

## Depois de válido

Gravar o ficheiro inteiro em `$INGRESSOS/docs/plans/<id>/style.md`. Não gravar cópia no host nem no home da skill. Não embeber no `.<id>.plan.md`.

Modo **posterior:** ler esse `style.md` (working tree ou `git show` na `dev-plan-<id>`). Stub de skip conta como ficheiro existente — não revalidar o anexo; não pedir outro guia.
