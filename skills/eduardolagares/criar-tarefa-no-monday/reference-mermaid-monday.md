# Mermaid → imagem no Monday Doc

**Regra:** qualquer gráfico Mermaid deve ser convertido em imagem **antes** de ser adicionado ao documento Monday. Nunca enviar Mermaid como código ou markdown cru.

## Kroki — POST (recomendado para ficheiro local)

```bash
curl -sS -X POST "https://kroki.io/mermaid/png" \
  -H "Content-Type: text/plain" \
  --data-binary @uc1.mmd \
  -o uc1.png
```

## Kroki — URL pública (para `public_url` no `create_block`)

```python
import zlib, base64

def kroki_png_url(mermaid_source: str) -> str:
    compressed = zlib.compress(mermaid_source.encode("utf-8"), 9)
    encoded = base64.urlsafe_b64encode(compressed).decode("ascii")
    return f"https://kroki.io/mermaid/png/{encoded}"
```

## Posicionamento no Monday Doc

Ordem típica após `create_doc` com markdown de tarefa funcional:

| UC | Inserir imagem `after_block_id` do bloco |
|----|------------------------------------------|
| UC1 | Texto da prosa do UC1 (após título UC1) |
| UC2 | Texto da prosa do UC2 |
| UC3 | Texto da prosa do UC3 |
| UC4 | Texto da prosa do UC4 |

Operação:

```json
{
  "operation_type": "create_block",
  "after_block_id": "<id do bloco de texto do UC>",
  "block": {
    "block_type": "image",
    "public_url": "https://kroki.io/mermaid/png/...",
    "width": 700
  }
}
```

## Upload como asset Monday (alternativa)

Se `public_url` externo falhar:

1. `get_asset_upload_url` — fileName, contentType, fileSize
2. `PUT` no `upload_url` — capturar `ETag`
3. `finalize_asset_upload` — uploadId, etag, boardId, itemId, columnId (`monday_doc`)
4. `create_block` com `asset_id` retornado

`add_markdown_content` **não** suporta `asset_id`; usar `create_block` para imagens.
