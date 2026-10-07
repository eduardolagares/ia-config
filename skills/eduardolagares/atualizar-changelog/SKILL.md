---
name: atualizar-changelog
description: >-
  Gera changelog em markdown a partir das tarefas do grupo Changelog no board
  Dia a Dia do monday.com (status consolidado Changelog), agrupadas por sistema.
  Use com /atualizar-changelog ou quando pedirem resumo changelog, release notes
  ou texto para colar na ferramenta de changelog.
disable-model-invocation: true
VERSION: "1.1.0"
---

# atualizar-changelog

Gera um **changelog em markdown** a partir das tarefas com status **Changelog** no board **Dia a Dia** do monday.com. Usa o MCP **monday** (`plugin-monday-crm-monday`).

## Pré-requisitos

1. MCP monday conectado — **antes de qualquer leitura**, chamar `get_board_info` com `boardId: 4571892384`.
   - Se o servidor não existir ou falhar autenticação → **parar** e orientar: **Cursor → Settings → MCP → conectar `monday`** (`plugin-monday-crm-monday`). **Não** simular changelog nem inventar tarefas.
2. **Data de publicação** — se o usuário não informar, perguntar **uma vez**:
   - dia e mês para o cabeçalho `## DD, DIA-DA-SEMANA`;
   - mês/ano para `# MÊS, ANO`.
   - Se o usuário pedir para agrupar tudo em uma data (ex.: «3 de julho»), usar essa data para **todas** as demandas.

## Board e filtro

| Campo | Valor |
|-------|--------|
| Board | **Dia a Dia** — `4571892384` |
| Grupo | **Changelog** — `group_mm2051g5` |
| Status consolidado | coluna `status_1`, label **`Changelog`** |

Critério de seleção: itens com `column_values.status_1 == "Changelog"`.

> O grupo **Changelog** no board coincide com itens cujo status consolidado é **Changelog**. Filtrar por `status_1`, não por `groupId` na resposta do MCP (a API nem sempre devolve o grupo no item).

## Fluxo de execução

```
1. get_board_info — board 4571892384 (validar MCP + colunas)
2. get_board_items_page — boardId 4571892384, includeColumns true, limit 500
3. Filtrar itens com status_1 = Changelog; contar total
4. Para cada item com doc: read_docs — type object_ids, ids [<objectId>] (UM doc por chamada)
   - Se 502 ou vazio: aguardar ~5s e repetir a mesma chamada (até 2 retries)
   - Se ainda falhar: redigir tópico só com título + Tipo + branch (sem inventar RF)
5. Classificar emoji, mapear sistema(s), redigir tópico
6. Agrupar por sistema; ordenar grupos pela ordem sugerida (§ Mapeamento)
7. Montar markdown no formato abaixo
8. Entregar o .md em bloco ```markdown para colar na ferramenta
```

### Leitura de itens (resposta grande)

`get_board_items_page` pode retornar JSON grande. Se necessário, parsear com script (ex.: filtrar `status_1 == "Changelog"`, extrair `monday_doc.files[0].objectId`).

### Leitura de documentos

- **Sempre** `read_docs` com `type: "object_ids"` e **um** `objectId` por chamada.
- **Nunca** lotes de 5+ ids — retorna vazio ou 502.
- `objectId` = `column_values.monday_doc.files[0].objectId`.
- Item sem doc (`objectId` null): usar título + coluna **Tipo** (`label`) + branch (`texto`).

## Formato de saída (obrigatório)

```markdown
# MÊS, ANO

## DD, DIA-DA-SEMANA

**SISTEMA**
🚀 Texto da demanda em um parágrafo.
🔄 Outra demanda.
🛠️ Correção.

**OUTRO SISTEMA**
🚀 ...
```

Regras:

- Cada demanda = **um** parágrafo (um tópico), iniciando com o emoji na mesma linha.
- Agrupar **por sistema**; repetir o cabeçalho `**SISTEMA**` para cada grupo.
- Redação em **passado**, tom do changelog interno: «Criamos», «Incluímos», «Ajustamos», «Corrigimos», «Disponibilizamos», «Implementamos».
- Mencionar permissão de usuário específica quando o doc indicar.
- Entregar **somente** o markdown final em bloco de código (```markdown … ```) para colar na ferramenta — a menos que o usuário peça outra coisa.

### Cabeçalho de data

| Elemento | Exemplo |
|----------|---------|
| Mês/ano | `# JULHO, 2026` |
| Dia/semana | `## 3, SEXTA` |

Dia da semana em português, maiúsculas: SEGUNDA, TERÇA, QUARTA, QUINTA, SEXTA, SÁBADO, DOMINGO.

## Emojis por tipo de demanda

Resolver **nesta ordem** (primeira regra que bater vence):

