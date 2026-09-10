# AI Stack Research

This folder contains ongoing research, some research topics are further along than others. gnarly extensive details here get continuously pruned as research closes in on conclusions and decisions.

## To Do

Next research topics are prioritized to scale up productivity quickly, even at the cost of didactics:

- 🚧 [coding agent customization](coding%20agent%20customization.md)
	- 🚧 customization of Grok Build, storing its config in stack, automate via MacStack
- ✅ [autonomous coding agents](autonomous%20coding%20agents.md)
- 🚧 [confidentiality and integrity](confidentiality%20and%20integrity.md)
	- ✅ main practical results is [Encrypting Repos](../../git/Encrypting%20Repos.md)
	- 🚧 how this works in Grok Build (rules, policies ...)
- 🚧 harness + scaffolding for coding and knowledge work
	- ✅ generally: [autonomous coding agents](autonomous%20coding%20agents.md)
	- ✅ still boken: [Agent Failures in Codeface](Agent%20Failures%20in%20Codeface.md)
	- ✅ solution concept: [Dev Harness Playbook](../dev%20harness/Dev%20Harness%20Playbook.md)
		- in particular the quality gate in the task completion guide
	- 🚧 solution practice:
		- Relate/apply the explicit practical means and conventions beyond just general markdown:
			- Agents.md, agentskills.io, custom agents
			- and what's possibly specific to Grok Build: plugins, personas, hooks, workflows
		- gather a basic template here for a harness, tested and proven in one specific project
- evals / quality gates (deeper dive into this part of the harness)
   - automated quality assessment of agent output
   - generating tests alongside code (even for shell scripts?)
   - regression suites, benchmark runs
   - the unglamorous answer to "10k LoC/day with quality and control?". without it, autonomous agents just ship bugs faster
- mcp servers / tooling / environment
   * and generally how to inspect and control the environment of agents (tools/context)
   * LeanCTX, efficient token use
   * the user as a (mcp) tool: so agents can ask the user clarifying questions (like an employee would) without breaking ther regular procedure of finishing a prompt/task/job. multiple agents could use the same tool, so the user can handle all questions in one channel.
   * mcp versus skills?
   * is mcp even useful/necessary since models are increasingly cabable to just use the shell, including pulling up man pages etc...?
   * what are ways/tools to tighten the agernt's feedback loop in the sense that the agent can retrieve screenshots of a website, run terminal copmmands and see the output, get screenshots of an app, maybe even walk through an app or website interactively etc.
- rag / knowledge management
   * semantic retrieval of your own docs, codebases, notes, decisions
   * embeddings, vector stores, retrieval pipelines
   * distinct from MCP (tools) — this is about knowledge
   * LLM Wiki
   * see also: Context7
- observability / tracing
   * understanding what agents are doing (token cost, latency, failures)
   * LangFuse, Helicone
   * prompt degradation over time
   * multi-agent failure debugging
- personal agents
   * Grok Bot
   * openclaw
   * claude cowork
- local inference
   * mlx
   * mlx-lm
   * ollama
   * llama.cpp
   * LMStudio
   * LiteLLM
   * (vLLM)
- extra capabilities that I have put off:
  - the agent should reliably be able to generate visual assets in marketing, design and prototyping work like when building apps, websites or online posts. agents increasingly have that built in, but it needs to be tested and likely be prompted in the harness ...
