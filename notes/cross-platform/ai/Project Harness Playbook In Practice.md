# Project Harness Playbook in Practice

This document describes:
- The repo-checked artifacts that can implement [Project Harness Playbook](Project%20Harness%20Playbook.md) elements
	- Agent-agnostic artifacts + Grok Build-specific artifacts
- A mapping: What artifacts can be used to implement each project harness element

Out of scope:
- User-level agent setup. This document is only about project-level.
- Example harness. This document names specific carriers - not their contents.
	- Example harness is being developed here: [Project Harness Template - Main README](../../../cross-platform/ai/project-harness-template/README.md)
- Ordinary markdown documents. Those can be used for everything and are implied not listed. 

## Agent-Agnostic Artifacts

Shared means with real adoption. Only `AGENTS.md` and Agent Skills have a repo shape more than one agent-product reads.

| Means | What it is | Repo shape |
| --- | --- | --- |
| [AGENTS.md](https://agents.md) | Always-on project instructions for agents. Plain markdown, no required fields. Stewarded by the Agentic AI Foundation. | `AGENTS.md` at the repo root. Nested files for subprojects. The site only says the closest file wins a conflict; it does not define whether parents are still loaded. Codex and Cursor load the chain and let the closer file win. |
| [Agent Skills](https://agentskills.io) | On-demand procedure. The agent sees `name` and `description` up front and loads the body when the task fits. | `.agents/skills/<name>/SKILL.md` at the repo root or in a subproject. Optional `scripts/`, `references/`, `assets/` beside it. Portable frontmatter is `name` and `description`. Other fields vary by agent. Claude Code does not read this folder; its project skills are `.claude/skills/`. |
| [MCP](https://modelcontextprotocol.io) | Protocol for tools the agent can call (checkers, docs lookup, trackers). | The protocol is shared. How you point the agent at servers is not. There is no shared project file. |

Custom agents (a specialist with its own prompt, and sometimes its own tools or model) are a common idea and not a common file format. There is nothing agent-agnostic to check in for them.

---

## Grok Build Artifacts

Grok loads every `AGENTS.md` from the repo root down to the working directory. They accumulate. A deeper file is placed later and wins when two files conflict. Files outside that initial set are picked up when the agent reads or edits there.

A `CLAUDE.md` in those same directories is loaded too, and does not replace `AGENTS.md`.

| Means          | What it is                                                                                                                                                                                                                                           | Repo shape                                                                                                                                                |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Rules          | Extra always-on instructions, same job as `AGENTS.md`, split into files.                                                                                                                                                                             | `.grok/rules/*.md`, from repo root down to the working directory.                                                                                         |
| Skills         | Same Agent Skills format, higher priority than `.agents/skills/`. Also reads `.claude/skills/`. Grok frontmatter controls invocation: `when-to-use`, `user-invocable`, `disable-model-invocation`, plus optional `allowed-tools`, model, and effort. | `.grok/skills/<name>/SKILL.md`. Grok Build also comes bundled with certain generic skills at `~/.grok/bundled/skills/`. A project skill of the same name replaces the bundled one.                                                                                                                            |
| Commands       | Older slash-command form of a procedure. Flat markdown, filename is the command.                                                                                                                                                                     | `.grok/commands/*.md`                                                                                                                                     |
| Agents         | A specialist session: own prompt, and optionally model and tools. Discovered by description and spawned as a subagent.                                                                                                                               | `.grok/agents/*.md`                                                                                                                                       |
| Personas       | Behavioral overlay on a subagent only (tone, focus, output shape). Does not change its tools, and does not apply to the main session.                                                                                                                | `.grok/personas/*.toml`                                                                                                                                   |
| Hooks          | A script or HTTP call on a lifecycle event. Runs outside the model. `PreToolUse` can deny a call. `Stop` can refuse to finish until a check passes. Other events can log or set up the session.                                                      | `.grok/hooks/*.json`                                                                                                                                      |
| Workflows      | Host-owned multi-agent script. The engine runs the rounds; the model does not.                                                                                                                                                                       | `.grok/workflows/*.rhai`, keyed by `meta.name`                                                                                                            |
| Plugins        | A folder that bundles skills, commands, agents, hooks, MCP servers, and LSP so they install as one unit.                                                                                                                                             | `.grok/plugins/<name>/`                                                                                                                                   |
| Project config | The only `config.toml` sections a repo file may contribute.                                                                                                                                                                                          | `.grok/config.toml` at the repo root and in folders down to the working directory: `[mcp_servers]`, `[plugins]`, `[permission]`, `[mcp] max_output_bytes` |
| MCP servers    | Project file that names MCP servers for this repo. Claude Code's format; Grok reads it.                                                                                                                                                              | Root `.mcp.json` (`mcpServers`)                                                                                                                           |
| LSP            | Language-server config for this repo.                                                                                                                                                                                                                | `.grok/lsp.json`                                                                                                                                          |

Folder trust is required before project instructions, skills, permission rules, hooks, MCP, LSP, and a plugin in `.grok/plugins/` load.

`/goal` is not in the table. It is a session loop: one objective, worked across rounds, marked complete only after an independent evidence review. With workflows enabled (the default) the host engine drives it. The objective, the generated plan, and the scratch it writes stay in the session, not the repo. `goal.enabled` is user config. A `/goal` objective is not a durable §3 objective, and the generated plan is not a repo task card. The overlap with §6 is the built-in gate, which you do not check in.

---

## Map onto the 11 elements

Harness elements here are not mapped to Grok plugins, because such a plugin is just how a repo ships the skill, the agent, the hooks, the MCP servers, and LSP together.

| # | Element | Agent-agnostic | Grok Build |
| --- | --- | --- | --- |
| 1 | Constitution | • `AGENTS.md`, root and nested | • `.grok/rules/*.md`<br>• `[permission]`<br>• `PreToolUse` hook for must-nots |
| 2 | Documentation | | |
| 3 | High-level objectives | | |
| 4 | Task management | | - A workflow could walk a task board across invocations |
| 5 | Task template (DoR) | • A skill to author or gate a card | • A skill in `.grok/skills/` to author or gate a card<br>• `user-invocable` and `disable-model-invocation` on that skill |
| 6 | Task execution template | • A skill for the quality gate: plan, fit to the existing code, implement, fresh review, checks | • Bundled `/implement`. Slash-only. Implement, fresh review, fix until clean<br>• Bundled `/review`. Fresh review of the working tree, the branch, a PR, or a stack<br>• `.grok/agents/*.md` to run that gate<br>• A `Stop` hook that can refuse to finish<br>• A workflow for that gate |
| 7 | Toolbox | • `.agents/skills/`, with `scripts/`, `references/`, `assets/`<br>• `.claude/skills/` for Claude Code<br>• Vendored docs, plus an index that points at them | • `.grok/skills/`<br>• Root `.mcp.json`<br>• `[mcp_servers]` in `.grok/config.toml`<br>• `.grok/lsp.json` |
| 8 | Specialized task template | • One skill per recurring job or role | • Bundled `/design`. Design doc until consensus, with a PR plan<br>• Bundled `/execute-plan`. Execute that PR plan<br>• Bundled `/code-review`. Slash-only strict maintainability audit<br>• `.grok/agents/*.md` for a specialist<br>• `.grok/personas/*.toml` for a subagent overlay<br>• A workflow for a fixed multi-agent pipeline |
| 9 | Specific task card | | |
| 10 | Work log / durable record | • A skill for appending progress and filing completion | • A hook on tool or session events that appends an audit trail |
| 11 | Harness evolution policy | • The standing rule in `AGENTS.md`: friction → harness task → upgrade | • The same rule in `.grok/rules/` |

### Choosing Artifacts

1. Empty cells are the ordinary markdown files, which are of course an always available baseline.
2. An explicit artifact and a generic markdown file can say the same thing. The explicit artifact wins on reliability, because the agent discovers it without someone remembering to link it.
3. When agent-agnostic and agent-specific artifact do the same job, use the agent-agnostic (shared) one: Grok already reads it, and the other agents do too.
4. When the Grok artifact does something the shared artifact cannot, the choice becomes portability versus effectiveness.

## The Agent-Agnostic Strategy

Keep the harness in shared files if these reasons are important:

1. Access to the best model at all times. A weaker model has greater downstream cost than missing a product's native machinery. Rankings and subscriptions move, so that model may live in another product (Claude Pro runs Claude Code, not Grok Build).
2. Adversarial review and similar patterns are part of the strategy. Implementer and reviewer are different seats by design: another product, another model, or a subagent. The harness is the language both seats load.

Put the harness in `AGENTS.md`, `.agents/skills/` and ordinary markdown files. Almost the whole playbook can live there.

A skill can require a real subagent: new context, given the review procedure, report back. Name that outcome. Do not name the product's spawn tool. An agent that can spawn already knows its tool. A native agent file is optional.

Treat hooks, workflows, and native agent formats as extras for the rare job a shared file cannot do.
