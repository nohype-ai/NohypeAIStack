# Grok Build

`mack update` copies each of these into `~/.grok/` if present (overwrite, no merge):

| Stack path | Destination |
|------------|-------------|
| `AGENTS.md` | `~/.grok/AGENTS.md` |
| `config.toml` | `~/.grok/config.toml` |
| `pager.toml` | `~/.grok/pager.toml` |
| `rules/` | `~/.grok/rules/` |
| `hooks/` | `~/.grok/hooks/` |
| `skills/` | `~/.grok/skills/` |
| `commands/` | `~/.grok/commands/` |
| `plugins/` | `~/.grok/plugins/` |
| `workflows/` | `~/.grok/workflows/` |
| `agents/` | `~/.grok/agents/` |
| `personas/` | `~/.grok/personas/` |

User-level: always-approve, sandbox profile `strict`. Named path denies for every tree are in `config.toml`. Extra names for one repo go in that repo's `.grok/config.toml`.

Empty folders are placeholders. This README is not copied.
