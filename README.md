# ia-config

Repositório de **regras** (Cursor), **comandos** e scripts de instalação para alinhar o assistente de IA ao teu fluxo (Ruby on Rails, TDD, convenções de equipa). O instalador descarrega **obrigatoriamente** `rules/karpathy-guidelines.mdc` a partir do projeto **[andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills)** (precisa de **curl**). As skills **Caveman** continuam opcionais — no fim o script **sugere** instalá-las (pergunta interativa — ver abaixo). Para **atualizar só** Karpathy e Caveman sem mexer em symlinks, usa **`--upgrade`** nos scripts `install/`.

## Instalação

1. **Clona** este repositório para um path estável (ex.: `~/projetos/ia-config`).

2. **Dá permissão de execução** aos scripts (só na primeira vez):

   ```bash
   chmod +x install/cursor.sh install/claude.sh
   ```

3. **Escolhe o ambiente** e corre o instalador correspondente a partir da raiz do repo:

   | Ferramenta    | Comando                 | Efeito |
   |---------------|-------------------------|--------|
   | **Cursor**    | `./install/cursor.sh`   | Cria symlinks em `~/.cursor/` para as pastas `rules`, `skills` e `commands` deste repo (substitui destinos existentes com o mesmo nome). |
   | **Claude Code** | `./install/claude.sh` | Igual, em `~/.claude/` (ou em `$CLAUDE_CONFIG_DIR` se estiver definido — [documentação](https://code.claude.com/en/env-vars)). |

   **Antes dos symlinks**, o script obtém **`rules/karpathy-guidelines.mdc`** do ramo `main` de [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) (ficheiro `.cursor/rules/karpathy-guidelines.mdc` no upstream). É **obrigatório** para a instalação completar; não está versionado neste repo (`.gitignore`). URL alternativa: variável `KARPATHY_GUIDELINES_URL`.

   No **final**, o instalador **sugere** as skills **Caveman**: aparece uma pergunta (predefinição *não*) sobre **instalar** esse toolkit. Se aceitares, corre um `git clone` shallow de [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) e copia-se `skills/` desse repo para `skills/` deste clone (ficheiros cobertos pelo `.gitignore`). Exige **git** instalado.

   **Sem prompt interativo** (CI ou scripts):

   ```bash
   INSTALL_CAVEMAN=yes ./install/cursor.sh
   ./install/claude.sh --with-caveman
   ./install/cursor.sh --without-caveman   # não pergunta nem instala
   ```

   **Repo alternativo:** `CAVEMAN_REPO_URL=https://... ./install/cursor.sh`

   **Upgrade** (apenas Karpathy + Caveman; **não** altera symlinks): `./install/cursor.sh --upgrade` ou `./install/claude.sh --upgrade`. Volta a descarregar `karpathy-guidelines.mdc` e aplica a mesma lógica Caveman (pergunta “Atualizar”, ou `INSTALL_CAVEMAN=yes ./install/cursor.sh --upgrade`, ou `--without-caveman`). Combina com `--dry-run`.

4. **Simula** sem alterar nada:

   ```bash
   ./install/cursor.sh --dry-run
   ./install/claude.sh --dry-run
   ./install/cursor.sh --upgrade --dry-run
   ```

5. **Reinicia** o Cursor (ou o cliente Claude) para garantir que carrega a configuração nova.

**Nota:** O script do Claude avisa que ficheiros `.mdc` são sobretudo para o Cursor; no Claude Code as rules costumam ser `.md` — podes duplicar ou converter se precisares do mesmo texto nos dois sítios.

---

## Conteúdo do repositório

### `install/`

Scripts bash que descarregam **obrigatoriamente** `karpathy-guidelines.mdc`, ligam **pastas inteiras** do repo a `~/.cursor/` ou `~/.claude/` via symlink (`rules`, `skills`, `commands`), e no fim **sugerem** as skills Caveman.

| Ficheiro      | Função |
|---------------|--------|
| `cursor.sh`   | Instalação para Cursor. |
| `claude.sh`   | Instalação para Claude Code; respeita `CLAUDE_CONFIG_DIR`. |
| `lib/karpathy-rules.sh` | `curl` do `.mdc` Karpathy a partir de [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills); **obrigatório**. |
| `lib/caveman-install.sh` | Clone shallow do upstream e cópia para `skills/`; opcional (pergunta no fim). |

### `rules/`

Regras em `.mdc` (Cursor **Project Rules** / contexto por glob). Cada ficheiro documenta convenções para um tipo de código ou preocupação.

| Ficheiro             | Tema |
|----------------------|------|
| `ruby.mdc`           | Convenções de linguagem Ruby. |
| `clean_code_ruby.mdc` | Clean code e Rails em geral. |
| `models.mdc`         | Models Active Record. |
| `controllers.mdc`    | Controllers. |
| `views.mdc`          | Views / templates. |
| `migrations.mdc`     | Migrations e alterações de schema. |
| `testing.mdc`        | Testes. |
| `query_objects.mdc`  | Query objects. |
| `rule_objects.mdc`   | Rule objects / objetos de regra de domínio. |
| `context-mode.mdc`   | Uso de context-mode / análise sem inundar o contexto. |
| `karpathy-guidelines.mdc` | **Externo:** obtido pelo `install/` a partir de [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills); não commitado. Diretrizes Karpathy para o agente. |

### `commands/`

Comandos slash (Markdown) invocados no chat; descrevem fluxos longos para o agente seguir.

| Ficheiro    | Descrição resumida |
|-------------|--------------------|
| `tdd-dev.md` | Fluxo TDD de implementação (RED/GREEN, menus, alinhado a specs `tdd-doc`). |
| `tdd-doc.md` | Fluxo para documentar/guionar o trabalho TDD no spec. |

### `skills/`

No Git existe apenas `skills/.gitkeep` — a pasta existe para o symlink `~/…/skills` apontar para um diretório válido.

Depois de correres o instalador e aceitares **Caveman** (ou `INSTALL_CAVEMAN=yes`), aparecem aqui as pastas copiadas do upstream (`caveman`, `caveman-commit`, etc.); continuam **fora do controlo de versão** (`.gitignore`). Assim o mesmo path serve ao Cursor/Claude via symlink e às skills locais.

### `hooks/` e `prompts/`

Pastas reservadas (`hooks/.gitkeep`, `prompts/.gitkeep`) para poderes acrescentar localmente hooks ou prompts sem alterar a estrutura base do projeto.

### `.gitignore`

Ignora `rules/karpathy-guidelines.mdc` (descarregado na instalação) e paths de **skills de terceiros** sob `skills/`.

---

## Skills Caveman (recomendado)

O ecossistema **Caveman** (modo compacto, commit/review/compress, cavecrew, …) **não está no histórico Git** deste repo. O **instalador sugere** instalar esse toolkit no final (pergunta interativa); também podes forçar com `--with-caveman` ou `INSTALL_CAVEMAN=yes`. Fonte: [github.com/JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman).

**Porquê:** comandos como `/tdd-dev` pedem a skill **caveman** quando existe em `skills/` — menos tokens e comportamento alinhado ao texto do comando. Se recusares a instalação e a pasta `skills/` ficar só com `.gitkeep`, esse bloco é ignorado (sem erro).

---

## Context-mode (recomendado)

Complemento **opcional**, **fora** dos scripts `install/` — segue o passo a passo do próprio projeto.

**[context-mode](https://github.com/mksglu/context-mode)** é um servidor MCP que ajuda a **reduzir ruído no contexto** (por exemplo executando análises em sandbox e devolvendo só o essencial ao chat). Combina bem com a regra `rules/context-mode.mdc` deste repositório: instala e configura o MCP no Cursor (ou no cliente que suportes) quando quiseres esse fluxo.
