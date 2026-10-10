# AI Stack Research

This folder contains ongoing research, some research topics are further along than others. gnarly extensive details here get continuously pruned as research closes in on conclusions and decisions. Results manifest in [our AI Stack](../../../../cross-platform/ai/README.md) or just move out of this research folder.

## To Do

Next research topics are prioritized to scale up productivity quickly, even at the cost of didactics:

- ✅ [Agent Customization Levels](../Agent%20Customization%20Levels.md)
	- ✅ customization of Grok Build, storing its config in stack, automate via MacStack
- ✅ [Agent Autonomy](../Agent%20Autonomy.md)
- ✅ [confidentiality and integrity - initial conversation](confidentiality%20and%20integrity/confidentiality%20and%20integrity%20-%20initial%20conversation.md)
	- ✅ Repo encryption: [Encrypting Repos](../../../../cross-platform/git/Encrypting%20Repos.md)
	- ✅ Agent isolation: [Agent Isolation](confidentiality%20and%20integrity/Agent%20Isolation.md)
	- ✅ Agent customization (here grok build): [Grok Build Permission System](../Grok%20Build%20Permission%20System.md)
	- "Sandbox" and "Permissions" settings in Zed (IDE level) ... what can they do?
- 🚧 harness + scaffolding for coding and knowledge work
	- ✅ generally: [Agent Autonomy](../Agent%20Autonomy.md)
	- ✅ still boken: [Agent Failures](../Agent%20Failures.md)
	- ✅ solution concept: [Project Harness Playbook](../Project%20Harness%20Playbook.md)
		- in particular the quality gate (in the task execution template, could be a skill)
	- 🚧 solution in practice:
		- ✅ [2026-09-08 Agent Autonomy - AI voice conversation](Agent%20Autonomy/2026-09-08%20Agent%20Autonomy%20-%20AI%20voice%20conversation.md)
		- ✅ [Project Harness Playbook In Practice](../Project%20Harness%20Playbook%20In%20Practice.md) — general means vs Grok Build, mapped onto the 11 elements
		- 🚧 template, exemplary only: [project-harness-template](../../../../cross-platform/ai/project-harness-template) — fill with practice-ready contents in a real project
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
