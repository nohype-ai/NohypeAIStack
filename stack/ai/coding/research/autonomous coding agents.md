# Autonomous (Background) Coding Agents

>Prompt:
>1) [@to do.md (6:11)](file:///Users/seb/Desktop/Repos/nohype-ai/company/NohypeAIStack/stack/ai/research/to%20do.md#L6:11) i have prioritized this so high because it's the core of the 10x or 100x developer promise. it's where the multiplication actually happens, and i want to know how to even approach it in practice and see how it maybe fails without the supporting stuff in place yet (like evals etc.).
>
>2) i only have a very vague and fuzzy picture in mind of what it even means to orchestrate several parallel agents and let them do near all of the software engineering. what are the basic typical elements of such a stack? does one use IDEs like Cursor or terminal agents like Claude Code? What makes them run so long, model selection, prompt, some agentic loop? who builds the loop if the agent (whether in terminal or IDE) does not have that built in? so many questions ...
>
>3) also i am very sceptical that such an autonomous software engineering system would actually produce code that is up to my standard. i experience time and again that even claude opus 4.7 misunderstands, overlooks or confuses simple things. i am an experienced software engineer and i feel that the more the user actually understands about coding, the more he will see the need to correct and steer the agent and the less scope he will let the agent deal with at a time. i can only imagine that a product built by highly autonomous agents will at some point crumble under its own complexity, inconsistency, rigidity, opaqueness etc.
>
>write me an overview of this topic into [@autonomous coding agents.md](file:///Users/seb/Desktop/Repos/nohype-ai/company/NohypeAIStack/stack/ai/research/autonomous%20coding%20agents.md) and also address my 3 main lines of thought.

Research notes, not decisions. Decisions will move into [coding/README.md](../README.md) once tested.

## Why this is the central topic

* The "10x/100x developer" promise lives or dies here. Single-prompt assistance gives ~2x at best. Real multiplication only happens when one or more agents make sustained, mostly-unsupervised progress while the human supervises rather than types. Whether that multiplication actually requires *parallel* agents — versus a single tireless sequential one — is itself an open question, examined under [When parallelism actually pays off](#when-parallelism-actually-pays-off).
* Everything else in the [to do list](../../research/to%20do.md) is in service of this:
  * customization, RAG, MCP/tools, evals, observability — all are scaffolding so that long-running, parallel agents don't drift, lie, or wreck the codebase.
  * Without that scaffolding, autonomy just ships bugs faster (see [10k LoC/day](#the-10k-locday-claim) below).
* So it makes sense to bootstrap autonomy early in a deliberately small, observable form, watch where it breaks, and let those breakages drive what to build next. The supporting layers earn their place by solving observed problems, not by being installed prophylactically.

## Anatomy of an autonomous coding setup

A "background coding agent" is not one product. It's a stack. Even the hosted offerings (Devin, Cursor Background Agents, Codex Cloud, GitHub Coding Agent) are just opinionated bundles of these layers:

1. **Runner / host** — where the agent process actually executes
   * Terminal CLI agents (Claude Code, OpenCode, Codex CLI, Gemini CLI, Amp, Cursor CLI). ✅ Best fit for background work: headless, scriptable, spawnable per task, easily piped to logs.
   * IDE-embedded agents (Cursor's IDE agent, Cline, Continue). 🛑 Interactive-by-design. Each session needs a window. Bad for parallelism.
   * Hosted background runtimes (Cursor Background Agents, Codex Cloud, GitHub Coding Agent, Devin, Jules, Amp Threads, Sourcegraph Agents). Provider runs the container, you assign tasks via web/PR/API.
   * Self-hosted agent platforms (OpenHands, SWE-agent, Aider scripted). You bring the runtime and the loop.
2. **Workspace isolation** — so parallel agents don't trample each other
   * `git worktree` per task is the cheap, local default. A worktree is a *separate working directory* checked out from the same `.git` repository, each on its own branch. Compared to:
     * a plain branch (just a label inside one working directory) — worktrees give you N concurrent live checkouts so N agents can edit and run tests simultaneously.
     * a full `git clone` — worktrees share history, hooks and remotes, are cheap to create/delete, and stay in sync with the same repo.
   * Hosted offerings use ephemeral containers / microVMs (Cursor uses Firecracker, Devin uses its own sandbox) for the same reason plus dependency isolation.
   * ❗ Worktrees only prevent *working-directory* collisions (two agents writing the same file at the same time). They do not prevent *merge conflicts* at integration. The intuition is correct: more parallelism = more chance two branches touch the same code = more conflicts that an agent or human must resolve. There is no free lunch here, only ways to push the cost down: pick fan-out tasks that genuinely don't overlap, integrate often (small PRs), and don't start agent N+1 on files that agent N hasn't yet landed.
   * ❗ Without isolation of any kind, parallelism is a lie: two agents on the same checkout = merge soup, immediately.
3. **Model** — the brain
   * Frontier coding models for hard reasoning (Sonnet 4.6, Opus 4.6/4.7, Gemini 3.1 Pro, GPT-5.4).
   * Cheap fast models for narrow subtasks (Haiku, Flash, Grok Fast, Nemotron).
   * Some agents route per call (Amp routes to "best model for this turn"), most use one model for the whole session.
4. **Agentic loop** — perceive → plan → act (tool call) → observe → repeat
   * Modern coding agents already contain this loop. You don't write it.
   * Building one yourself = building your own SWE-agent on LangGraph / smolagents / autogen / crewai / OpenHands. Defensible only if existing agents truly don't fit.
5. **Tools** — the verbs the agent can use: file edit, shell, web fetch, code search, test runner, MCP servers. (See [to do](../../research/to%20do.md) item 4.)
6. **Orchestrator / dispatcher** — what spawns and coordinates *multiple* agents (see [Orchestration patterns](#orchestration-patterns)).
7. **Task source / spec** — where work comes from: GitHub issues, plan markdown files, a kanban board, a queue. Spec-driven setups (Kiro, GitHub spec-kit) make this explicit. ❗ For us this maps directly onto Obsidian: process-as-docs is the task source.
8. **Verification gate** — what every PR/branch must pass before being accepted: types, lint, tests, evals, human review. ❗ Without a real gate, autonomy is unsafe at any speed.
9. **Memory / context substrate** — `AGENTS.md`, `README.md`, decision logs, RAG. Without it every agent restarts cold and reinvents conventions.
10. **Observability** — what each agent did, cost, latency, where it failed. (See [to do](../../research/to%20do.md) item 6.)

## What makes them run long

Common confusion: long runtime is not from "the model thinking longer per turn". It's from many turns of the same built-in loop.

* The loop is the agent's, not yours. You do not write it. You start the agent (e.g. `claude` or `opencode run`); it perceives the goal, picks a tool, observes the result, decides on the next tool, and keeps going until it judges the task done or hits a stop condition. That alone can sustain hours of work on a single launching prompt.
* What you actually control:
  * The **launching prompt** (goal + scope + acceptance criteria).
  * The **context the agent finds** as it works (`AGENTS.md`, `README.md`s, plan files, code, test output, MCP tool results).
  * The **tools/MCP** it has available.
  * Optionally, an **outer script** that re-invokes the agent in a loop with fresh context per task (see [Who builds the loop?](#who-builds-the-loop)).

What stretches a single invocation across hours:

* **Task scope.** Bigger spec = more subtasks = more turns.
* **Test-driven self-correction.** Run tests → patch → re-run → patch. This easily eats hundreds of turns.
* **Tool latency.** Each shell call, file read, web fetch is a round trip.
* **Subagent delegation.** Claude Code's `Task` tool, OpenCode subagents, Amp's worker threads — the parent agent spawns child agents that themselves loop.
* **"Don't stop until done" training.** Sonnet 4.5/4.6 and Opus 4.6/4.7 are explicitly trained to keep going through reasonable obstacles. Older models bailed early; new ones grind.
* **Plan-then-execute patterns.** Long plan, then a turn per plan item.

So model choice and prompt set the *tempo*. Total runtime is set by the agent's tooling, the size of the spec, and how strict the verification feedback is.

## Who builds the loop?

* **You almost never write the inner loop yourself.** All the CLI/IDE coding agents above ship a mature loop. Writing your own with LangGraph etc. is a separate engineering project that competes badly with what Anthropic / OpenAI / Cursor / Sourcegraph already maintain.
* **What you optionally build is one layer up:** an *outer* loop that supplies new tasks (and a fresh context window) to fresh agent invocations.

Concrete example — "mow through every ticket on a kanban board":

* **Single launching prompt, no outer script.** You can tell Claude Code: *"open `kanban.md`, pick the top unfinished ticket, branch, implement, run tests, push a PR, mark the ticket done, then repeat"*. It will probably finish a few tickets, but eventually accumulate too much context, lose plot mid-loop, or stop. Works for a handful of tickets at most. Not what you want for hours of unattended work.
* **Outer wrapper script (the actual answer for hours of unattended work).** A small shell loop that, for each ticket: creates a worktree, invokes `claude` (or `opencode run`) headlessly with that ticket's spec as the prompt, captures the log, opens the PR, and moves on. Each invocation gets a clean context window and predictable behavior. This is the form that runs overnight without surprises. Most coding agents support a non-interactive / headless mode specifically for this (Claude Code: `claude -p`; OpenCode: `opencode run`; Codex CLI: similar).
* **Next step up:** a small job queue (a markdown plan file is enough) plus retries, PR creation, and status reporting written back to the kanban file.

Tooling that already wraps this:

* Conductor (Charm) wraps the outer-loop pattern around Claude Code specifically.
* Hosted services (Cursor Background Agents, GitHub Coding Agent, Codex Cloud, Devin, Amp Threads) sell that exact outer wrapper plus a managed runtime.

❗ Rule of thumb: **one agent invocation = one bounded task with a clear definition of done.** Long horizons come from chaining many such invocations, not from making one invocation chew on the whole roadmap.

## Orchestration patterns

| Pattern | Idea | Good for | Notes |
|---|---|---|---|
| **Fan-out** | N independent tasks, N agents in N worktrees | Bug bash, refactor pass, test backfill | Simplest. Demands tasks that genuinely don't conflict. |
| **Pipeline** | spec → implement → review → tests, each a separate agent | Single feature with quality gates | Each stage's output is the next stage's input. Maps onto PR review. |
| **Hierarchical** | One orchestrator agent delegates to subagents | Larger feature decomposed on the fly | Built-in to Claude Code (`Task`), OpenCode (subagents). Token cost compounds. |
| **Best-of-N** | Same task, N attempts, pick best (or merge) | Hard problems with cheap verification | Wasteful but effective when a deterministic check exists. |
| **Swarm / consensus** | Multiple peers vote | Research-y; rarely worth it for coding | Mostly hype outside narrow domains. |

❗ For someone bootstrapping: start with **fan-out on independent tasks** + **pipeline for the verification stage**. Hierarchical and best-of-N can be added when the simple patterns hit a ceiling.

## Concrete tools landscape (Q2 2026)

| Tool | Hosted? | Loop | Orchestration | Notes |
|---|---|---|---|---|
| Claude Code (CLI) | local | ✅ | ❌ (single agent per invocation) | Strongest single-agent loop. Pair with worktrees + scripts to scale out. |
| OpenCode (CLI) | local | ✅ | partial (subagents) | BYOK, open-source, scriptable. Best fit for self-built orchestration. |
| Codex CLI | local | ✅ | ❌ | OpenAI's CLI; mirrors Claude Code's shape. |
| Cursor CLI | local | ✅ | ❌ | Tied to Cursor subscription. See [coding stack notes](../README.md). |
| Amp (CLI/web) | hybrid | ✅ | ✅ (Threads) | Multi-model routing built in. Costs add up fast. |
| Conductor | local | — | ✅ (over Claude Code) | A thin orchestration shell around Claude Code. Worth watching. |
| Cursor Background Agents | hosted | ✅ | ✅ | MicroVM per task, opens PRs. Tied to Cursor account. |
| GitHub Coding Agent | hosted | ✅ | ✅ | Assign issues, get PRs. Tightest GitHub integration. |
| Codex Cloud | hosted | ✅ | ✅ | Same idea, OpenAI-flavored. |
| Devin | hosted | ✅ | ✅ | The original "AI engineer" pitch. Expensive, opaque. |
| Jules | hosted | ✅ | ✅ | Google's entry. |
| OpenHands | self-host | ✅ | ✅ | Open-source platform. The serious DIY route. |
| SWE-agent | self-host | ✅ | ✅ | Research-flavored, paper-driven. |

## The 10k LoC/day claim

Repeated everywhere. Worth defusing.

* The number is almost always "lines generated", not "lines kept and shipped".
* Counts usually include scaffolding, vendored deps, generated configs, test stubs.
* Doesn't subtract the rework / discarded branches / failed PRs.
* Mostly demoed on **greenfield** code where consistency hasn't yet been put under stress.
* Teams that *do* sustain high autonomous throughput share one trait: a real verification layer (types + tests + evals) that catches the agent's mistakes before merge. Without that layer the throughput number is the bug-shipping rate.
* ❗ So: yes, achievable, but the headline number is the wrong KPI. The honest KPI is "merged-and-still-green-after-a-week".

## What's actually different from a human team

Fair observation: most of the principles in this document — `AGENTS.md` as code-of-conduct, definition of done, specs, QA loops, small PRs, branch-per-feature, decision logs — are a re-invention of how a sane human team operates. That's not an accident and not a defect of the framing. Software engineering at multi-actor scale always rediscovers the same core practices, regardless of whether the actors are human, agent, or mixed.

The interesting question is what's *actually* different, because that's the part where naive analogies to managing humans break and where agent-specific tooling earns its place.

| Dimension | Human team | Agent team |
|---|---|---|
| Cost shape | Salary, mostly fixed. Idle time is a sunk cost. | Per-token, mostly variable. Idle time is free. |
| Parallelism cost | High (hiring, coordination, comms overhead). | Low (`git worktree`, another process). |
| Ramp-up | Days to months. Skill compounds over time. | Zero. No skill carries between sessions; every run starts cold from the docs. |
| Tacit knowledge | Absorbed from hallway, reviews, pairing. | Cannot be absorbed. Must be made explicit in `AGENTS.md`/READMEs/specs or it doesn't exist. |
| Initiative | Humans raise concerns, push back, escalate. | Agents don't, unless explicitly prompted to. They confidently do the wrong thing in silence. |
| Failure mode | Tired, distracted, political, lazy — but usually internally consistent. | Hallucinates, loses plot mid-task, fabricates APIs, "fixes" symptoms. Confidently inconsistent. |
| Memory | Persistent and selective. | Per-session and total. Once the context window closes, it's gone. |
| Discardability | High social/financial cost to throw away work or restart. | Zero. Throwing away a bad branch and re-running is normal. |
| Best-of-N | Practically impossible. | Cheap and routine. |
| Speed per task | Hours to days. | Minutes to hours. |
| Reviewability | Self-explains in person. | Explanation lives only in PR description and diff. |

Practical consequences for the stack:

* **The principles transfer; the dials don't.** "Small PRs" and "definition of done" stay; the right value of "small" is *smaller* for agents, because review of an agent PR is harder than review of a colleague's PR (no shared context, no in-person clarification, see [The reviewer bottleneck](#the-reviewer-bottleneck)).
* **Documentation becomes load-bearing.** With humans, undocumented knowledge survives in heads. With agents it does not exist. This is exactly why [agent customization](coding%20agent%20customization.md) concludes the win is essentially "do classical good documentation, finally".
* **Throwing away work is a feature, not a failure.** Best-of-N, restart-from-scratch, "delete the branch and try again with a tighter spec" are first-class tactics with agents and almost taboo with humans.
* **Initiative must be engineered.** A human reports "this spec is ambiguous". An agent has to be given a "user-as-MCP-tool" channel (see [to do](../../research/to%20do.md) item 4) or it will guess.
* **Coordination overhead inverts.** With humans, parallelism is expensive and coherence is cheap. With agents, parallelism is cheap and coherence is expensive — coherence comes from docs/specs/types/tests, not from people talking.

## Honest scope: where autonomy actually works

The skepticism is well-founded. Frontier models *do* misread, overlook, confuse. The senior engineer's instinct to shorten the leash is correct, not a sign of being out of touch. So the right question is not "will autonomy work?" but "where does it work *today* with my standards intact?".

| Task type | Autonomy fit | Why |
|---|---|---|
| Greenfield prototype | ✅ | No legacy consistency to violate. |
| Refactor with tests in place | ✅ | The tests *are* the spec; the agent has a tight feedback loop. |
| Codebase migration (lib version, framework, syntax) | ✅ | Mechanical, repetitive, verifiable. |
| Test backfill, doc backfill | ✅ | Output is itself the verification artifact. |
| Issue triage / first-pass fix | ✅ | Cheap to discard if wrong. |
| Bug fix in a well-typed module | ⚠️ | Works if the bug is local. Fails when root cause is architectural. |
| New feature in mature codebase | ⚠️ | Conventions matter; agent needs strong `AGENTS.md` and `README.md` discipline. |
| Cross-cutting change (auth, logging, error model) | 🛑 | Touches too many invariants the agent can't see. |
| Architectural decision | 🛑 | Spec is the hard part; agent has no taste. |
| Performance / security sensitive code | 🛑 | Failure modes are silent. Verification is hard. |

❗ The takeaway from the third concern: an experienced engineer who shortens the leash isn't fighting the technology — they're correctly using it within its current bounds. The way to widen the bounds is not to grant more autonomy and hope, but to invest in the **verification gate** and the **spec quality**. Both shift the trust boundary outward without requiring the model to suddenly become wiser.

## The reviewer bottleneck

The PR-size trade-off is real and not solved by any prompt or agent. The human reviewer's attention is the actual scarce resource of the whole stack.

* **Small PRs:** easy to review individually, but arrive often, fragmenting deep-work time. The "fast feedback for the agent" win is paid for in human context-switching.
* **Large PRs:** rare interruptions, but past ~300–500 changed lines review quality drops sharply, and past ~1500 it's mostly LGTM theatre. Past a certain size the human cannot meaningfully review at all.

There is no PR size that defeats this trade-off. What helps is reducing how much PR review actually has to land on the human:

* **Tiered gates.** Cheap automated gate first (typecheck, lint, tests, a fast eval); then a *reviewer agent* for structural/style/anti-pattern review; then human only on what cleared both. The human reviews fewer PRs but with higher concentration.
* **Async review by default.** Treat agent PRs like email, not pages. Pull from a review queue on your schedule; agents don't care if a PR sits four hours.
* **Trust gradient by task type.** Migrations, refactors-with-tests, doc/test backfill — sample-review only. Architectural changes, security/perf-sensitive code — deep review every time. Same shape as [Honest scope](#honest-scope-where-autonomy-actually-works) above.
* **Specs as the actual review surface.** Reviewing the *spec* the agent worked from is often higher leverage than reviewing the diff. A wrong spec produces wrong code consistently; a right spec produces code that mostly only needs a sanity check.
* **Batch reviews.** N PRs in one sitting once or twice a day, not interrupt-driven. Agents can be told to wait.

❗ Even with all of the above, the reviewer remains the rate-limiting step of the whole pipeline. Any "10x" claim that ignores reviewer capacity is overcounting. The honest design goal is to keep the human in the loop where judgement matters and out of it where it doesn't, not to remove them.

## When parallelism actually pays off

Worth challenging the premise head-on. A single agent running 24/7 on well-bounded sequential tasks captures most of the realistic productivity gain for a solo operator. Genuine intra-project parallelism brings real costs (conflict prevention, merge resolution, harder review, harder observability) and is not free throughput.

When parallelism is worth those costs:

* **Independent tasks across the codebase.** Bug bash, test backfill, doc generation, migrations applied module-by-module. Conflict surface is genuinely small, fan-out wins.
* **Latency-sensitive single tasks.** When *this one* PR has to land soon and the agent's loop is dominated by sequential test runs, internal parallelism (e.g. several `Task` subagents on different sub-pieces) can help. Niche.
* **Best-of-N on hard problems with cheap verification.** Multiple attempts at the same task, pick the one that passes tests / evals / your taste. Wasteful in tokens, cheap relative to a stuck agent.
* **Across projects.** The simplest, lowest-conflict form of parallelism. Two unrelated repos, two agents, no shared filesystem state, no merge collisions, no shared review queue beyond your attention. ❗ For a solo operator this is often the highest-leverage form: sequential within a project, parallel across projects.

When parallelism is *not* worth it:

* Non-trivial features in the same module (conflict surface > parallelism gain).
* Anything where review depth matters (you become the bottleneck immediately).
* Architectural or cross-cutting work (parallel agents will diverge in ways no merge resolves).
* Before automated verification is in place (each parallel run multiplies the bugs you don't catch).

❗ Honest framing: "swarm of parallel autonomous agents" is the marketing pitch. The realistic operator pattern is closer to **one tireless sequential agent per project, plus occasional batched fan-outs for genuinely independent work, plus best-of-N when a hard task can be cheaply judged**. Aim for that first; treat aggressive intra-project parallelism as a later optimization adopted only when a specific pain demands it.

## Failure modes when you skip the supporting stack

Useful as a checklist of what to expect when starting before the rest of the [to do](../../research/to%20do.md) is in place:

* **No evals / weak tests** → silent quality drift. PRs look fine, regressions accumulate. The exact failure mode that produces the "AI codebase that crumbles" mentioned in the third concern.
* **No `AGENTS.md` / weak `README.md`s** → each agent reinvents conventions. Inconsistency compounds across PRs. (Mitigation principles already collected in [coding agent customization](coding%20agent%20customization.md).)
* **No RAG / no decision log** → agents repeat decisions you already rejected, reintroduce dead patterns.
* **No observability** → when something goes wrong across N parallel runs you cannot tell which agent did what or why. Debugging time eats the throughput gain.
* **No isolation (worktrees / containers)** → parallel runs corrupt each other.
* **No "ask the user" channel** → agents either block silently or, worse, guess and proceed. (See `to do` item 4: user-as-MCP-tool.)
* **Weak typing / no static analysis** → loop never gets honest feedback; agent thinks it's done when it isn't.
* **Greenfield-only validation** → the setup feels great until applied to a real codebase, then collapses. Test the stack on actual existing code early.

## Suggested first setup

Smallest thing that exercises the whole stack and exposes its weaknesses:

1. **One frontier coding agent** (Claude Code or Amp), driven from the terminal. CLI not IDE. (See [coding stack](../README.md).)
2. **Worktrees** as the isolation primitive: `git worktree add ../proj-task-N`.
3. **Plan files in Obsidian** as the task source. One markdown file per task, with acceptance criteria explicit.
4. **`AGENTS.md` + good `README.md`s** as the standing context. (Already covered in [agent customization](coding%20agent%20customization.md).)
5. **Verification gate**: typecheck + lint + existing tests must pass before merge. No exceptions.
6. **Start sequential, not parallel.** One agent, one task, one project at a time. Per [When parallelism actually pays off](#when-parallelism-actually-pays-off), 24/7 sequential is most of the available win for a solo operator. Add parallelism only across projects (lowest conflict surface) or for clearly independent fan-out work, and only after the verification gate has proven it catches mistakes.
7. **Manual orchestration first**: `tmux` panes plus a small shell script invoking the agent headlessly per task. Don't adopt Conductor / Background Agents / Devin until the manual version reveals what they'd actually solve.
8. **Log everything**: redirect agent stdout/stderr to per-task log files. This is the seed of observability.
9. **Run on a real (small) codebase**, not a greenfield demo. The whole point is to see where it breaks under realistic constraints.

Once that hurts in specific ways, those pains become the prioritized order of the rest of [to do](../../research/to%20do.md): evals, RAG, MCP, observability, and so on.

## Open questions to resolve through use

* Does Claude Code or OpenCode handle long autonomous runs better in practice on this kind of work?
* How well do worktrees + a plan-file workflow integrate with Obsidian as the operator UI?
* What's the smallest useful eval — even just "tests pass + lint clean + diff under N lines" — that meaningfully filters bad PRs?
* Is `AGENTS.md` enough to keep multiple parallel agents stylistically coherent, or is some active enforcement (formatter, linter, review agent) required?
* When does hosted (Cursor Background Agents / GitHub Coding Agent) start to beat local CLI + worktrees on real throughput, and at what cost?
* What does a "user-as-MCP-tool" channel actually look like when several agents need to ask questions concurrently?
* What's the empirical break-even point at which intra-project parallelism beats single-agent sequential on this codebase, and is that point ever reached in practice for a solo operator?
* How many agent PRs per day can a single reviewer absorb at meaningful depth, and how much can tiered gates (typecheck → tests → reviewer agent → human) actually reduce that load before review becomes theatre?

## Q&A

### Questions:

1) what is a git worktree (compared to a branch) and why does it mitigate merge conflicts? i assume the more parallelism the more potential conflicts that some agent or human must resolve. there is no way around this trade-off.
2) i see this trade-off: if the agent proiduces small reviewable PRs, the frequency of reviews is higher and the human is interruped more, leaving her less opportunnity to use the time in between the reviews for other work. the bigger the PRs are the less a human can review them in a valuable way.
3) what is actually unique about agent teams as opposed to human teams? all of the principles and techniques seem like a re-invention of managing a human developer team: code of conduct, definition of done, specs, QA loops, small PRs, every feature on its own branch, document done work etc.
4) about the "long running" part: so basically what makes the agent run long is how it's prompted (including all the context it finds), and other than that we use the same loop the agent (Claude Code for example) has already built in? plus maybe the scripts we wrap around headless calls of agents? for example if i want the agent to run in a loop and just mow through the tickets on a kanban board, can claude code do that with one launching prompt? to run for hours? or will this require some additional scaffolding script?
5) why is parallelism even that important when a) i can run an agent 24/7, b) parallelism adds the cost of conflict prevention and resolution, c) i could just as well have parallel agents work on completely different project, so I deliver more in total but avoid all the problems of actual parallelism.
6) about parallelism: i think i could hardly review as much output as a 24/7 agent could produce. so i guess that the art is not in parallelizing but in improving the agent's harness continuously to get away with reviewing a smaller and smaller fraction of the agent's output?
7) is there a difference in this context between the agent's harness and its scaffolding?
8) it's like harness plus scaffolding becomes a reusable thing in its own right. there must be many templates for that and its own terminolgy around this out there, i guess.

### 1) Worktrees vs branches, and the conflict trade-off

A **branch** is just a label inside one working directory. To switch branches you change what's checked out *in that one directory*. So if you have one checkout, two agents can't be on two branches at the same time without overwriting each other's files.

A **`git worktree`** is a *second working directory* attached to the same `.git` repository. Same history, same remotes, same hooks — but a separate folder on disk, on its own branch. So `git worktree add ../proj-task-A featureA` gives you a parallel checkout. Lighter than `git clone` (no duplicated history, instant to create/delete), heavier than just a branch (real files on disk).

What worktrees actually fix: **working-directory collisions**. Two agents writing to the same file at the same moment, or one agent's `npm install` clobbering another's dev server. With worktrees that whole class of problem disappears.

What worktrees do **not** fix: **merge conflicts at integration time**. You're exactly right — more parallelism = more chance two branches touched the same code = more conflicts to resolve. There is no way around this trade-off. The only knobs are:

- pick fan-out work that genuinely doesn't overlap (test backfill, per-module migration, doc generation),
- integrate often (small PRs land before the next branch starts on touched files),
- treat overlapping-file branches as a serial dependency, not parallelism.

So worktrees buy you cheap parallel *execution*. They don't buy you cheap parallel *integration*. That cost is real and someone (agent or human) eats it.

### 2) Small PRs vs large PRs (reviewer bottleneck)

You've correctly identified what is in my view the actual rate-limiting step of the whole "autonomous coding" stack.

The trade-off is exactly as you described and **no PR size defeats it**:

- Small PRs interrupt you often, fragmenting deep work.
- Large PRs interrupt you rarely but past ~300–500 changed lines review quality drops fast, and past ~1500 you're rubber-stamping.

What actually helps is reducing how much review has to land on you at all:

- **Tiered gates.** Cheap automated checks first (typecheck, lint, tests, fast eval), then a *reviewer agent* doing a structural/style/anti-pattern pass, then you — only on what cleared both layers. You review fewer PRs but at higher concentration.
- **Async review by default.** Agent PRs are not pages, they're email. Pull from a queue on your schedule. Agents don't care if a PR sits four hours.
- **Trust gradient by task type.** Sample-review on migrations, refactors-with-tests, doc/test backfill. Deep-review every architectural or security/perf change. The leash length should match the failure cost.
- **Review the spec, not the diff.** A wrong spec produces wrong code consistently and a right spec produces code that mostly only needs a sanity check. Spending review attention on specs has higher leverage per minute than reading diffs.
- **Batch reviews.** Two sittings a day, not interrupt-driven.

Even with all of this, you remain the bottleneck. Any "10x" pitch that ignores reviewer capacity is overcounting. The honest design goal is to keep you in the loop where judgement matters and out of it where it doesn't, not to remove you.

### 3) What's actually unique about agent teams vs human teams

You're right that ~80% of the principles being re-discovered (definition of done, specs, small PRs, branch-per-feature, code of conduct, decision logs) are just sane human-team practice. That's not a defect of the framing — it's that multi-actor software always rediscovers the same core practices regardless of who the actors are.

The interesting 20% — where naive analogies to managing humans break — is where agent-specific tooling earns its place:

| Dimension | Human | Agent |
|---|---|---|
| Cost shape | Salary, fixed. Idle = sunk cost. | Per-token, variable. Idle = free. |
| Parallelism cost | High (hiring, coordination, comms). | Low (`git worktree`, another process). |
| Ramp-up | Days to months, skill compounds. | Zero. Every run starts cold from the docs. |
| Tacit knowledge | Absorbed from hallway/reviews/pairing. | Cannot be absorbed. Must be made explicit or it doesn't exist. |
| Initiative | Raises concerns, pushes back, escalates. | Doesn't, unless explicitly prompted to. Confidently does the wrong thing in silence. |
| Failure mode | Tired, lazy, political — usually internally consistent. | Hallucinates, loses plot, fabricates APIs, "fixes" symptoms. Confidently inconsistent. |
| Memory | Persistent and selective. | Per-session and total. Window closes → gone. |
| Discardability | High social/financial cost to throw away work. | Zero. Restart-from-scratch is normal. |
| Best-of-N | Practically impossible. | Cheap and routine. |
| Speed per task | Hours to days. | Minutes to hours. |
| Reviewability | Self-explains in person. | Explanation lives only in PR description and diff. |

The practical consequences I think actually matter:

- **The principles transfer; the dials don't.** "Small PR" for a colleague might be 500 lines; for an agent it's smaller, because review is harder (no shared context, no in-person clarification).
- **Documentation becomes load-bearing.** Undocumented knowledge survives in human heads. With agents it doesn't exist. This is why the [agent customization](coding%20agent%20customization.md) doc concludes the win is essentially "do classical good documentation, finally".
- **Throwing away work is a feature, not a failure.** Best-of-N, restart-from-scratch, "delete the branch and try again with a tighter spec" — first-class with agents, taboo with humans.
- **Initiative must be engineered.** A human asks "this spec is ambiguous, what do you mean?". An agent has to be *given* a question channel (a "user-as-MCP-tool") or it will just guess.
- **Coordination overhead inverts.** With humans, parallelism is expensive and coherence is cheap (people talk). With agents, parallelism is cheap and coherence is expensive — coherence comes from docs/specs/types/tests, not from talking.

So the answer to your question is: yes, you're rediscovering team-management principles, that's correct and unavoidable. What's *new* is that the cost structure inverts in the table above, and that inversion is what the whole stack is shaped around.

### 4) Long-running mechanics: prompt + built-in loop, plus a kanban example

Yes — your model is essentially correct. Specifically:

- **The loop is the agent's, not yours.** Claude Code, OpenCode, Codex CLI etc. each ship a mature inner loop (perceive → pick a tool → observe → repeat). You don't write it and shouldn't. Building your own with LangGraph/autogen/crewai means competing against products with whole teams behind them.
- **What you control is around it:** the launching prompt, the context the agent finds (`AGENTS.md`, READMEs, plan files, code, test output, MCP results), the tools/MCP available, and *optionally* an outer script that re-invokes the agent in a loop.
- **A single launching prompt can sustain hours.** That's the agent's loop self-perpetuating as long as it has work to do. Sonnet 4.5/4.6 and Opus 4.6/4.7 are explicitly trained "don't stop until done", so they grind through where older models bailed.

For your specific kanban example:

- **One prompt, no outer script.** You can tell Claude Code: *"open `kanban.md`, pick the top unfinished ticket, branch, implement, run tests, push a PR, mark done, repeat"*. It will probably get through a few tickets. Then it will accumulate too much context, lose plot mid-loop, or stop. Workable for a handful of tickets. **Not** what you want for hours of unattended work.
- **Outer wrapper script — the actual answer for overnight runs.** A small shell loop that for each ticket creates a worktree, invokes the agent *headlessly* (Claude Code: `claude -p "<spec>"`; OpenCode: `opencode run`; Codex CLI: similar) with that one ticket's spec as the prompt, captures the log, opens the PR, moves on. Each invocation gets a fresh context window and predictable behavior. This is the form that actually runs overnight without surprises.
- **Next step up:** queue + retries + status reporting back to the kanban file. Conductor is essentially this for Claude Code; Cursor Background Agents / GitHub Coding Agent / Codex Cloud / Devin are the same outer loop sold as a managed service.

Rule of thumb: **one agent invocation = one bounded task with a clear definition of done.** Long horizons come from chaining many such invocations, not from making one invocation chew on the whole roadmap. The outer chaining is the part you (or a tool like Conductor) build; the inner grinding is the part the agent already does.

### 5) Whether parallelism even matters

Honest answer: for a solo operator your skepticism is largely correct. A single agent running 24/7 sequentially captures most of the realistic productivity gain. "Swarm of parallel autonomous agents" is mostly the marketing pitch, not the realistic operator pattern.

When intra-project parallelism *is* worth its costs:

- **Independent fan-out tasks** with genuinely small conflict surface: bug bash, test backfill, doc generation, per-module migration. This is the strongest case.
- **Latency-sensitive single tasks**, where *this one* PR has to land soon and the agent's loop is dominated by sequential test runs. Internal parallelism (subagents on different sub-pieces) can shave wall-clock. Niche.
- **Best-of-N on hard tasks with cheap verification.** N parallel attempts, pick the one that passes tests/evals/your taste. Wasteful in tokens, cheap relative to a stuck agent.

When it's *not* worth it (the cases your instinct is correctly flagging):

- Non-trivial features in the same module — conflict surface > parallelism gain.
- Anything where review depth matters — you become the bottleneck immediately (see Q2).
- Architectural or cross-cutting work — parallel agents diverge in ways no merge resolves.
- Before automated verification is in place — each parallel run multiplies bugs you don't catch.

Your option (c) — **parallelism across different projects** — is in my view the highest-leverage form for a solo operator and the most underrated. Two unrelated repos, two agents, no shared filesystem state, no merge collisions, no shared review queue beyond your attention. Almost all the throughput, almost none of the conflict cost.

So the realistic operator pattern is closer to: **one tireless sequential agent per project, plus occasional batched fan-outs for genuinely independent work, plus best-of-N when a hard task can be cheaply judged.** Aim for that first. Treat aggressive intra-project parallelism as a later optimization adopted only when a specific pain demands it.

### 6) Trust ratio as the real limiting factor

Your observation on parallelism is, I think, the actual core insight of all of this. Worth stating sharply: **the bound on autonomous coding throughput is the fraction of agent output you must read, not the rate at which agents produce it.** Once you internalize that, the entire to-do list reorders itself around one question — *"what would let me skip reading this PR?"* — and evals, types, tests, reviewer agents, `AGENTS.md` discipline and tight specs all stop being "good practice" and become the actual bottleneck-busters. The whole rest of the stack exists to raise the trust ratio.

Two distinct paths get you there, both usually needed:

- **Trust the gate, not the human.** Make the automated verification so thorough (typecheck + tests + evals + reviewer agent) that human review can sample rather than cover. The agent ships, the gate catches, you spot-check.
- **Keep tasks bounded enough that review is cheap.** Each PR is so well-scoped that 60 seconds of glancing is enough. This is mostly a function of spec quality, not agent quality.

A nice corollary: this also reframes parallelism. Parallelism only buys throughput up to your review capacity. The trust ratio multiplies it. So 1 agent at 90% trust beats 5 agents at 30% trust, by a wide margin and with far fewer integration headaches.

### 7) Harness vs Scaffolding

**Harness vs scaffolding** — honest answer: not strictly defined, often interchangeable in practice, especially in academic papers (the original SWE-agent paper uses "scaffolding" for what most practitioners now call "harness"). But there's a useful working distinction that some of the field is converging on:

- **Harness** = the *persistent runtime envelope the agent operates inside, per invocation*. System prompt, tools, MCP servers, context window contents, `AGENTS.md`, the agent definition, sub-agent definitions, RAG hookup. The thing the model lives in. Closer to the model, mostly invisible from outside.
- **Scaffolding** = the *broader supporting machinery around the autonomous setup as a whole, across many runs*. Evals, CI gates, the orchestrator script, worktree setup, the kanban file, observability/logging, reviewer-agent pipelines. What wraps the operation end-to-end. Closer to the operator, mostly visible from outside.

Or even shorter: **harness is what the agent sees; scaffolding is what surrounds it**. An MCP server is harness. A Conductor-style outer loop is scaffolding. An `AGENTS.md` is harness. A nightly eval suite is scaffolding. The verification gate sits on the boundary — you could call either.

Don't trust anyone who claims a hard line between the two; do feel free to use the distinction yourself when it clarifies which layer of the stack you're discussing.

### 8) Templates for Harness + Scaffolding

Yes, exactly — and the field is currently in active terminology-formation around it, which is why it feels like there *should* be a name but you can't quite pin one down. There are several competing terms and several emerging artifact-shapes, none yet dominant:

**Terms in circulation** (loosely ordered from harness-flavored to scaffolding-flavored):

- **Skill / Agent Skill** — Anthropic's `SKILL.md` packaged capabilities (you've already seen these in your Cursor sidebar). Reusable harness fragments, distributable.
- **Subagent / Agent definition** — Claude Code, OpenCode, Cursor agents-as-files. Reusable role/persona/tools bundles.
- **Crew / Squad** — CrewAI's name for a packaged team of agents with roles and a workflow. MetaGPT does the same thing under "software company" framing.
- **Microagent** — OpenHands' term for small reusable agent definitions.
- **Recipe / Cookbook** — Anthropic, OpenAI, LangGraph, CrewAI all use this for documented patterns.
- **Workflow / Pipeline template** — LangGraph templates, n8n/dify workflows.
- **Spec kit** — GitHub's `spec-kit` is probably the closest current example of a packaged harness-plus-scaffolding *for a whole repo*: spec format, plan format, scripts, prompts, agent guidance, all in one drop-in.
- **Spec-driven development (SDD)** — the methodology that wraps the above. AWS Kiro is built around this.
- **Engineering OS / "Operating system for agents"** — marketing terms aiming at the same combined artifact, mostly vapor so far.
- **Starter / template repo** — the cookiecutter-style answer: `AGENTS.md` + `.cursor/rules` + evals dir + headless invocation scripts + worktree helpers + PR automation, all pre-baked. Several "Claude Code starter" / "ClaudeOps" repos floating around GitHub.

**Honest read on the state of it:**

- The reusable artifact is real and forming, but the name hasn't settled. "Skill" is winning at the small/in-context end; "spec-kit" / "starter template" is winning at the whole-repo end; nothing yet owns the middle.
- Most existing templates are *opinionated* about either harness *or* scaffolding, rarely both. A `SKILL.md` ships harness without scaffolding. A `spec-kit` ships scaffolding with thin harness.
- A truly drop-in "harness + scaffolding bundle" — eval suite, plan format, AGENTS.md, agent definitions, headless runner, worktree manager, observability hooks, all coherent — does not really exist as a polished off-the-shelf product yet. Most teams assemble their own from these parts.
- ❗ This is one of the cases where it's worth *watching* the terminology rather than committing to one. In 12 months one of "skill", "crew", "spec kit", or something not yet named will likely have eaten the rest. Until then, building your own bundle (and naming it whatever's useful internally) is reasonable — and is exactly what the suggested first setup in the doc amounts to.

## ❗ My Main Takeaways

- no magic: use regular CLI coding agent, rely on its built in loop
- harness: what the agent sees directly. scaffolding: whole machinery in which the agent is employed. harness is essentially text-based context. scaffolding can also include code and infrastructure.
- long running time per-invocation is a result of mostly just the harness (like spec's scope) – not of the "right" agent or agent config itself
- one invocation can run for hours but should be limited to one self contained task, like implementing one ticket.
- a task like mowing through many tickets from a kanban board should be spread across multiple invocations (one per ticket) and requires some kind of wrapper script or dedicated conductor (like literally [Conductor](https://www.conductor.build))
- key to 10x productivity is having to review very little of the agent's output, which is a result of the output's quality, which is a result of the agent's harness and scaffolding (specs, qa steps etc.) and **not** of parallelism
- parallelism is less important than expected: human review likely the tighter bottle neck for a 24/7 agent, parallel work on overlapping scope would require merge conflict resolution, so parallelization should start with fully independent work items (ideally even distinct projects)
- 90% of what unlocks autonomous agents is known good practices that apply to managing human dev teams as well
- the main difference between human and agent engineers is cost structure: agents cost much less to begin with, discarding results becomes viable (for best-of-N, retries etc.), zero cost for onboarding and idle time, nor any social cost or friction.
  - secondary differences: all knowledge must be explicit, zero initiative unless explicitly engineered, confidently-inconsistent (requires stricter verification gates)
- in principle, agents can accumulate long-term knowledge similar to humans, since agents can be empowered to evolve a project's knowledge base ([LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)) or even their own scaffolding and harness
- Obsidian is the right tool for managing the harness and large parts of the scaffolding, which amount to a "process as docs" philosophy
