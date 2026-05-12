# ia-config — regras globais (Antigravity)

Este ficheiro faz parte do repositório **ia-config** (Google Antigravity: `~/.gemini/GEMINI.md`).

## Onde estão as convenções

Depois de correres `./install/antigravity.sh`, o instalador **copia e converte** o conteúdo para a árvore do Antigravity (além do symlink deste `GEMINI.md`):

- **Regras** (`.mdc` do repo → `.md` com `globs` Cursor ajustado a `paths` onde aplicável): `~/.gemini/antigravity/ia-config/rules/*.md` (ou `GEMINI_HOME/antigravity/...` se usares `GEMINI_HOME`).
- **Workflows** (equivalente a comandos slash): `~/.gemini/antigravity/global_workflows/*.md` — texto com referências ajustadas a esse path.
- **Skills** (pastas com `SKILL.md`, ex. Caveman): `~/.gemini/antigravity/skills/<nome>/`.

Aplica-as quando forem relevantes ao stack (Ruby on Rails, TDD, query objects, etc.) e quando não entrarem em conflito com instruções do projeto em curso.

## Nota sobre ferramentas

O ficheiro `~/.gemini/GEMINI.md` pode ser partilhado com o **Gemini CLI**; se usares os dois, evita edições manuais concorrentes ou considera variável `GEMINI_HOME` no script `install/antigravity.sh` se no futuro quiseres isolar caminhos.
