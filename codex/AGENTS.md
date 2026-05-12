# ia-config — instruções globais (Codex)

Este ficheiro faz parte do repositório **ia-config**. O Codex lê `AGENTS.md` em `~/.codex/` (ou `CODEX_HOME`) para orientação global.

## Onde estão as convenções

- **Regras** (`.mdc`, alinhadas ao Cursor): pasta `rules/` na **raiz do repositório** (irmã desta pasta `codex/`).
- **Comandos** (fluxos longos em Markdown): pasta `commands/` na raiz.

Quando gerares ou reveres código:

1. Segue o espírito e o detalhe dessas regras se o projeto em curso não disser o contrário.
2. Se o workspace for o próprio clone `ia-config`, lê os `.mdc` em `rules/` conforme os ficheiros em contexto.
3. O ficheiro `rules/karpathy-guidelines.mdc` é obtido pelo script `install/codex.sh` a partir do upstream **andrej-karpathy-skills** (não vai estar no Git se ainda não correste o instalador).

## Precedência

Se existir `~/.codex/AGENTS.override.md` com conteúdo, o Codex pode preferi-lo a este ficheiro — vê a documentação oficial do Codex.