| Emoji | Quando |
|-------|--------|
| 🛠️ | Título começa com `Fix:` / `fix:`; ou contém `Correção` / `Corrigir`; ou coluna **Tipo** = `BUG` |
| 🔄 | Coluna **Tipo** = `Ajuste` ou `Manutenção` |
| 🚀 | Coluna **Tipo** = `FUNCIONALIDADE` ou `MELHORIA`; ou demais casos de feature/nova capacidade |

Se **Tipo** estiver vazio: inferir pelo título e pelo doc (feature → 🚀, ajuste de comportamento → 🔄, correção → 🛠️).

> Ex.: título `Fix: …` com Tipo `FUNCIONALIDADE` → **🛠️** (título prevalece).

## Mapeamento de sistema

Usar a seção **Impactos** do documento (ou título/branch quando o doc não tiver impactos). Uma tarefa pode gerar **mais de um** tópico se impactar vários sistemas — duplicar o texto em cada grupo, ou resumir por sistema conforme o doc.

| Termo no doc / contexto | Cabeçalho no changelog |
|---------------------------|-------------------------|
| assinaturas-adm, Assinaturas ADM | **ASSINATURAS ADM** |
| assinaturas (sem -adm) | **ASSINATURAS** |
| auth2, auth | **AUTH2** |
| produtor | **PRODUTOR** |
| anúncios adm, adm anúncios, ADM Anúncios | **ANÚNCIOS ADM** |
| account + app / webview / BaladAPP | **APP BALADAPP** |
| account (sem app) | **ACCOUNT** |
| checkout | **CHECKOUT** |
| vitrine | **VITRINE** |
| comissários, comissarios | **COMISSÁRIOS** |
| ingressos (sem outro sistema mais específico) | inferir pelo fluxo (ADM → **ANÚNCIOS ADM** ou **ASSINATURAS ADM**) |

**Ordem dos grupos** (omitir vazios): ANÚNCIOS ADM → APP BALADAPP → ASSINATURAS → ASSINATURAS ADM → AUTH2 → CHECKOUT → COMISSÁRIOS → PRODUTOR → VITRINE → ACCOUNT.

## Redação do tópico

1. Ler cenário + o que foi feito nos requisitos do doc.
2. Condensar em **1–3 frases**, foco no que mudou para o usuário/operador.
3. Não colar RF/UC crus; não incluir Mermaid nem imagens.
4. Manter nomes de flags, permissões e campos como no doc (ex.: `permitir_login_por_documento`, `contratos__exportar`).

## MCP — ferramentas

Ler schema em `mcps/plugin-monday-crm-monday/tools/` antes de chamar.

| Etapa | Ferramenta | Parâmetros principais |
|-------|------------|------------------------|
| Validar MCP + board | `get_board_info` | `boardId: 4571892384` |
| Itens | `get_board_items_page` | `boardId: 4571892384`, `includeColumns: true`, `limit: 500` |
| Documento | `read_docs` | `type: "object_ids"`, `ids: ["<objectId>"]` (um por vez) |

Servidor: **`plugin-monday-crm-monday`**.

## Invocação

```
/atualizar-changelog
/atualizar-changelog 3 de julho de 2026
/atualizar-changelog agrupar tudo em 3 de julho
```

## Saída no chat

Após montar o changelog:

1. Informar quantas tarefas **Changelog** foram processadas.
2. Entregar o markdown completo em bloco ```markdown para colar.

Exemplo de mensagem curta:

```markdown
Changelog gerado com **26** tarefas do monday (status Changelog), agrupadas em **3 de julho de 2026**.

(cole o bloco markdown abaixo na ferramenta)
```

## Falhas comuns (não tratar como sucesso)

| Sintoma | Ação |
|---------|------|
| `MCP server does not exist: plugin-monday-crm-monday` | Orientar reconectar MCP; **não** continuar |
| `read_docs` lote retorna vazio | Voltar para **um** `objectId` por chamada |
| `read_docs` HTTP 502 | Retry após ~5s (máx. 2); depois título+tipo+branch |
| `MONDAY_API_TOKEN` ausente | **Não** usar API direta; exigir MCP |

## Proibido

- Inventar tarefas ou detalhes que não estejam no monday/doc.
- Usar API token / curl fora do MCP (salvo falha persistente do MCP após orientar reconexão).
- Alterar o formato de cabeçalho/emojis sem o usuário pedir.
- Publicar o changelog em ferramenta externa — só gerar o texto para o usuário colar.
- Simular sucesso se a leitura do monday falhar — reportar o que foi possível ler.
- Criar ou sobrescrever esta skill durante a execução — a skill já existe; só gerar o changelog.

## Escopo

Executar **somente** geração do markdown do changelog a partir do monday. Se o usuário pedir criar tarefa no monday, usar `/criar-monday`.
