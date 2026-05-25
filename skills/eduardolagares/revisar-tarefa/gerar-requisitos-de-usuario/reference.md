# gerar-requisitos-de-usuario — schema

## Saída markdown (obrigatória)

Seção fixa: `## Requisitos da tarefa` + lista numerada.

Cada item **deve** incluir:

- `Fonte: documento` — sempre
- `Verificação:` — um de `diff` | `teste` | `monday` | `manual`
- `Status:` — `pendente` | `concluído`

Itens com marcador ignorar-revisão (ver SKILL.md): `Status: concluído` + sufixo `*(ignorar revisão — não reabrir)*`.

## JSON (opcional, agente interno)

```json
{
  "titulo": "string",
  "projetos_sugeridos": ["string"],
  "requisitos": [
    {
      "id": "R1",
      "texto": "string",
      "fonte": "documento",
      "verificacao": "diff",
      "status": "pendente",
      "ignorar_revisao": false
    }
  ],
  "pendentes_ids": ["R1"],
  "ignorar_revisao_ids": [],
  "spec_incompleta": false
}
```

## Mapeamento monday-task-info → campos

| Seção monday-task-info | Uso |
|------------------------|-----|
| Projetos alterados (tabela) | Resumo — **Projetos sugeridos** |
| ## Documento | **única** fonte de itens R* |

## Cruzamento com passo 3 (diff)

Itens com `verificacao: "diff"` e `status: "pendente"` são candidatos à checagem no diff (`executar-diff`).
