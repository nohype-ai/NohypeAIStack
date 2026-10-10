# Grok Build Permission System

## Scope

- This is a bout **Hard enforced permission settings** for what Grok Build can read, write, run, and send
- Based on user guide shipped with Grok Build 1.0.50
- What does not count as hard enforced settings:
	- Launch arguments. The next session does not keep them. Confidentiality and integrity cannot depend on remembering to use some flag.
	- Merely prompt-based customization (`AGENTS.md`, `.grok/rules/`, skills, personas). That's stochastic nudging, not guarantees.
- Excluded in this document (not essential):
	- Admin pins / requiremnt files
	- Custom sandbox profiles
	- Claude Code compatability locations
	- Launch arguments, prompt-based customizations
- Related:
	- [Agent Customization Levels](Agent%20Customization%20Levels.md)
	- [confidentiality and integrity - initial conversation](confidentiality%20and%20integrity%20-%20initial%20conversation.md)
	- [Agent Isolation](Agent%20Isolation.md)
	- Grok Build config docs are extracted on launch to `~/.grok/docs/user-guide/`
		- [26-config-reference.md](~/.grok/docs/user-guide/26-config-reference.md) lists every field of `config.toml`
		- [05-configuration.md](~/.grok/docs/user-guide/05-configuration.md) says which files are read, and in what order

## Three Knobs

On a tool call the three are consulted in this order.

1. **Permission rules.** A matching `deny` stops the call. A matching `ask` forces a dialog. A matching `allow` lets it through with no dialog. `deny` beats `ask` beats `allow`.
2. **Permission mode**, only when no rule settled the call. That is the Shift+Tab stop: a dialog, no dialog, or auto-review.
3. **Sandbox**, if the call then runs. The kernel allows or rejects the file open, the write, or a child process's network.

A permission rule cannot grant an exception to the sandbox. `allow` only skips a dialog for a path or command the sandbox already allows. `deny` and `ask` add barriers inside what the sandbox allows. An approval from a rule or from the mode still fails when the sandbox blocks the path.

### 1. Permission rules

A named path or command, settled before the mode. `deny` fails that call with no dialog to override it. `ask` forces a dialog, including on a read. `allow` skips the dialog and does not widen the sandbox. Read when the session starts.

Where:

- `~/.grok/config.toml`: `[permission]`.
- `<repo>/.grok/config.toml`: `[permission]`
- `~/.grok/sessions/…/permission.toml`
	- "always" or "never" for one command, saved from the approval dialog. Always-approve ignores this file.

### 2. Permission mode

Which stop of the Shift+Tab cycle this session is on. A session preference, not a fence.

Where:

- `~/.grok/config.toml` (the stop the TUI opens on)
	- Example: `[ui] permission_mode = "ask"`

#### Modes

| What the TUI shows | Config name                   | What that stop does                                                                                                                                                                                                                                                                                         |
| ------------------ | ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| (no label)         | `ask` or `default`            | Asks before edits and most commands, does not ask before a read                                                                                                                                                                                                                                             |
| `plan`             | Not a `permission_mode` value | Badge `plan`. File edits are rejected except the session plan file. The permission mode stays armed underneath, so on always-approve reads and bash still run. Leaving plan restores the previous badge. `/plan` enters it too. This state is saved and survives a restart. Bash is not checked for writes. |
| `auto-review`      | `auto`                        | A classifier lets routine calls through. The rest still prompt.                                                                                                                                                                                                                                             |
| `always-approve`   | `always-approve`              | No dialogs. A `deny` rule still fails the call.                                                                                                                                                                                                                                                             |

### 3. Sandbox

A sanbox profile is a named grant of paths and network.
- active profile is the value of `[sandbox] profile` for this session.
	- The choice is fixed for the session, including resume.
- A path it does not grant fails, in file tools and in bash. No approval dialog. You see a tool error. 
- Built-in profiles are `off`, `workspace`, `read-only`, `strict`, and `devbox`.
	- `off` is the default and grants every path you can open, so nothing fails.
	- Any other name is a custom profile defined in `sandbox.toml`.

