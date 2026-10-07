# Mermaid → imagem no Monday Doc

**Regra:** qualquer gráfico Mermaid deve ser convertido em imagem **antes** de entrar no documento Monday. Nunca enviar Mermaid como código ou markdown cru.

## Renderizar: só pelo script

```bash
python3 ~/.cursor/skills/eduardolagares/criar-tarefa-no-monday/render_diagramas.py \
  docs/tarefas/<arquivo>.md /tmp/diagramas
```

O script é a única fonte de imagem: lê os blocos ` ```mermaid ` do próprio `.md` (então Monday e arquivo local não divergem), baixa o PNG e verifica os bytes. Falha com exit ≠ 0 em:

| Falha | Por quê |
|-------|---------|
| `flowchart` fora de `LR` | No doc a imagem entra com `width: 700`; vertical vira tira alta e ilegível |
| resposta não é PNG | Renderer fora do ar devolve HTML/erro, e o Monday exibe imagem vazia sem reclamar |

Altura não é verificada: `sequenceDiagram` cresce na vertical e imagem alta no doc é aceitável.

`--self-check` roda as asserções do próprio script.

**Exit ≠ 0 → não publicar.** Corrigir o `.md`, ou trocar `RENDERER` no topo do script quando o serviço cair.

## Estado dos renderers

| Serviço | Situação |
|---------|----------|
| `mermaid.ink` | Em uso. `?type=png` para PNG (o default é JPEG) |
| `kroki.io/mermaid` | **Fora do ar** (2026-08). O host responde e outros renderers dele funcionam, mas `/mermaid/*` dá timeout e o Monday guarda a imagem vazia. Não usar sem testar |

Hotlink apodrece: quando o board tiver coluna de arquivo, preferir `asset_id` — a imagem passa a viver no Monday.

## Posicionamento no Monday Doc

Uma imagem por UC, sempre com `after_block_id` = último passo daquele UC:

```json
{
  "operation_type": "create_block",
  "after_block_id": "<id do ultimo passo do UC>",
  "block": { "block_type": "image", "public_url": "<url verificada>", "width": 700 }
}
```

`create_block` **sem** `after_block_id` não vai para o fim: colide com a primeira posição e a imagem aparece no **topo** do documento, antes do Cenário.

Bloco de imagem é imutável — para trocar a imagem, `delete_blocks` no antigo + `create_block` novo.

## Verificação obrigatória

Após inserir todas as imagens, com **um** `read_docs` (`include_blocks: true`, `include_comments: true`):

1. Sequência de cada UC: último passo → imagem → próximo título.
2. Uma imagem por UC; nenhuma solta no fim **nem no topo**.
3. `aspectRatio` de cada bloco confere com o `largura x altura` impresso pelo script. Proporção idêntica em diagramas diferentes = imagem de erro.
4. Títulos de seção com texto, negrito e alinhamento à esquerda; sem título vazio/duplicado.
5. Corrigir e repetir a leitura enquanto algum item falhar.

## Upload como asset Monday

Quando o board tiver coluna de arquivo compatível:

1. `get_asset_upload_url` — fileName, contentType, fileSize
2. `PUT` no `upload_url` — capturar `ETag`
3. `finalize_asset_upload` — uploadId, etag, boardId, itemId e **coluna de arquivo**
4. `create_block` com `asset_id` retornado

`columnId` é obrigatório e precisa ser coluna de arquivo. Não usar `monday_doc`: aceita um único documento e retorna `CellLimitExceededException`. O quadro **Dia a dia** (`4571892384`) **não tem** coluna de arquivo hoje — criar uma altera o schema do board do time, então só com aprovação. `add_markdown_content` não suporta `asset_id`; usar `create_block`.
