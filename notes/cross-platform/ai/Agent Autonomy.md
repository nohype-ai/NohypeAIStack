# Agent Autonomy

- no magic: use regular CLI coding agent, rely on its built in loop
- harness: what the agent sees directly. scaffolding: whole machinery in which the agent is employed. harness is essentially text-based context. scaffolding can also include code and infrastructure.
- long running time per-invocation is a result of mostly just the harness (like spec's scope) – not of the "right" agent or agent config itself
- one invocation can run for hours but should be limited to one self contained task, like implementing one ticket.
- a task like mowing through many tickets from a kanban board should be spread across multiple invocations (one per ticket) and requires some kind of wrapper script or dedicated conductor (like literally [Conductor](https://www.conductor.build))
- ❗key to 100x productivity is having to review very little of the agent's output, which is a result of the output's quality, which is a result of quality gates in the agent-/project harness (well specified QA requirements, unit tests, architecture documentation, code metrics, QA sub-agents, cross validation with multiple models/agents -> not everything but whatever it takes) and **not** of parallelism.
- ❗quality gates then enable longer runtimes, wich means giving agents more well specified larger-scoped tasks and sufficient other elements in the harness (task execution template, documentation, high-level objectives, etc.)
- ❗parallelism is a consequence of autonomy - not a precondition for it.
  - quality gates + large-scope tasks ➡️ short review times + long run times ➡️ parallelism possible
- parallelism is less important than expected:
  - human review is the tighter bottle neck for a 24/7 agent until review time is significantly shorter than agent run time (requires optimizing QA loops and tasks/harness)
  - parallel work on overlapping scope would require merge conflict resolution, so parallelization requires isolation of some kind. low hanging fruit here is to simply start with fully independent work scopes like distinct folders or even projects.
- 90% of what unlocks autonomous parallel agents is known good practices that apply to managing human dev teams as well
- the main difference between human and agent engineers is cost structure: agents cost much less to begin with, discarding results becomes viable (for best-of-N, retries etc.), zero cost for onboarding and idle time, nor any social cost or friction.
  - secondary differences: all knowledge must be explicit, zero initiative unless explicitly engineered, confidently-inconsistent (requires stricter verification gates)
- in principle, agents can accumulate long-term knowledge similar to humans, since agents can be empowered to evolve a project's knowledge base ([LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)) or even their own scaffolding and harness
- Obsidian is the right tool for managing the project- and agent harness, since they amount to a "process as docs" philosophy anyway