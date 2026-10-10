# 💙 Config as code formats

**Date:** 2026-10-01
**Source:** Brave Ask (search.brave.com/ask)

---

### User

why are there so many languages formats for configuration files today?
.env files and the like are basically bash, right?
Brewfile on macOS is basically Ruby right?
Then there are YAML, TOML, LUA.
And then there is Maven and Gradle with their own format, right?
And Makefiles are what?
What are Docker config files?
What else did i forget in the Unix/macOS/Linux config as code space?

### Brave Ask

There's no single "right" format because each tool emerged independently, in a different era and ecosystem, with different priorities (readability, strictness, nesting, comments, schema validation, embedded logic). No universal config parser exists, so each project just picks what fits its use case.

**Your specific questions:**

| Format | What it actually is |
|---|---|
| `.env` | **Not bash.** Flat `KEY=value` pairs with `#` comments, *inspired by* shell env-var syntax, but parsed by dedicated `dotenv` libraries. No nesting, no types, no logic. |
| `Brewfile` | **Yes, Ruby.** Homebrew is written in Ruby and the Brewfile is evaluated as Ruby — you can use real Ruby logic (`brew "gnupg" if OS.mac?`). |
| `YAML` / `TOML` | Data serialization formats (not programming languages). YAML dominates DevOps (Kubernetes, CI/CD); TOML dominates modern package tooling (Cargo, `pyproject.toml`). |
| `Lua` | A full **programming language** used as config where you need logic/expressions (e.g., Nginx, game engines). |
| Maven | Uses **XML** (`pom.xml`) — not "its own format." |
| Gradle | Uses **Groovy DSL** (`build.gradle`) or **Kotlin DSL** (`build.gradle.kts`) — also not a new format, just a real language as config. |
| `Makefile` | A **domain-specific build-automation language** with its own syntax: `target: dependencies` + tab-indented shell recipes. Not a general language, not a data format — it's a dependency-tracking build system. |
| `Dockerfile` | Its **own instruction-based DSL**: `FROM`, `RUN`, `COPY`, `CMD`, etc. — one instruction per line, executed in order. `docker-compose.yml` is **YAML**. |

**What you're missing:**

- **INI** (`.ini`, `.cfg`, `.conf`) — the oldest flat key-value format; still everywhere (Windows, `systemd` unit files, Apache `.conf`)
- **JSON** — `package.json`, `tsconfig.json`, `.eslintrc`, API configs
- **XML** — Maven, Ant, enterprise Java, SOAP
- **HCL** (HashiCorp Configuration Language) — Terraform, Vault
- **Protocol Buffers** (`.proto`) — structured config for microservices
- **Apache-style `.conf`** — a domain-specific directive language (not a data format)
- **Shell scripts** — used as "config" for system setup, CI pipelines, dotfiles
- **Python/Go/JS as config** — e.g., `setup.py`, `webpack.config.js`, `Vite` config — executable code as configuration

---

### User

oh yeah. and i had to use jinja as well at some point. ssh config is also it's own thing right?

so, now which are the ones I need to know most as an AI software company CTO across macOS and Linux?

### Brave Ask

