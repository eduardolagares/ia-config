# GitLab (`glab`) — obsoleto

**Não usar** em `/revisar-tarefa`. O fluxo atual usa **somente** a REST API com **`GITLAB_TOKEN`** no ambiente do executador.

Documentação ativa: **[reference-gitlab-api.md](reference-gitlab-api.md)**

| Antigo (`glab-*`) | Substituto (`gitlab-api-*`) |
|-------------------|----------------------------|
| `glab-phase3-diff-bundle.sh` | `gitlab-api-phase3-diff-bundle.sh` |
| `glab-mr-find.sh` | `gitlab-api-mr-find.sh` |
| `glab-mr-diff.sh` | `gitlab-api-mr-diff.sh` |
| `glab-compare-diff.sh` | `gitlab-api-compare-diff.sh` |
| `glab-validate.sh` | `gitlab-api-validate.sh` |

Scripts `glab-*` permanecem na pasta por compatibilidade; **não** são invocados pelo hook, prefetch nem passos 3/8.
