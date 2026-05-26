# AI Stack Research: To Do

Next research topics are prioritized to scale up productivity quickly, even at the cost of didactics:

- ✅ [coding agent customization](../coding/research/coding%20agent%20customization.md)
- ✅ [autonomous coding agents](../coding/research/autonomous%20coding%20agents.md)
- 🚧 [Confidentiality and Integrity](Confidentiality%20and%20Integrity.md)
- harness + scaffolding for coding and knowledge work
	- see [autonomous coding agents](../coding/research/autonomous%20coding%20agents.md)
	- spec-driven development ...
	- set up a basic example harness & scaffolding in one project as a learning ground and template
- evals / quality gates
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
