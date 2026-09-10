# Confidentiality and Integrity Customization

What Grok Build is *permitted* to do, as opposed to what it is *asked* to do. Parent: [confidentiality and integrity](confidentiality%20and%20integrity.md). Prompt/behavior locations: [coding agent customization](../agent%20customization/coding%20agent%20customization.md).

Scope: Grok Build, user and project level, general knobs on the agent itself. Not MCP, hooks, plugins, personas, skills.

## Approach

Allow tools at **user** level. Confine the filesystem at **user** level. Named extra denies at **project** level.

| Level | What | Where |
|-------|------|--------|
| User | Tools run without asking (`always-approve`). No `[permission]` deny list. | `stack/ai/coding/grok/config.toml` → `~/.grok/config.toml` |
| User | Sandbox profile `cwd` extends `strict`: the process may read/write the launch directory only (plus system paths and `~/.grok`). Fail-closed: Grok refuses to start if the kernel policy cannot apply. | `config.toml` `[sandbox] profile = "cwd"` + `sandbox.toml` |
| Project | Deny named secrets *inside* cwd (`.env`, `*.pem`, and home `.ssh`/`.gnupg` as belt-and-suspenders). | `<repo>/.grok/config.toml` `[permission] deny` |

```toml
# ~/.grok/config.toml
[ui]
permission_mode = "always-approve"

[sandbox]
profile = "cwd"

# ~/.grok/sandbox.toml
[profiles.cwd]
extends = "strict"

# <repo>/.grok/config.toml
[permission]
deny = [
  "Read(/Users/*/.ssh/**)",
  "Read(/Users/*/.gnupg/**)",
  "Read(**/.env)",
  "Read(**/*.pem)",
]
```

Project config cannot set `permission_mode` or select a sandbox profile. Cwd isolation therefore lives at user level; project files only add named denies.

## Wrong lever: `AGENTS.md` and `rules/`

These are standing instructions stuffed into context. The model *tends* to follow them. They are not a boundary.

- `AGENTS.md` (and variants) at `~/.grok/`, repo root, or any folder
- `~/.grok/rules/*.md` and `<dir>/.grok/rules/*.md`

Grok’s own docs call this “Project Rules.” That word is borrowed from Cursor/Claude and means “please do this,” not “this is enforced.” Do not put confidentiality or integrity controls here.

Name collision: `[permission]` in `config.toml` is the real rule engine. `.grok/rules/` is markdown.

## Why sandbox at user, not `[permission]` at project

“Don’t read outside the folder Grok was launched in” cannot be a project `[permission]` rule:

- There is no inverse glob (“everything except this project”). `Read(/Users/**)` also matches the repo.
- Under `always-approve`, `ask` on `Read` does not prompt.
- Sandbox never asks; it blocks.

`strict` (our `cwd` profile) is the portable outside-project fence. Still readable: system paths + `~/.grok`. `[permission] deny` is for paths you can name, including secrets that sit *inside* the launch directory.

## What this actually buys

- **Outside cwd:** kernel block (Seatbelt). Irreversible for that process.
- **Named secrets inside cwd:** harness `deny`. Also covers `cat`/`sed` on those paths.
- **No ignore file.** Nothing like `.cursorignore`. `tools.respect_gitignore` is indexing, not a confidentiality control.
- Launching Grok from `$HOME` makes all of home the cwd — don’t.

Not `AGENTS.md`.