Yes on both — **Jinja2** is a templating engine (not a config format per se, but it *generates* configs; you'll hit it in Ansible, CI/CD pipelines, and infra-as-code templates). **SSH config** (`~/.ssh/config`) is its own directive-based DSL with `Host`, `HostKeyAlgorithms`, `ProxyJump`, etc.

---

## Priority list for an AI company CTO (macOS + Linux)

**Tier 1 — you'll touch these weekly:**

| Format | Where it shows up | Why it matters |
|---|---|---|
| **YAML** | Kubernetes manifests, GitHub Actions / GitLab CI, Docker Compose, LiteLLM proxy, Ansible, most ML framework configs | The de facto standard across the entire AI infra stack. You'll write and review YAML more than any other format. |
| **JSON** | `package.json`, `tsconfig.json`, model configs, API payloads, structured data in pipelines | Universal interchange; every tool emits or consumes it. |
| **TOML** | `pyproject.toml`, `Cargo.toml`, `ruff.toml`, `poetry.toml` | Dominant in Python and Rust tooling — the languages most AI/ML work happens in. |
| **HCL** (Terraform) | GPU cluster provisioning, cloud resources, networking, VPCs | You won't write it daily, but you need to read it, review PRs, and understand state drift. |
| **Dockerfile** | Every model service, training job, eval pipeline | You'll be reviewing these and making architectural decisions about layering, caching, multi-stage builds. |
| **`.env` / dotenv** | Secrets, API keys, model endpoints, environment-specific overrides | You'll set policy on how these are managed (never in git, use Vault/Sealed Secrets/etc.). |

**Tier 2 — you'll hit these regularly:**

| Format | Where | Why |
|---|---|---|
| **Python** (as config) | `pyproject.toml` (TOML inside), `setup.py`, `conftest.py`, most ML tooling is Python-native | You need to be fluent enough to read and review, not necessarily write from scratch. |
| **Makefile** | C/C++ extensions, CUDA builds, custom ops, `make train` / `make serve` targets | Still the lingua franca for build steps in ML repos with native code. |
| **systemd units** (INI-like) | Long-running inference services, data pipelines on Linux boxes | You'll need to understand how services are managed on bare-metal or VMs. |
| **SSH config** | GPU clusters, on-prem inference nodes, bastion hosts | You'll be setting up and reviewing access patterns for the team. |
| **Jinja2** | Ansible playbooks, Terraform templates, CI/CD config generation | You'll be reading templated configs and debugging "why is the rendered output wrong." |

**Tier 3 — macOS-specific / situational:**

| Format | Where | Why |
|---|---|---|
| **Brewfile** (Ruby) | Standardizing dev environments across the team | One-time setup, then you mostly just review PRs. |
| **Plist / LaunchAgents** (XML) | macOS background services, local dev daemons | Rarely touch in an AI company context, but good to know exists. |
| **Nix** (if adopted) | Reproducible dev environments, GPU driver pinning | Growing in ML shops that want bit-for-bit reproducible environments. |

---

**The meta-point:** as CTO your job isn't to *write* all of these — it's to make **format and tooling decisions** (TOML over YAML for Python projects? Terraform over Pulumi? Docker Compose vs. K8s for staging?) and to **review** what your teams produce. So the skill is: read fluently, know the tradeoffs, and enforce consistency.

---

### User

for the config of modern cli tools, which language/format is the current state of the art?

### Brave Ask

**TOML** is the current state of the art for CLI tool configuration files. It's the format the Rust, Python, and Go ecosystems have all converged on (`Cargo.toml`, `pyproject.toml`, `ruff.toml`, `ty.toml`, etc.), and it's what new tools are defaulting to.

The reasons it won:

- **Explicit types** — no YAML-style implicit coercion (`yes`/`no`/`on`/`off` all becoming booleans)
- **Comments** — unlike JSON
- **No indentation sensitivity** — unlike YAML
- **Shallow, flat structure** — which is what CLI configs actually need (a handful of named sections, not 5-level nesting)
- **Unambiguous** — a parser can't "guess" your intent

**However**, the [CLI Guidelines](https://clig.dev/) (the de facto standard for CLI design) actually make a more important point: **most CLI tools shouldn't need a config file at all.** The recommended hierarchy is:

1. **Flags** (highest priority)
2. **Environment variables** (for global/user-level settings)
3. **Config file** (only if the config is "sufficiently complex")

And when you do need one, the guidance is: use a standard format, don't invent your own syntax, and support a precedence chain (flags > env > project-local > user-global).

**The practical rule for your AI company:**

| Context | Format |
|---|---|
| Your own CLI tools | **TOML** |
| CI/CD pipelines | **YAML** (because GitHub Actions / GitLab demand it) |
| Kubernetes manifests | **YAML** (no choice) |
| Secrets / env overrides | **`.env`** or a secrets manager |
| Machine-to-machine config | **JSON** |

If you're building a new internal CLI tool in 2026, TOML is the default answer. The only reason to pick YAML is if the tool is tightly coupled to a DevOps/CI ecosystem that already speaks YAML.

---

### User

explain the levels in the precedence chain: precedence is flags, then environment variables, then project config, then user config, then system config.

### Brave Ask

The core principle: **more specific scope wins.** Each level represents a different "who/what is this setting for?" question.

| # | Level | Scope | Typical location | Why it exists |
|---|---|---|---|---|
| 1 | **Flags** | One invocation | `--model=o3`, `-c key=value` | The user is making a deliberate, one-off decision *right now*. Highest intent, shortest lifetime. |
| 2 | **Environment variables** | One shell session / CI job | `export MYAPP_TOKEN=...` | Set by the surrounding context (CI runner, Docker container, `source .env`). More persistent than a flag, but still "ephemeral" relative to files. |
| 3 | **Project config** | One project, all users | `.myapp/config.toml` (committed to repo) | Team-shared, version-controlled settings. "This is how *this project* runs." Lives in git, reviewed in PRs. |
| 4 | **User config** | One person, all projects | `~/.config/myapp/config.toml` | Personal preferences that follow you across repos. "I prefer dark mode / 4-space indent / this API endpoint." |
| 5 | **System config** | All users, one machine | `/etc/myapp/config.toml` | Admin-set baselines. "The org mandates these defaults." Lowest user-writable precedence, but still overridable by everything above. |
| 6 | **Built-in defaults** | Always | Hardcoded in source | The fallback when nothing else is set. Keeps the tool usable out of the box. |

**The mental model is "specificity gradient":**

- A flag is the *most specific* statement of intent: "for this one command, do this."
- An env var is slightly broader: "for this session/container, use this."
- Project config is broader still: "for everyone working on this repo."
- User config is broader: "for me, everywhere."
- System config is broadest: "for everyone on this machine."

**Why env vars beat project config (the non-obvious part):**

This is the one that trips people up. The rationale (from the AWS CLI, `uv`, dbt, and clig.dev) is:

- Env vars are set by the *runtime environment* — a CI system, a container orchestrator, a secrets manager. They represent **infrastructure-level intent** that the platform operator has deliberately injected.
- Project config is set by a *developer* who committed a file.
- The infrastructure should be able to override what a developer committed (e.g., point `DATABASE_URL` at the staging DB in CI without touching the repo).

**Concrete example (from `uv`):**

```
uv run --python 3.12          ← flag (wins)
UV_PYTHON=3.13                ← env var (loses to flag)
pyproject.toml: requires-python = ">=3.11"   ← project config
~/.config/uv/config.toml      ← user config
/etc/uv/config.toml           ← system config
```

**One caveat for enterprise:** some tools add a *policy/managed* layer above everything (MDM on macOS, `requirements.toml` in Codex CLI, server-side policy in Claude Code). That layer can *enforce* constraints that even flags can't override — it's not "higher precedence" in the normal sense, it's a hard ceiling/floor.

---

### User

How are Environment variables typically set up on macOS and Linux?

### Brave Ask

## Linux

Linux has a clean, layered model:

| Scope | File | Format | Loaded by |
|---|---|---|---|
| System-wide, all users | `/etc/environment` | `KEY="value"` (not a script) | PAM at login |
| System-wide, login shells | `/etc/profile` | Shell script with `export` | Login shells |
| System-wide, drop-in | `/etc/profile.d/*.sh` | Shell scripts | Sourced by `/etc/profile` |
| Per-user, login shells | `~/.profile` or `~/.bash_profile` | Shell script | Login shells |
| Per-user, interactive shells | `~/.bashrc` / `~/.zshrc` | Shell script | Interactive shells |
| Per-service | systemd unit: `Environment=` / `EnvironmentFile=` | INI-like | systemd at service start |
| Per-project | `.env` + `direnv` or `docker compose` | `KEY=value` | Tool-specific |

The key insight: **`/etc/environment` is not a shell script** — it's a flat `KEY=value` file parsed by PAM. You can't use `export`, variable expansion, or conditionals. For anything complex, use `/etc/profile.d/`.

For long-running services, the canonical place is the **systemd unit file** itself:
```ini
[Service]
Environment="API_KEY=abc123"
EnvironmentFile=/etc/myapp/secrets.env
```

---

## macOS

macOS is more fragmented because of the **shell vs. launchd split**. GUI apps (launched from Finder, Spotlight, Dock) are children of `launchd`, not a shell — so they never see your `~/.zshrc`.

| Scope | File / Mechanism | Notes |
|---|---|---|
| Per-user, interactive shells | `~/.zshrc` | Default since Catalina (10.15). Most common place. |
| Per-user, login shells | `~/.zprofile` | Sourced once at login. Good for PATH. |
| Per-user, all zsh (incl. scripts) | `~/.zshenv` | Sourced for *every* zsh invocation. Rarely needed. |
| System-wide PATH | `/etc/paths` + `/etc/paths.d/*` | One directory per line. Processed by `path_helper`. |
| GUI apps / system-wide | `launchctl setenv KEY value` | Affects the current launchd session. **Does not survive reboot.** |
| GUI apps, persistent | LaunchAgent plist in `~/Library/LaunchAgents/` | Runs `launchctl setenv` at login. The "real" solution. |
| Per-service | `launchd` plist: `EnvironmentVariables` dict | For daemons/agents you define. |
| Per-project | `.env` + `direnv` or tool-specific | Same as Linux. |

**Critical macOS gotchas:**

1. **`/etc/environment` does not exist / is not read.** It's a Linux PAM artifact. macOS uses `launchd` instead.
2. **`launchctl setenv` is session-scoped.** It dies on logout/reboot. For persistence, you need a LaunchAgent:

```xml
<!-- ~/Library/LaunchAgents/com.user.env.plist -->
<key>ProgramArguments</key>
<array>
  <string>launchctl</string>
  <string>setenv</string>
  <string>JAVA_HOME</string>
  <string>/Library/Java/JavaVirtualMachines/zulu-23.jdk/Contents/Home</string>
</array>
<key>RunAtLoad</key>
<true/>
```

3. **VS Code / Electron apps** launched from the Dock won't see your `~/.zshrc` vars. Either launch from terminal (`code .`) or use the LaunchAgent approach.
4. **`/etc/launchd.conf` is deprecated.** Don't use it.

---

## Practical CTO guidance for your team

| Need | Linux | macOS |
|---|---|---|
| Dev machine PATH setup | `~/.bashrc` or `~/.zshrc` | `~/.zshrc` |
| Project-local env (auto-load on `cd`) | `direnv` + `.envrc` | `direnv` + `.envrc` (identical) |
| CI/CD secrets | Platform-native (GitHub Actions `secrets`, GitLab CI/CD vars) | Same — CI runs on Linux |
| Long-running service env | systemd `EnvironmentFile=` | LaunchAgent plist `EnvironmentVariables` |
| Container env | `docker run -e` / `docker-compose.yml` / K8s `env` | Same — containers run on Linux |
| Team-wide standard | `/etc/profile.d/99-company.sh` (via provisioning) | LaunchAgent plist (via MDM or `homebrew` formula) |

**The one rule that simplifies everything:** for anything that runs in a container, on a server, or in CI — you're on Linux. The macOS-specific mess (launchd, plists, the GUI/shell split) only matters for **local developer workstations**. Standardize on `direnv` + `.envrc` for project-local, `~/.zshrc` for personal, and let your infra (Terraform, K8s, CI) handle everything else.

---

### User

i don't get why the clig wants us tyo cram a cli tool's config into existing files on the machine (.bashrc, .zshrc, /etc/environment etc.) so that the config becomes a bunch of environment variables. isn't one new tool config toml in ~/.config/<tool>/.config.toml much cleaner? they say tread lightly on the user's computer and be easy to uninstall. in addition one config file is easier to backup.

### Brave Ask

You're right, and CLIG isn't actually saying what you think it's saying. Let me untangle this.

## What CLIG actually says

The exact text:

> "If this configuration is **sufficiently complex**, it may warrant a configuration file of its own, but environment variables are usually good enough."

It's recommending env vars as a **supplementary override layer**, not as the primary config mechanism. The "tread lightly" argument is about not *requiring users to edit `~/.bashrc`* — it's not an argument against `~/.config/<tool>/config.toml`.

## Why env vars are in the chain at all

The rationale isn't "avoid files." It's three specific things:

1. **CI/CD and containers.** A GitHub Actions runner or a Docker container doesn't have a user's `~/.config/`. The orchestrator injects env vars. If your tool *only* reads a config file, you can't configure it in CI without writing a file at runtime (which is fragile and racy).

2. **Infrastructure-level override.** A platform operator should be able to point `DATABASE_URL` at the staging DB without touching a committed config file. The env var is the "I'm the environment, I'm overriding you" mechanism.

3. **Secrets.** CLIG explicitly says *don't* put secrets in config files (they get committed, leaked in screenshots, etc.). A token like `MYAPP_API_KEY` belongs in the environment, injected by a secrets manager.

## What you should actually do

**Your instinct is correct for the primary config.** The pattern used by every well-designed tool (AWS CLI, `uv`, `gh`, `kubectl`, `terraform`):

```
~/.config/<tool>/config.toml    ← primary, structured, user-editable, backable up
MYAPP_* env vars                ← override layer for CI, secrets, infra
--flags                         ← one-off overrides
```

The config file is where the **structured, multi-key, human-readable** settings live. Env vars are where the **few critical values that change per-environment** live (tokens, endpoints, feature flags).

| Setting type | Where it lives |
|---|---|
| API key / token | Env var (injected by secrets manager) |
| Default model, log level, timeout, retry count | `~/.config/<tool>/config.toml` |
| One-off override for debugging | Flag |
| Per-project override | Project-level `config.toml` in repo |

## The "uninstall" and "backup" arguments

You're right on both:

- **Uninstall:** `rm -rf ~/.config/<tool>/` is cleaner than hunting through `~/.zshrc` for `export MYAPP_*` lines you added.
- **Backup:** One file to back up is better than "all the env vars scattered across three rc files."

The CLIG "tread lightly" principle is really about: *don't make the user edit their shell profile to use your tool.* A dedicated `~/.config/<tool>/config.toml` is perfectly in line with that — it's *your* file in *your* directory, not a modification of *their* shell environment.

**TL;DR:** Use `~/.config/<tool>/config.toml` as the primary config. Support env vars as an override layer for CI/secrets/infra. The CLIG is telling you to support *both*, not to pick env vars *instead of* a config file.

---

### User

ok then was this earlier caveat overblown?

"However, the CLI Guidelines (the de facto standard for CLI design) actually make a more important point: most CLI tools shouldn't need a config file at all."

### Brave Ask

Yes, somewhat overblown — I was overstating the CLIG's position to make a rhetorical point. Here's the more accurate framing:

**What the CLIG actually means:** For a tool with 3–5 flags and no persistent state, you don't need a config file. `mytool --verbose --format=json` is enough. Don't invent a config file for a tool that's basically a one-liner.

**What's actually true in practice:** The "sufficiently complex" threshold is hit *very* quickly. The moment a tool has:

- more than ~5 settings
- any setting with a non-obvious default
- per-project vs. per-user scoping
- anything a user would want to set once and not re-type

...a `~/.config/<tool>/config.toml` is the right answer. That's basically every CLI tool that isn't a trivial wrapper.

**The real CLIG principle that matters:** Don't *require* a config file to get started. The tool should work with zero config (sensible defaults), and the config file is an *opt-in* for power users. That's different from "most tools shouldn't have one."

So the corrected statement would be: *"Most CLI tools should work without a config file out of the box, but most CLI tools should also support one for non-trivial settings."* My original phrasing conflated "don't require it" with "don't offer it."

---

### User

persistence is a big one i guess. the user should not point macstack.dev to the user's stack repo on every invocation. but the tool should not shove that into other system files either.

### Brave Ask

Exactly right. The pattern is:

**First run:** tool asks (or infers), writes to `~/.config/macstack/config.toml`:

```toml
stack_repo = "/Users/you/dev/stack"
```

**Every subsequent run:** tool reads it. No flag needed, no env var needed, no system file touched.

**The key distinction that makes this clean:**

| Type | Who writes it | Format | Example |
|---|---|---|---|
| **Config** | User (or first-run onboarding) | TOML, human-editable | `stack_repo = "..."` |
| **State** | Tool, machine-generated | JSON, opaque | `~/.config/macstack/state.json` (caches, last-run timestamps, session IDs) |

The "where's my repo" value is **config**, not state. The user can open the TOML, read it, edit it, gitignore it, back it up. The tool never touches anything outside `~/.config/macstack/`.

**Uninstall is:**
```bash
rm -rf ~/.config/macstack/
```

Done. No grepping through `~/.zshrc`, no `launchctl unsetenv`, no hunting through `/etc/profile.d/`.

This is exactly what `gh`, `terraform`, `kubectl`, `uv` all do — own their directory, stay out of the user's shell.
