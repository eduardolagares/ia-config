# ia-config — instruções globais (Codex)

Este ficheiro faz parte do repositório **ia-config**. O Codex lê `AGENTS.md` em `~/.codex/` (ou `CODEX_HOME`) para orientação global.

## Onde estão as convenções

Depois de `./install/codex.sh`, o instalador gera **skills** no diretório global do Codex (predefinição **`~/.agents/skills`**, ou o valor de `AGENTS_SKILLS_ROOT`):

- Cada ficheiro em `rules/*.mdc` do repo vira uma skill `ia-rule-<nome>/SKILL.md` (metadados + corpo; scopes do Cursor convertidos no texto).
- Cada ficheiro em `commands/*.md` vira `command-<nome>/SKILL.md` (com `name` e `description` no frontmatter).
- Pastas em `skills/` do repo (ex. Caveman, cada uma com `SKILL.md`) são copiadas para o mesmo destino.

Quando geres ou reveres código:

1. Usa essas skills quando o pedido corresponder à respetiva `description` (descoberta progressiva do Codex).
2. Se o workspace for o próprio clone `ia-config`, também podes consultar os `.mdc` em `rules/` no repo.
3. O arquivo `rules/karpathy-guidelines.mdc` é **gerado** pelo instalador a partir do [SKILL.md upstream](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/skills/karpathy-guidelines/SKILL.md) (não fica no Git até você rodar o script).

## Precedência

Se existir `~/.codex/AGENTS.override.md` com conteúdo, o Codex pode preferi-lo a este ficheiro — vê a documentação oficial do Codex.
