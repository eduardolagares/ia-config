---
name: revisar-tarefa-verificar-requisitos-usuario
description: >-
  Passo 5 de revisar-tarefa: cruza requisitos de usuário (R*) com o diff e identifica
  quais não foram implementados. Somente leitura. Alimenta o passo 6 (gerar-requisitos-de-codigo).
disable-model-invocation: true
VERSION: "1.0.0"
---

# revisar-tarefa — verificar requisitos de usuário (passo 5)

Sub-skill **`verificar-requisitos-usuario`** do passo 5. **Somente leitura** — não altera Monday.

Cruza cada **`R*`** pendente (passo 2) com o **`## Diff`** (passo 3) e classifica implementação. Itens **não implementados** alimentam o passo 6 → tópico **Requisitos não implementados** no doc **Revisar código**.

Fluxo: passo 6 [gerar-requisitos-de-codigo](../gerar-requisitos-de-codigo/SKILL.md).

## Pré-requisito

| Dado | Obrigatório |
|------|-------------|
| **`## Requisitos da tarefa`** | Sim — passo 2 (`R*`) |
| **`## Diff`** | Sim — passo 3 |
| **Documento principal** | Recomendado — passo 1 (contexto da spec) |

Sem `R*` pendentes → entregar verificação com tabela vazia e secção **Requisitos não implementados:** `Nenhum.`

Diff só com **Erro:** por repo → classificar como **não verificável (diff indisponível)**; listar `R*` pendentes em **Requisitos não implementados** com nota de evidência insuficiente.

## Entrada

- Lista **`R*`** do passo 2 (respeitar `Status: concluído` / ignorar-revisão — **não** reverificar)
- Hunks do **`## Diff`** (passo 3); fallback: `diff_file` do cache
- Opcional: screenshot / texto do **Documento** (passo 1) para requisitos `Verificação: manual`

## Execução

Para cada **`R*`** com `Status: pendente`:

1. Ler o texto do requisito e o modo **`Verificação:`**.
2. Procurar evidência **somente** no diff (e paths citados nos hunks).
3. Classificar:

| Resultado | Critério |
|-----------|----------|
| **implementado** | Diff contém alteração que atende o requisito (path, template, teste, migração, etc.) |
| **parcial** | Evidência parcial ou ambígua — tratar como **não implementado** na saída |
| **não implementado** | Nenhuma alteração no diff relacionada ao requisito |
| **não verificável** | Modo `manual`/`monday` sem alteração esperada no diff; **não** marcar como implementado sem evidência |

### Por modo de verificação

| Modo | Como verificar |
|------|----------------|
| `diff` | Paths/módulos citados no requisito aparecem no diff com mudança substantiva |
| `teste` | Diff inclui teste novo ou alterado que cobre o comportamento |
| `manual` | Só **implementado** se diff altera artefato visual citado (template, CSS inline, partial, componente); senão → **não verificável** ou **não implementado** se a spec exige código ausente |
| `monday` | **não verificável** pelo diff — **não** listar em **Requisitos não implementados** salvo spec citar artefato de código ausente no diff |

### Regras

- **Não** inventar evidência fora do diff.
- **Não** duplicar achados do code review (passo 4) — foco = cobertura da **spec de usuário**.
- Requisito com múltiplos entregáveis → **não implementado** se faltar qualquer parte verificável no diff.
- Evidência fraca → **Parcial** → entra em **Requisitos não implementados**.

## Saída obrigatória

Entregar **somente** este bloco:

```markdown
## Verificação de requisitos

| ID | Verificação | Resultado | Evidência |
|----|-------------|-----------|-----------|
| R1 | diff | implementado | `path/no/diff`: … |
| R2 | manual | não implementado | diff não altera … |

### Requisitos não implementados

- **R2** — <texto curto do R2>. Evidência: …

(ou `Nenhum.` se todos implementados ou ignorados)
```

### Regras de formato

- Cabeçalho **`## Verificação de requisitos`** — texto exato.
- Tabela com **todos** os `R*` pendentes verificados.
- Secção **`### Requisitos não implementados`**: só ids com resultado **Parcial**, **não implementado**, ou **não verificável** quando a spec exige alteração de código ausente no diff.
- **Não** incluir `R*` com `Status: concluído` (ignorar-revisão no doc principal).
- **Não** repetir diff integral nem markdown do passo 1.

## Handoff para passo 6

| Saída passo 5 | Uso no passo 6 |
|---------------|----------------|
| Itens em **Requisitos não implementados** | Tópico **`## Requisitos não implementados`** no doc Monday |
| Tabela (implementados) | Só chat — não publicar no Monday |

Passo 6: [gerar-requisitos-de-codigo/SKILL.md](../gerar-requisitos-de-codigo/SKILL.md).

## Erros

| Situação | Ação |
|----------|------|
| Sem `## Requisitos da tarefa` | Parar; executar passo 2 |
| Sem `## Diff` | Parar; executar passo 3 |
| Nenhum `R*` pendente | Tabela vazia ou só ignorados; **Requisitos não implementados:** `Nenhum.` |

## Skills relacionadas

| Skill | Papel |
|-------|--------|
| `revisar-tarefa-gerar-requisitos-de-usuario` | Passo 2 — fonte R* |
| `revisar-tarefa-executar-diff` | Passo 3 — fonte diff |
| `revisar-tarefa-gerar-requisitos-de-codigo` | Passo 6 — publica no Monday |
| `revisar-tarefa-avaliar-tarefa` | Passo 7 |
| `revisar-tarefa-pos-avaliacao` | Passo 8 |
