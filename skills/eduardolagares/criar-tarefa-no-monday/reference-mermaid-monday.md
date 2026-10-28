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

## Estado dos renderers (só dentro do script)

O script chama o renderer **localmente** ao gerar PNG; o Monday **nunca** recebe URL do renderer.

| Serviço | Situação |
|---------|----------|
| `mermaid.ink` | Usado **apenas** em `render_diagramas.py` (`?type=png&bgColor=!white`). Saída = arquivo `ucN.png` verificado |
| `kroki.io/mermaid` | **Fora do ar** (2026-08). Não usar no script sem testar |

**Proibido no Monday doc:** `public_url` apontando para mermaid.ink, kroki ou base64 na URL. Base64 na mão quebra parsing em vários diagramas (HTTP 400) mesmo quando o script gera PNG válido.

**Obrigatório no Monday doc:** `asset_id` após upload do PNG gerado pelo script.

## Posicionamento no Monday Doc

Uma imagem por UC, sempre com `after_block_id` = último passo daquele UC:

```json
{
  "operation_type": "create_block",
  "after_block_id": "<id do ultimo passo do UC>",
  "block": { "block_type": "image", "asset_id": "<id do asset Monday>", "width": 700 }
}
```

O schema desse `create_block` **não** tem `alignment`. Passar o campo faz a chamada falhar, e o bloco nasce à esquerda. Em seguida, `all_api_write` → `update_doc_block`: reenviar o `content` do bloco com `"alignment": "center"`, mantendo `assetId`, `width` e `url`.

`create_block` **sem** `after_block_id` não vai para o fim: colide com a primeira posição e a imagem aparece no **topo** do documento, antes do Cenário.

**Não** usar `replace_block` para “mover” ou trocar imagem — no doc do Monday isso costuma **recriar a imagem no final** (após critérios de aceite). Corrigir posição: `delete_blocks` nas imagens erradas + `create_block` com `after_block_id` certo (inserir UC 6 → UC 1 se várias de uma vez).

Arquivo e posição do bloco de imagem não se editam no MCP — para trocar arquivo ou posição, `delete_blocks` no antigo + `create_block` novo, e de novo `update_doc_block` com `alignment` `center`.

## Verificação obrigatória

Após inserir todas as imagens, com **um** `read_docs` (`include_blocks: true`, `include_comments: true`):

1. Sequência de cada UC: último passo → imagem → próximo título.
2. Uma imagem por UC; nenhuma solta no fim **nem no topo**.
3. `aspectRatio` de cada bloco confere com o `largura x altura` impresso pelo script. Proporção idêntica em diagramas diferentes = imagem de erro.
4. `alignment` de cada imagem é `center`. `left` ou ausente → repetir `update_doc_block`.
5. Títulos de seção com texto, negrito e alinhamento à esquerda; sem título vazio/duplicado.
6. Corrigir e repetir a leitura enquanto algum item falhar.

## Upload como asset Monday (fluxo padrão)

Para **cada** `ucN.png` do script:

1. `get_asset_upload_url` — `fileName: ucN.png`, `contentType: image/png`, `fileSize` (bytes do arquivo).
2. `PUT` no `upload_url` com corpo binário do PNG — capturar `ETag` da resposta (valor sem aspas).
3. `finalize_asset_upload` — `uploadId`, `etag`, `boardId` (`4571892384`), `itemId` da tarefa, `columnId: monday_doc`.
4. Obter `asset_id`:
   - sucesso → usar o id devolvido;
   - **`CellLimitExceededException`** na coluna Documento (já existe doc na célula) → o asset **ainda é criado**; ler `assetId` do payload da mutação na mensagem de erro (ex.: `"assetId":"3316844352"`).
5. `create_block` no doc com esse `asset_id` (não anexar o PNG à coluna Documento — só registrar o asset para o bloco de imagem).

O quadro **Dia a dia** (`4571892384`) **não tem** coluna de arquivo dedicada; **não** criar coluna nova sem aprovação do time. O truque acima (`finalize` + extrair id do erro) é o caminho estável até existir coluna de arquivos.

`add_markdown_content` não suporta `asset_id`; só `create_block` com `block_type: image`.

### Conferência opcional

`get_assets` com os ids — confirmar `public_url` temporária e tamanho coerente com o `largura x altura` impresso pelo script.