Where:

- `~/.grok/config.toml` selects the profile
	- Example: `[sandbox] profile = "strict"`
	- No `[sandbox]` key means `off`
- `~/.grok/sandbox.toml` defines a custom profile
	- only when the built-in grant is not enough
	- Example: `[profiles.mine] extends = "strict"`.
- `<repo>/.grok/sandbox.toml` a custom profile shipped with that repo
	- such as an extra writable directory or a repo-specific `deny`
	- runs only when `~/.grok/config.toml` sets `[sandbox] profile` to that name
		- repo file cannot turn itself on, so cloning a repo cannot change your sandbox
	- The same name in `~/.grok/sandbox.toml` wins

## How to Protect Sensitive Data

### Overview

1. Permission mode is not part of the fence. We set always-approve as the default and always assume that's active.
2. Our basic fence is the `strict` sandbox profile shipped with Grok Build. It limits reads to the launch directory, plus essential system paths and `~/.grok`.
3. Permission deny rules then block named sensitive files that may sit inside that launch directory. Permission rules cannot allow anything the sandbox (`strict`) already blocks.
	- The names that show up in any tree go in `~/.grok/config.toml`
	- Extra names for one repo go in `<repo>/.grok/config.toml`

### Example Files

```toml
# ~/.grok/config.toml
[ui]
permission_mode = "always-approve"

[sandbox]
profile = "strict"

[permission]
deny = [
  "Read(**/.ssh/**)",
  "Read(**/.gnupg/**)",
  "Read(**/.env)",
  "Read(**/.env.*)",
  "Read(**/*.pem)",
  "Read(**/*.key)",
  "Edit(**/.ssh/**)",
  "Edit(**/.gnupg/**)",
  "Edit(**/.env)",
  "Edit(**/.env.*)",
  "Edit(**/*.pem)",
  "Edit(**/*.key)",
]
```

```toml
# <repo>/.grok/config.toml
[permission]
deny = [
  "Read(**/client-secrets/**)",
  "Edit(**/client-secrets/**)",
  "Bash(git push *)",
]
```

### What `strict` still allows

|         | Allowed                                                                                                                                     |
| ------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| Read    | Launch directory, essential system paths, `~/.grok` (credentials, memory, other sessions)                                                   |
| Write   | Launch directory, `~/.grok/sessions`, `/tmp`, and `/var/tmp`. macOS also grants its own temp directories.                                   |
| Network | Model API, `web_search`, and `web_fetch`, always, in-process. `bash` network (`curl`, `npm`) blocked on Linux only. On macOS it stays open. |

### Important Notes 
  
- **Repo Level Config:** A repo cannot turn the sandbox on. `<repo>/.grok/config.toml` is not read for `[sandbox]` or `[ui]`. It is read for `[permission]`, which is how step 3 adds names for that repo.
- **Launch Directory:** The fence is the launch directory, not the git root. Starting in `$HOME` or a parent of several repos widens the fence to that tree.
- **Rule Patterns:** `~` in a pattern is literal. `**/.ssh/**` matches any home. `/Users/…` does not match `/home`. `*` does not cross `/`. `**` does. `Write` is the edit class, so an `Edit` rule covers it. A `Read` deny also stops `cat` and `sed` on that path. A program that builds the path in code gets past that scan.
- **Always-approve mode:** Always-approve still honors `deny` rules, hooks, and shell `ask` rules. It does not prompt for an `ask` on a read or an edit, and it ignores remembered grants, including a saved "never allow." `[ui] yolo = false` beside `permission_mode = "always-approve"` leaves always-approve on.
- **Folder Trust:** A deny in `<repo>/.grok/config.toml` applies after `/hooks-trust`, and that same trust also loads the repo's hooks, instructions, skills, and MCP.
- **Sandbox Lifetime:** The sandbox profile is fixed for the life of the session. Resuming a session will not pick up a new sandbox profile.