# "Good Enough" Has Downstream Costs

*A conversation summary by Grok 4.7 (High) on September 30, 2026*.

Cost-per-task leaderboards measure whether a model finished *this* ticket cheaply. They do not measure whether that ticket made the next fifty tickets cheaper or dearer. For a product that will live months or years, the second number is the one that matters.

**A slightly weaker first pass can look cheaper on the scoreboard and still lose on total cost of ownership**.

---

## Why benchmarks miss quality

Per-task suites are built to be comparable, short, and auto-gradable. That design drops the costs that actually compound.

- **The unit is one isolated task.** There is no next sprint, no second feature on the same module, no on-call.
- **The grader is usually “tests pass.”** Green tests do not mean the change matches existing patterns, is the smallest fix, or is safe under the failure modes nobody wrote a test for.
- **Out-of-scope work is under-penalized** except on a few suites (e.g. FrontierCode). Extra files, extra abstractions, and “helpful” refactors often still count as success.
- **Architecture and intent are not scored.** Consistency with the repo’s real patterns is invisible unless a human reviews it.
- **Repair loops are flattened.** A model that fails first review and burns three fix rounds can still post a completed-task cost. In production those rounds dominate spend.
- **Review quality is a different job.** Catching a known bug in a diff is not the same as implementing a ticket. Benches rarely chain implement → review → live with the result.
- **Human time is omitted.** Evening cleanup, re-explaining the design to the next agent, and reading a clever detour never hit the API invoice.
- **Token use after day one is omitted.** A messier tree means larger context, more re-reads, more retries. That tax is paid on *later* tasks, under a different row of the spreadsheet.
- **Effort knobs break “same task” comparisons.** A cheaper model at max effort can spend more tokens than a stronger model at high effort and still look like the budget option on list price.

So a “cheaper per task” result can mean: finished the harness, not: left the codebase easier to change.

---

## How a lower-quality solution costs more later

Comparative cost is everything the higher-quality solution does not force you to pay again.

### Immediate aftershock
- Extra implementer rounds after a failed first review
- Re-runs on a stronger model to finish what the cheap pass botched
- Hotfixes for missed failure modes (wrong mental model of the bug, then a patch built on that model)

### Structure that persists
- Needless complexity: extra layers, wrappers, parallel ways to do one thing
- Contorted architecture: the clever path that is not the house style
- Inconsistent patterns: each session invents a local idiom
- Scope creep inside the diff: drive-by refactors that tests still accept
- Weaker boundaries: leaked internals, blurry module ownership

### Understandability tax
- Harder for humans to review and to trust
- Harder for the *next* agent to infer intent, so it reads more files
- Silent token spend: larger prompts, more cache misses, more confused tool loops
- Worse predictability: the same class of ticket no longer has one obvious shape

### Product and operations
- Bugs that escape review (lower catch rate on hard cases)
- On-call and incident cost from the missed failure mode
- Slower subsequent features on the same foundation
- Rewrites or “just isolate it” work when the shortcut becomes load-bearing
- Reduced option value: harder to hire against, harder to hand to another model or person

### Accounting illusion
None of this lands on the original task’s cost-per-task cell. It lands on next month’s tickets, on review hours, and on quota burned re-reading a tree that did not need to be this large.

“Outdated tech” is the weak item on this list when both models share a knowledge cutoff. Pattern drift and missed invariants are the strong items.

---

## Why slight differences compound

Software is path-dependent. The second change is written on top of the first.

- **Interest on debt.** A small extra abstraction is cheap once. Every later agent must read it, preserve it, or fight it.
- **Intent decay.** If the first pass only weakly understood *why* the system is shaped this way, later passes optimize the local mess instead of the original intent.
- **Variance becomes house style.** One inconsistent module is noise. Ten become “how we do it here.”
- **Agent context is a budget.** Noise in the tree spends that budget on archaeology instead of the new work. First-pass quality falls, which creates more noise.
- **Review does not fully unwind structure.** Humans and models will patch a working but wrong shape more often than they will tear it out.
- **Failures cluster.** A wrong failure-mode story produces a wrong fix, which produces a wrong test, which blesses the wrong shape.

A 2-point index gap on a one-shot bench can be noise. The same gap, applied to every decision that defines modules and interfaces, is not noise. The relevant question is not “how much worse is this ticket?” It is “how many future tickets inherit this ticket?”

---

## Short projects vs real products

This argument is weak for:

- spikes, prototypes, throwaway scripts
- one-off migrations with a hard stop
- work that dies when the demo ends
- tickets that are fully specified, fully tested, and deleted if ugly

It is the default for:

- products with real scope
- codebases that will be changed for months or years
- anything an agent will keep returning to
- anything a human will on-call

If the artifact has a lifetime, the foundation is an investment. Per-task price is a cash-flow snapshot.

---

## Spend the expensive intelligence on high-leverage points

You do not need the strongest model on every keystroke. You need it on the decisions that subsequent work cannot cheaply undo.

**1. Architecture and invariants**  
Module boundaries, data ownership, failure modes, what must never happen. Write it down (ADRs, “do not do X”). Predictability is a document, not a hope that the next session will re-infer the design.

**2. Project harness**  
Repo map, allowed tools, test commands, stop conditions, file-scope rules, review checklist. A tight harness shrinks the quality gap on *execution*. It does not replace judgment on *shape*.

**3. Implementation plan**  
Short plan plus acceptance tests *before* the cheap model runs. The plan is the expensive artifact; the patch is not.

**4. Quality review of shape-changing diffs**  
Interfaces, auth, data flow, concurrency, anything that adds a pattern. Review is where missed bugs and extra architecture are still cheap to kill.

**5. Escalation rules**  
Cheap model while the task is “fill this in against the plan.” Strong model when the task is “what should this be,” when first review fails twice, or when the diff invents structure.

**6. Record what was decided**  
Decisions and rejected alternatives belong in the repo. That cuts the understandability tax for every later human and agent.

Rule: **buy intelligence for the compounding layer; buy throughput for the reversible layer.** If a cheaper model is allowed to *decide* the shape of a long-lived product, the per-task saving is usually a rounding error on the interest.
