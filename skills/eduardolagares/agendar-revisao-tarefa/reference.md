# Monday.com (opcional) — ST-0

Só usar se `MONDAY_API_TOKEN` estiver no ambiente. Senão, pedir ao utilizador um bloco com os campos do ST-0.

## GraphQL (v2)

Endpoint: `https://api.monday.com/v2`

```bash
curl -s -X POST https://api.monday.com/v2 \
  -H "Authorization: $MONDAY_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"query { items(ids: [ITEM_ID]) { id name url column_values { id text title } subitems { id name column_values { id text title } } updates { body } } }"}'
```

Mapear no agente:

- **Branch principal** → coluna com esse título na item principal
- **projetos** → regex em updates/subitems: nomes conhecidos em `baladapp/*` ou menção explícita
- **executor** → subtarefa cujo nome contém `Executar`; owner da subtarefa

Não documentar token no chat. Não gravar token em ficheiros de estado.
