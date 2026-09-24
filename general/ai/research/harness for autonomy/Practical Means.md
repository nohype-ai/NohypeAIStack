# Practical Means

Overview of the repo-checked means that can carry a [Dev Harness Playbook](Dev%20Harness%20Playbook.md) element. Project level only. User-level agent setup is out of scope. So is an example harness: this page names carriers, not their contents.

An empty cell means an ordinary repo document is enough. `AGENTS.md` may point at that document; the pointer does not make `AGENTS.md` the document.

Two adoption facts from the process notes:

- Facts that are true on every task go in `AGENTS.md`. Procedures go in skills, so they load when the task matches.
- A skill or a plain markdown file can say the same thing. The harness-native file wins on reliability, because the agent discovers it without someone remembering to link it.

When both files do the same job, use the shared one: Grok already reads it, and the other agents do too. When the Grok file does something the shared file cannot, the choice is portability against effectiveness. A skill can tell every agent to spawn a fresh reviewer. A `.grok/agents/` definition is what gives that reviewer its own context, model, and tools, and only Grok will run it. Hooks that block a call or block "done" are the same kind of choice. The sections below stay the full menu.

## General

Cross-harness. These are the only repo conventions with real adoption beyond one product.

| Means | What it is | Repo shape |
| --- | --- | --- |
| [AGENTS.md](https://agents.md) | Always-on project instructions for agents. Plain markdown, no required fields. Stewarded by the Agentic AI Foundation. | `AGENTS.md` at the repo root. Nested files for subprojects. The site only says the closest file wins a conflict; it does not define whether parents are still loaded. Codex and Cursor load the chain and let the closer file win. |
| [Agent Skills](https://agentskills.io) | On-demand procedure. The agent sees `name` and `description` up front and loads the body when the task fits. | `.agents/skills/<name>/SKILL.md`. Optional `scripts/`, `references/`, `assets/` beside it. Portable frontmatter is `name` and `description`. Other fields are vendor-specific. |
| [MCP](https://modelcontextprotocol.io) | Protocol for tools the agent can call (checkers, docs lookup, trackers). | No shared repo filename. Each harness has its own project config. |

Custom agents (a specialist with its own prompt, and sometimes its own tools or model) are a common idea and not a common file format. There is nothing agent-agnostic to check in for them.

---

## Grok Build

Repo paths only. Grok also reads `AGENTS.md` (and the compat names `AGENT.md`, `CLAUDE.md`, `CLAUDE.local.md`) and `.agents/skills/`. Grok loads every `AGENTS.md` from the repo root down to the working directory. They accumulate. A deeper file is placed later and wins when two files conflict. Files outside that initial set are picked up when the agent reads or edits there.

| Means | What it is | Repo shape |
| --- | --- | --- |
| Rules | Extra always-on instructions, same job as `AGENTS.md`, split into files. | `.grok/rules/*.md`, from repo root down to the working directory. |
| Skills | Same Agent Skills format, higher priority than `.agents/skills/`. Grok frontmatter controls invocation: `when-to-use`, `user-invocable`, `disable-model-invocation`, plus optional tool, model, and effort overrides. | `.grok/skills/<name>/SKILL.md` |
| Commands | Older slash-command form of a procedure. Flat markdown, filename is the command. | `.grok/commands/*.md` |
| Agents | A specialist session: own prompt, and optionally model and tools. Discovered by description and spawned as a subagent. | `.grok/agents/*.md` |
| Personas | Behavioral overlay on a subagent only (tone, focus, output shape). Does not change model or tools, and does not apply to the main session. | `.grok/personas/*.toml` |
| Hooks | A script or HTTP call on a lifecycle event. Runs outside the model. `PreToolUse` can deny a call. `Stop` can refuse to finish until a check passes. Other events can log or set up the session. | `.grok/hooks/*.json` |
| Workflows | Host-owned multi-agent script. The engine runs the rounds; the model does not. | `.grok/workflows/*.rhai`, keyed by `meta.name` |
| Plugins | A folder that bundles skills, commands, agents, hooks, and MCP servers so they install as one unit. | `.grok/plugins/<name>/` |
| Project config | The only `config.toml` sections a repo file may contribute. | `.grok/config.toml`: `[mcp_servers]`, `[plugins]`, `[permission]`, `[mcp] max_output_bytes` |
| LSP | Language-server config for this repo. | `.grok/lsp.json` |

Permission rules and hooks need folder trust before they run. A plugin in `.grok/plugins/` does too.

`/goal` is not in the table. It is a session loop: one objective, worked across rounds, marked complete only after an independent evidence review. With workflows enabled (the default) the host engine drives it; otherwise the model reports progress through `update_goal` and the harness still verifies. The files it writes stay in the session, not the repo: goal-mode state beside the other session records, a generated `goal/plan.md` (acceptance criteria and a verification plan) under the session trace directory, and a private scratch tree (`implementer/`, `skeptic-*/`) for captured output. `goal.enabled` is user config. A `/goal` objective is not a durable §3 objective, and the generated plan is not a repo task card. The overlap with §6 is the built-in gate, which you do not check in.

---

## Map onto the 11 elements

| # | Element | Agent-agnostic | Grok Build |
| --- | --- | --- | --- |
| 1 | Constitution | `AGENTS.md`, root and nested | `.grok/rules/*.md`. `[permission]` and a `PreToolUse` hook enforce must-nots. |
| 2 | Documentation | | |
| 3 | High-level objectives | | |
| 4 | Task management | | |
| 5 | Task template (DoR) | A skill for authoring or gating a card | The same kind of skill in `.grok/skills/`, with Grok invocation frontmatter |
| 6 | Task completion guide | A skill for executing any ready task. This is the quality gate: plan, fit to the existing code, implement, fresh review, checks. | `.grok/agents/*.md` for a fresh reviewer with its own context. Grok invocation flags on that skill. Legacy `.grok/commands/*.md`. A `Stop` hook that blocks done until checks pass. A workflow when the gate is a host-run sequence of agents. |
| 7 | Toolbox | `.agents/skills/` (including `scripts/`, `references/`, `assets/` for a CLI, a checker, or downloaded framework docs). Root `.mcp.json`. | `.grok/agents/*.md` as an invocable specialist. `.grok/skills/`. `[mcp_servers]` in `.grok/config.toml`. `.grok/plugins/` as the bundle. `.grok/lsp.json`. |
| 8 | Specialized template | One skill per recurring job or role | `.grok/agents/*.md` for a specialist. `.grok/personas/*.toml` for a lighter subagent overlay. A workflow when the pass is a fixed multi-agent pipeline. |
| 9 | Specific task card | | |
| 10 | Work log / durable record | | A hook on tool or session events can append an audit trail. |
| 11 | Harness evolution policy | The standing rule in `AGENTS.md` (friction → harness task → upgrade) | The same rule in `.grok/rules/` |

Plugins stay off the element rows. A project plugin is how a repo ships the skill (§5, §6, §8), the agent (§6, §7, §8), the hooks (§1, §6, §10), and the MCP servers (§7) together.

A workflow can also walk a task board across invocations. That is outer scaffolding around §4, so the board cell stays empty.
