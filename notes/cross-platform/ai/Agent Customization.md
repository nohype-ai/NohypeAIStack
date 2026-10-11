# Agent Customization

## Levels

Custom instructions, rules and configurations can be injected into an agentic coding system at five levels, building a hierarchy of customizations, where the lower and more specific levels (higher numbers) take precedence.

❗ These levels are supposed to help in practice so they mirror actual practical precedence order. Who is able or permitted to edit each customization or where these customizations are stored are entirely different dimensions.

1) Team Level:
   - default instructions or rules for all members of a team
   - rare, agent and provider account must be tightly linked
   - examples:
     - GitHub Copilot org custom instructions
     - Cursor Team Rules
       - Note: Cursor Team Rules can be used as soft team defaults (Level 1) or as unbreakable guardrails (Level 5)
2) User Level:
   - global on user machine, configs live in dotfiles/dotfoldfers in ~/ for persistence across projects
   - agent specific format/location
   - not version-controlled
3) Project Level:
   - Universal standard: AGENTS.md (or AGENT.md) in repo root as "README for agents"
   - Tool-specific stuff often in hidden folders (.cursor/, .continue/, .claude/) for clean project root
4) Folder Level:
   - Ideal for domain-specific rules (e.g., /api/ vs. /ui/)
5) Tool Level:
   - source of truth is conceptually with the agent/tool itself
   - this may be implemented via system prompt, dashboard rules, config files etc.
   - last-resort policy enforcement (final safeguard): customizations on this level overrule any customizations from levels 1 - 4
   - Examples:
     - Cursor Team Rules
       - Note: Cursor Team Rules can be used as soft team defaults (Level 1) or as unbreakable guardrails (Level 5)
     - Gemini CLI GEMINI_SYSTEM_MD (full system prompt override)
       - Any user can override this while Cursor Team Rules may be gated by specific roles in the team. But the important thing here is that this system prompt has the power to overrule even folder-level prompts.
     - `~/.gemini/policies/*.toml` actually overrule project-level policies. so `~/.gemini/policies/*.toml` represent the final safeguards of gemini CLI itself and not user preferences.

## Locations

**All Agents** is the shared surface. Other columns are only what that agent adds. Per-agent file lists and precedence: [Customization locations](research/coding%20agents.md#customization-locations).

| Level | **All Agents** | **Grok Build** | Claude Code | Cursor CLI | OpenCode | Gemini CLI |
| --- | --- | --- | --- | --- | --- | --- |
| **Team** | ❌ | ❌ | ❌ | Team Rules (if logged in) | ❌ | ❌ |
| **User** | `~/.agents/skills/` (⚠️1) | `~/.grok/` | `~/.claude/CLAUDE.md`<br>`~/.claude/settings.json`<br>`~/.claude/skills/` | `~/.cursor/rules/`<br>`~/.cursor/cli-config.json` (local only) | `~/.config/opencode/AGENTS.md`<br>`~/.config/opencode/opencode.json` | `~/.gemini/GEMINI.md`<br>`~/.gemini/settings.json` |
| **Project (root)** | `AGENTS.md` (⚠️2)<br>`.agents/skills/` (⚠️1) | `.grok/` | `CLAUDE.md`<br>`.claude/` | `.cursor/rules/`<br>`.cursor/cli.json` (permissions)<br>`CLAUDE.md` | `opencode.json`<br>`.opencode/` | `GEMINI.md`<br>`.gemini/` |
| **Folder (any)** | `AGENTS.md` (⚠️2) | `.grok/` | `CLAUDE.md` | ❌ | ❌ | `GEMINI.md` |
| **Tool** | ❌ | `--sandbox`<br>`--rules`, `--allow`, `--deny`<br>`PreToolUse` hooks | ❌ | Team Rules (enforced) | ❌ | `~/.gemini/policies/`<br>`GEMINI_SYSTEM_MD` |

* ⚠️1) On-demand procedures: `.agents/skills/<name>/SKILL.md`. Read by Gemini CLI, OpenCode, Cursor, and Grok. Claude Code reads `~/.claude/skills/` and `.claude/skills/`.
* ⚠️2) Always-on instructions. Gemini CLI loads `AGENTS.md` when `context.fileName` includes it; its default context file is `GEMINI.md`. Claude Code (v2.1.277+) loads it when no `CLAUDE.md`, `.claude/CLAUDE.md`, or `CLAUDE.local.md` is in scope. `/config` → Project instructions can load both.
* OpenCode also reads `CLAUDE.md` and `~/.claude/` as fallbacks. Turn that off with `OPENCODE_DISABLE_CLAUDE_CODE=1`.
* Amp reads `AGENTS.md` at `~/.config/amp/AGENTS.md`, in the project, and in folders, plus `.agents/skills/`. Detail: [Amp customization](research/amp%20customization.md).

## Conclusions

* The `AGENTS.md` convention is the closest we can get to a cross-agent (agent-agnostic) way to guide agents.
* ❗ We can largely ignore user-level prompt customization:
  * `AGENTS.md` is not at all universally respected at the user level.
  * Hardly anything would truly add value across all projects and folders, in particular when coding agents are applied beyond coding.
  * It would add latency, cost and prompt dillution to every single prompt.
  * It can not easily be version-managed together with a version managed folder, so agent behaviour would be decoupled from commits
* True user-level infos (like user's name, language style preference, tooling, operating system) would need to be somehow injected via markdown (templates) at the project folder level. but this has relatively low impact and can be postponed.
* `AGENTS.md` files should only contain what truly only applies to agents (like infos about the user). Almost nothing is truly agent-specific, for example, instructions on how to work with a project also apply to humans. So almost everything should remain in regular `README.md` files.
  * This reduces redundancy and promotes well structured documentation.
  * Also avoid including pointers to `README.md`, they would add ceremony without value. Agents are increasingly able to do contextual discovery and read relevant documentation.
* ❗ This whole agent customization thing is converging back to classic principles of just providing good old documentation. But agents do indeed make those principles more crucial than ever:
  * make things explicit
  * put docs where they actually apply and are needed
  * structure texts well
  * avoid redundancy
  * give overview first
  * link to related docs
  * use precise (even if long) terms
  * clarify used terminology
  * keep it up to date
  * make it as concise and dense as possible
  * etc.
* ❗ Non-repo folders and non-codebase folders should also use `README.md` files as their entrypoint and overview. Agents know what a `README.md` is.
* ❗ user-level agent settings (in contrast to prompts) are not only ok but also necessary (like for iCloud Drive folders which are not repos and cannot have their own agent settings). so an agent's permissions (what it is allowed or denied to always do) must be defined at user-level and anyway should truly apply across projects.
* Agent permissions:
  * cases where it makes sense to actually deny agent actions
    1) are local exceptions
    2) can often NOT be covered with formal rules but require intelligence
    3) can still manually be avoided with Plan/Ask mode
    4) Could still be reviewed and reverted in git repos
  * ❗ → best strategy: allow everything on a user-level and handle sensitive exceptions on a project/folder level via policies, rules, documentation and AGENTS.md files. this prioritizes productivity a bit over total safety, and that's ok.

| | Prompts | Permissions |
|---|---|---|
| **User level** | avoid | necessary |
| **Project/folder level** | primary home | possible but redundant if user-level covers it |
