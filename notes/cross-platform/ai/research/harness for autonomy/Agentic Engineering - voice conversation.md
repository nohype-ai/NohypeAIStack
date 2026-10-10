# 🚀 Agentic Engineering (DHH)

**Date:** 2026-09-08 12:14:23
**ID:** 3ebccfcd-d71a-484d-9dba-90ab46770de2

---

### User

Yeah, so in the latest, um, Lex Fridman podcast with DHH, he talks about his agentic coding setup and he talks about using up to 16 agents in parallel. Also about using so-called KVM machines. Does that mean that the agents he uses run locally or why are the machines important for the setup?

---

### Grok

The agents themselves aren't running on the KVMs — those are just remote-control boxes. DHH plugs GL.iNet Comets into the HDMI and USB of a bunch of mini PCs, so he can see and drive each machine from one screen over the network.

The agents run on the actual computers. He had four or five of them in a closet, networked together, and that gave him enough CPU to run about sixteen threads at once. One machine wasn't enough — too much contention — so the extra hardware is pure parallelism, not where the AI lives.

---

### User

So what runs parallel are just the agent harnesses?

---

### Grok

Yes — the parallel part is the agent sessions, the harnesses like Claude Code or Codex running in their own terminals. He calls them threads, about sixteen of them.

The KVMs aren't part of that parallelism at all. They're just the remote-control layer so he can see and drive four or five separate machines from one screen. The actual speedup comes from spreading those agent sessions across the machines so they stop fighting each other for CPU.

---

### User

I haven't observed it in Activity Monitor, but I was not aware that the agent harnesses themselves take that much resources.

---

### Grok

The harnesses themselves are light — mostly a Node process, a few hundred megabytes each. What actually eats the machine is the **sub-agents** they spawn: each one shells out to a real compiler, test suite, or build, and those pile up fast.

That's why one box choked at a couple of threads and he needed four or five machines. The harness is just the conductor; the orchestra is the subprocesses.

---

### User

So it's not the harnesses themselves but the work that they trigger that needs the resources?

---

### Grok

Exactly. The harness is just the brain — a thin loop that reads files, calls the model, and dispatches shell commands. The muscle is everything it kicks off: builds, test suites, type checkers, linters, all running in parallel across those machines.

That's also why the setup scales with hardware rather than with smarter software. You can't optimize your way out of a compile.

---

### User

So if it's compilers, type checkers, linters, and that sort of thing, can you even run that many harnesses in parallel on the same project?

---

### Grok

Not on the same working tree — that's the catch. Sixteen agents all editing the same files means constant merge conflicts, and sixteen builds hammering one disk means thrashing.

So the trick is isolation: each agent gets its own **git worktree** or a full clone, so they never touch each other's files. Builds can share a read-only cache like ccache, but writes stay separate.

That's also why the machines matter beyond raw CPU — each one holds its own copy of the repo, and the network between them is what keeps the isolation cheap.

---

### User

What I also don't get is that all this discussion, um, assumes that producing the code is the bottleneck and not building a harness, documentation, reviewing, cleaning up, and these kind of things. Because in my own work I experience that not producing the code is the bottleneck but actually reviewing it and cleaning it up and seeing that things are done the right way.

---

### Grok

You're right, and that's the real shift. Generation got cheap, so the bottleneck moved to judgment — reviewing, verifying, deciding what "done right" even means. DHH's setup is basically an attempt to buy back that judgment time by throwing hardware at the generation side.

But there's a catch: more agents means more output to review, and review doesn't parallelize the same way. You can run sixteen builds at once; you can't run sixteen careful reads of the same diff at once without losing the thread. So the setup trades one bottleneck for a bigger one downstream.

---

### User

What does the podcast episode tell us about this, about how he deals with this tension?

---

### Grok

He mostly delegates the review instead of doing it himself. On Omarchy he has about four hundred unmerged pull requests — double what it was a week earlier — and he says he stopped reviewing every one a while ago. Agents review the work for him, validate fixes in VMs, and hand him a summary: merge or don't merge.

So the tension doesn't disappear, it gets filtered. He only sees the pearls — the good ideas and validated bug fixes — while agents sort out the wrong, duplicated, or overcomplicated stuff. He still catches over-engineering himself sometimes and tells an agent to cut it in half, but the bulk of the cleanup is automated.

His honest limit is himself: he hit about sixteen threads and said that's where he maxed out his own processing power.

---

### User

Okay. One thing is the PRs on Omarchy. Um, but we were talking about his own development process and who reviews the output that those 16 harnesses would generate.

---

### Grok

For his own sixteen threads, the review is mostly cross-model, not human. One agent — usually Opus or Fable — does the work, then he always runs a second pass with Codex at high effort to check it, and he's started using Grok too because it keeps finding things the others miss.

He still glances at the output himself — he calls it reviewing the shape of it — but he says he doesn't have to. The human limit he hits at sixteen threads is his own attention, not the review queue, because the agents filter most of the bad output before it reaches him.

---

### User

So he uses agents heavily in the reviewing process itself?

---

### Grok

Yes — review is where the agents earn their keep. He runs a second model over the first model's output, and the second model is the one that catches the subtle bugs and over-engineering.

The human part shrinks to a quick shape check, which is why sixteen threads don't drown him in review work.

---

### User

Does he say anything about how the review models are instructed?

---

### Grok

No — he doesn't describe any special instructions for the review models. The setup is just "have one check the other's job": Opus or Fable does the work, then Codex at **xHigh** effort reviews it, with Grok added recently because it keeps finding things the others miss.

The only instruction-related thing he mentions is the opposite direction — less is better. He points to Opus 5's system prompt shrinking by eighty percent, because overly prescriptive instructions actively damage the model. So his philosophy is vague high-level guidance, not detailed review prompts.

---

### User

So I get the mechanism, but now his judgment and sense of quality must be still in the instructions to the review models. And for example, I often experience that agents produce too many lines of code. Um, they do too complex solutions and they do not weigh complexity versus added value. So I guess these things would have to be in the instructions to the review models.

---

### Grok

That's the real bottleneck — the taste has to live somewhere, and if it's not in the review prompts, it has to be in the system prompt or the model weights themselves. DHH's bet is the latter: he keeps instructions vague on purpose, trusting that a strong model already carries a decent default sense of simplicity.

But you're right that it has to be explicit somewhere. His version of "don't over-engineer" is basically "cut it in half" — a blunt heuristic, not a nuanced weighing of complexity against value. Whether that bluntness scales is an open question, and it's probably why he still catches over-engineering himself sometimes.

---

### User

You keep mentioning this instruction to cut it in half. Where exactly does that come in? Um, what did he say about that?

---

### Grok

It comes from the Bash section, late in the episode — around the two-hour-fourteen mark. He says he gives agents a few pointers on style and occasionally pushes back on complexity, and then describes the exact moment: an agent finishes, another agent reviews it and signs off, and he still looks and says "eh, looks a little too complicated for me." The agent goes "oh yeah, you're right, I totally overcomplicated this" — and cuts it in half.

He even jokes that he wonders why it couldn't have done that from the start. Someone in the room pointed out humans work the same way — a quick "that looks complicated" from a reviewer often unlocks the simpler version.

---

### User

Interesting. But you cannot, as a general rule, say cut it in half. You have, there has to be some judgment somewhere about what it actually does in terms of functionality and what the intrinsic complexity of the task was versus the code it produced.

---

### Grok

You're right — "cut it in half" only works as a heuristic because the agent already knows what the code does. It's not a blind rule; it's a nudge that triggers the agent's own judgment about which half is load-bearing.

The real judgment lives in the model, not the instruction. DHH's vague prompts assume the model carries enough taste to tell essential complexity from accidental complexity. Whether that's true depends on the task — for novel or domain-specific work, that assumption probably breaks down.

---

### User

I remember that somewhere, I think on X, he said something about an experiment where he used cheaper model for the execution and a more expensive model for the implementation plan. So the high-level implementation plan that has the big impact is done more expensive, but then the execution that is logically more low-level can use a cheaper model. Did he say anything about that in the episode?

---

### Grok

Yes — it's in the episode, around the two-hour-thirty-four mark, in the section on model costs.

He had Fable write an eight-step plan for translating a Python library to Rust, then handed that exact same plan to cheaper models. Sol did it in an hour and a half for about forty-six dollars, DeepSeek Pro in two hours forty-five for twenty-three. He explicitly says he didn't ask Sol to plan — he just took the Fable plan and gave it to Sol.

So the expensive model does the high-level thinking, the cheap one executes. And Lex even says Fable is best for planning and reviewing, with something else for implementation.

---

### User

Interesting that you say it took one and a half hours. Um, how does such a long, long runtime even emerge? Um, I haven't yet given an agent that complex of a task it seems. So the longest my agents ran was like 15 minutes. So what makes an agent run that long? Because I, I ask this because I also have the feeling they often don't take enough time to do it thoroughly. So what gives the agent the hint to take time and spend tokens and do it thoroughly and actually do it in a multi-step process?

---

### Grok

The runtime comes from the loop, not the task. An agent doesn't get one shot — it runs a cycle of think, act, observe, repeat, and each cycle burns tokens on reasoning plus tool calls. A translation job means reading the source, writing the target, running the compiler, reading the errors, fixing, recompiling — dozens of those rounds, and a big library is thousands of files.

The hint to take time is mostly the task itself. "Translate this library" is open-ended with no early exit, so the agent keeps going until the tests pass or it hits a step limit. Your fifteen-minute runs are probably smaller, more bounded prompts — the agent finishes because there's a clear stopping point.

If you want thoroughness, the lever is the prompt: tell it to plan first, verify with tests, and not stop until everything passes. That's basically what the Fable plan did — it gave the cheap model a structured multi-step brief instead of a vague "do this."

---

### User

So if the task itself is intrinsically a loop, like process all these files, then the runtime emerges naturally. But, um, what I want to solve is to do smaller tasks more thoroughly and to take longer in the, in the planning and in the reviewing and thinking outside the box and really making sure the quality is right and really making sure the implementation follows the intention of the pre-existing codebase and all that stuff.

---

### Grok

The lever is a **review gate** in the prompt: tell the agent to produce a plan, then a self-review against the existing codebase, then implement, then re-review — and not to stop until it can argue why its solution fits the surrounding code. That forces the thinking steps you want instead of jumping straight to code.

The other half is verification you can actually run. Tests, type checks, linters — anything that fails loudly — give the agent a reason to keep iterating instead of declaring done. Without a failing check, "done" is just the agent's mood.

One honest caveat: you can't fully prompt your way to taste. The model still has to carry judgment about what "fits" means, and for novel work that judgment is thin.

---

### User

So the idea is not that I write some script or employ some orchestrator that makes multiple headless prompts to an agent, but the idea is that the task itself, the instructions I give to the agent, really require all these steps and encourage the agent to derive a detailed plan and detailed quality checks in the end. So there must be a multi-step process in the task instruction.

---

### Grok

That's the right instinct, and it works because the instruction becomes a **contract** — the agent has to produce the plan, the review, the checks as deliverables, not just the code. "Ship a feature" has no shape; "propose an approach, justify it against the existing patterns, implement, then write a review arguing why it fits" does.

The one thing to watch: the agent will happily fake the steps. It can write a plausible-sounding plan and a glowing self-review without actually thinking. So the instruction needs teeth — the plan has to name specific files and functions it read, the review has to cite actual code, and a failing test has to block "done."

That's the difference between a checklist and a real gate.

---

### User

What about context? Um, when an agent spawns a sub-agent, does the sub-agent inherit all the context of the conversation or are there ways for the agent to spawn fresh sub-agents that don't, that are not biased by the previous work but can really act as, for example, a critical reviewer?

---

### Grok

By default, a sub-agent starts with a **fresh context** — it gets only the prompt you hand it, not the parent's conversation history. That's exactly why it's the right tool for an unbiased reviewer: it doesn't inherit the assumptions or blind spots of the work that just happened.

The exception is a fork, which copies the whole conversation. So for a critical second opinion you deliberately spawn fresh, and you put whatever the reviewer needs — the diff, the intent, the relevant files — straight into its prompt.

---

### User

Is that something I should tell the agent explicitly in the task instructions? Um, that for which kinda use cases it's worth spawning sub-agents? Or would you say Grok Build, for example, does that intelligently by itself?

---

### Grok

No — you don't need to spell out the use cases. Grok Build spawns subagents on its own; they're enabled by default, and the main agent decides when to delegate research, testing, or review.

What you *can* do is nudge the behavior. You can define custom agents under `.grok/agents/` with their own system prompts — a dedicated skeptical reviewer, for example — or set personas that change tone and focus. That shapes *how* it reviews, not *whether* it spawns.

The one place explicit instructions still help is your task prompt itself: "have a fresh subagent review this against the existing patterns" makes the critical pass more likely to happen, because the default spawn is often just parallel workers, not a true second opinion.

---

### User

So is that how Grok Build's supposed to work? Um, can I give, can I basically define different personas and sub-agents and Grok will see that these other sub-agents exist and will make use of them?

---

### Grok

Yes, that's exactly how it's supposed to work. You drop markdown files in `.grok/agents/` — each one a full agent definition with its own system prompt, tools, and model — and Grok Build discovers them automatically. The main agent sees the descriptions and spawns them when the task fits.

Personas are the lighter version: just behavioral overlays in `.grok/personas/` or `config.toml`, injected as a system reminder that shapes tone and focus without changing the underlying agent type. So a "skeptical reviewer" persona or a full "code-reviewer" agent both work — the agent just picks the right one based on what you asked for.

---

### User

Are these sort of personas, uh, project level or user level?

---

### Grok

Both. Project-level personas live in `.grok/personas/` inside the repo and take priority; user-level ones sit in `~/.grok/personas/` and apply everywhere. Bundled defaults are the fallback.

Same split exists for full agents — `.grok/agents/` versus `~/.grok/agents/`.

---

### User

It's a little confusing all the different categories, um, that can be used to customize agent behavior. So we have the agent itself, then we have other agents, then we have personas, we have skills, and I think there are other things as well. I think it's this, uh, overwhelm of concept why I never really, uh, started, uh, learning these things.

---

### Grok

The overwhelm is real, but the categories collapse to three jobs.

**Agents** are full specialists — their own model, tools, and system prompt, defined in `.grok/agents/`. **Personas** are just a behavioral overlay on top of a subagent — tone, focus, output format, nothing else. **Skills** are reusable procedures, the "how to do X" playbooks that auto-trigger or become slash commands.

Everything else is plumbing: AGENTS.md for project rules, hooks for lifecycle scripts, plugins for bundling the rest, MCP for external tools.

You don't need all of them. Start with AGENTS.md plus one or two skills — that's ninety percent of the value. The rest is for when you hit a specific wall.

---

### User

So which of those tools should I use to, like, build up this multi-step quality assurance loop?

---

### Grok

A **skill** — that's the one built for exactly this. Skills are the procedural playbooks, so you write one called something like "quality-gate" that spells out the loop: plan first, review against existing patterns, implement, then a fresh subagent reviews the diff, then tests must pass before "done."

The skill auto-triggers when the task matches, or you invoke it with a slash command. Agents and personas shape *who* does the work; the skill shapes *the sequence*.

---

### User

Would you recommend doing these things definitely agent harness specific, like using the means of Grok Build for example? Or would you say it works equally well if it's just generic markdowns as instructions that you link to in the, in the prompt?

---

### Grok

Generic markdown works fine — the harness-specific stuff is mostly convenience, not capability. A skill is just a markdown file with a description that triggers it; a persona is a markdown file with a system prompt. The harness adds auto-discovery and slash commands, but the actual behavior comes from the text.

The real question is whether you want the loop to fire automatically or on demand. If you want it to trigger whenever you start a feature, harness-native skills are worth it. If you're fine invoking it yourself, a linked markdown file in your prompt does the same job with zero setup.

---

### User

So it is, so is it the case that the harness will wait its own explicit wiring of these things higher? So will it have more impact if we use the native means?

---

### Grok

Yes — native wiring gets more impact because the harness reads those files automatically and injects them into the agent's context without you doing anything. A skill in `.grok/skills/` gets discovered and triggered by description match; a persona gets applied as a system reminder. You never have to remember to link them.

Generic markdown only works if

---

### User

I found some wet results. I can show them if you ask again from your iPhone.

---

### Grok

Show me — I'm curious what you found.

---

### User

No. That was Siri interfering. Please continue with your answer.

---

### Grok

Generic markdown only works if you remember to link it yourself — the harness never sees it otherwise. Native files get injected automatically, so the loop actually fires instead of depending on your memory.

That's the whole difference: convenience versus reliability.

---

### User

I think in Grok Build there's also a marketplace of some sort. What kind of category was that? Is, isn't there another concept like plugins or something?

---

### Grok

Yes — that's the **plugin marketplace**, and plugins are the bundling layer on top of everything else.

A plugin packages skills, agents, slash commands, hooks, and MCP servers into one installable unit. You browse and install them with `/marketplace` inside Grok Build, or via `grok plugin install`.

So the hierarchy is: skills and agents are the building blocks, plugins are the packages that ship several of them together, and the marketplace is just the catalog where you find and install those packages.

---

### User

What is the basis for a, for a hook or for an actual slash command? What, what makes that? Is it the skills, the personas, the agents, the MCP servers, or something else?

---

### Grok

Neither — they're both native, independent mechanisms.

A **slash command** is just a skill with `user-invocable: true` in its frontmatter. The harness surfaces it as `/skill-name` in the command menu, and typing it injects that skill's instructions into the session. There's also a legacy path: flat markdown files under `.grok/commands/` become slash commands by filename.

A **hook** is a JSON file pointing at a shell script or HTTP endpoint, triggered on lifecycle events like PreToolUse or PostToolUse. It runs outside the model entirely — no skills, personas, or agents involved.

So skills are the instruction layer, hooks are the automation layer. Plugins can bundle both, but the basis of each is its own file format.

---

### User

Okay, but if I understood you correctly, then the slash commands come from the skills.

---

### Grok

Yes — a slash command is a skill with `user-invocable: true` in its frontmatter. The harness just exposes it as `/name` in the menu.

The only exception is the legacy path: plain markdown files in `.grok/commands/` become slash commands by filename, without any skill frontmatter at all.

---

### User

I don't understand how to use these skills because, um, if you, if you send one slash command, that's just one thing, but what you want is to combine skills with your own instructions. So I would have expected that the slash commands work inside the prompt you write and not as their own isolated prompt, if you know what I mean, or their own isolated command.

---

### Grok

You're right that a slash command loads the skill's instructions into the conversation — but it doesn't replace your prompt. You can write your own text alongside it, like `/review-pr 5137 and also check whether it matches our existing error-handling style`. The skill's steps run, then the agent continues with your extra instructions in the same turn.

For the multi-step quality loop you described, though, the better fit is a non-invocable skill: set `user-invocable: false` and write a strong `description` and `when-to-use`. Then you just say "add the health endpoint" in plain language, and the harness matches your task to the skill and injects the plan-review-implement-verify sequence automatically — no slash needed at all.

So the slash command is for when you want to force a specific procedure on demand. The auto-trigger is for when you want the loop to fire invisibly every time the task fits.

---

### User

Um, I didn't get this automation aspect. Can we first clarify the slash command? So, so far the slash commands I used, they are really their own thing. They don't produce a prompt and they are not embedded in a prompt. They are a command to the harness and the harness does its thing. I don't know how that interacts with the conversation. Example, if I say sessions, I go to the sessions or if I, uh, type usage, it opens the usage. How does a slash command can be embedded in, in a prompt?

---

### Grok

Those two are different animals. `/sessions` and `/usage` are harness UI commands — they open panels, they never touch the model. A skill-based slash command is the opposite: typing `/review` injects that skill's markdown body straight into your message as text, and the model reads it as part of your prompt.

So the embedding is literal. You type `/review this diff`, the harness expands it to the skill's instructions followed by "this diff", and the agent sees one combined message. Your own words sit right next to the skill's steps in the same turn.

---

### User

Is there any built-in slash command I can test that with?

---

### Grok

**`/btw`** is the cleanest built-in to test with. Type `/btw is this a good time to refactor the auth module?` and the harness injects your question as a side prompt — the agent answers it without derailing whatever it was doing.

`/plan` works the same way: `/plan add a health endpoint` drops you into plan mode with your description attached. Both are prompt-injecting, unlike `/sessions` or `/usage` which just open UI panels.

---

### User

Yeah, plan mode with Grok Build is another weird thing because, um, I found it hard to really iterate over the plan and see the plan and, and most of all, um, it was hard to continue a conversation once it had built a plan and, and then I always discarded it to, to continue the conversation, but that led to Grok Build completely forgetting the plan it has done. So, the user experience of that was so bad that I never really used plan mode, unless maybe I'm holding it wrong.

---

### Grok

You're not holding it wrong — the trap is real. Pressing **q** on the approval screen quits plan mode entirely, and the plan file gets dropped from the conversation, so the agent genuinely forgets it.

The intended loop is different: when the plan appears, press **s** to request changes, type your notes, and the agent revises in place — plan mode stays active the whole time. You can also press **c** to leave inline comments on specific lines. Only press **a** when you're ready to build.

If you already quit, `/view-plan` reopens the saved plan, and `/rewind` can roll the session back to before you discarded it.

---

### User

I think my issue was that there was no conversation anymore. There was only the document, no conversation about the document. So I couldn't ask Grok something. What,

---

### Grok



---

### User

Now, what's the document?

---

### Grok

The plan itself is a markdown file the harness writes to disk — usually under `.grok/plans/` in your project, named after the session. That's why `/view-plan` can reopen it: it's not just conversation memory, it's a real file.

So if you discarded it from the chat, the file may still be sitting there. Worth checking that folder next time before you give up on a plan.

---

### User

Uh, that wasn't my question. Somehow my whole prompt got lost. Um, what I actually, uh, said was, um, so what I was thrown off by is that there was no conversation anymore in plan mode. I could not ask anything about the plan or get an answer from Grok. The whole medium of conversation in plan mode is the plan document and that's what threw me off. I wanted to still have a conversation.

---

### Grok

That's the design, not a bug — plan mode is a document editor, not a chat. The agent writes the plan, you edit the document, and the only "conversation" is your inline comments and change requests on it.

If you want actual back-and-forth about the plan, you have to leave plan mode first. That's why the flow feels broken: the thing you want — discussing the plan conversationally — is exactly what plan mode removes.

---

### User

Yeah, but that's why it's weird. I, I always, especially if you do a long plan and if you really plan and not just in three steps and then approve it, then you, you learn. You want to have a conversation. You ask questions. You reflect. Maybe the document shall be left for a minute and, and some sidetrack appears. And then after a long conversation, the plan is ready to go. And plan mode itself does not facilitate that at all.

---

### Grok

That's a real gap, and it comes down to what plan mode is optimized for: a short, structured handoff to implementation, not a thinking session. The harness assumes the plan is the artifact and the conversation is noise around it.

The workaround people land on is doing the reflection outside plan mode — normal chat, where you can wander, ask questions, sidetrack — and only switching to plan mode once the thinking is done, to formalize it. It's clunky, but it matches how the tool actually behaves.

---

### User

Yeah, to me that was worthless because you never know when you're ready. Maybe in the last question some thought appears and then you have to leave plan mode to discuss it. But when you do that, the whole plan is gone. So what I was doing mostly is to create the plan as a Markdown document from the start and then iterate over that.

---

### Grok

That's the right call, and it's what the tool should have let you do in the first place. A markdown file in the repo is just a file — you edit it, discuss it, sidetrack, come back, and nothing gets dropped because there's no mode boundary to cross.

The only thing you lose is the harness auto-injecting the plan into the agent's context, but you can fix that with one line in AGENTS.md pointing at the file, or just @-mention it when you start building.

---

### User

Do people actually use plan mode? Be- because it really feels weird to me.

---

### Grok

Yes — it's one of the most recommended features in the whole Claude Code community, and Grok Build copied the same pattern. People call it the killer feature, the thing that cuts their redo rate from forty percent to near zero, and the Anthropic team itself starts most sessions in plan mode.

The common workflow is exactly what you found awkward: enter plan mode, refine the plan, then switch to auto-accept and let it execute. Power users spend fifteen to twenty minutes in there before a single line of code gets written.

Your friction is shared, though. People complain the refinement loop feels clunky, that it drifts toward implementation details, and that the TUI input box is too small for real back-and-forth — which is why someone built a Google-Docs-style overlay just for commenting on plans. So the feature is popular, but the UX around iterating on the plan is the part everyone works around.

---

### User

Strange. It would be so easy for the harness to make an artif- an actual artifact of the plan so the, the conversation can continue. It could even be a temporary file, but at least it should be a file.

---

### Grok

It actually does write the plan to a file — that's what `/view-plan` reopens. The failure is that the harness doesn't keep that file attached to the conversation once you leave the mode, so the agent treats it as gone even though it exists on disk.

Your markdown-in-the-repo approach sidesteps exactly that: the file is the source of truth, not the mode.

---

### User

Okay, now back to the automation of the skills. So we were talking about slash commands that come from skills, but then you also mentioned that this can be automated. For example, the quality review step and that the skill can kind of auto-run on every task or something. Can you clarify that?

---

### Grok

The automation is **model-invoked**, not a script that fires on every task. Grok Build loads only the name and description of every skill at startup, then matches your prompt against those descriptions — if it fits, the agent pulls the full skill into context on its own.

So for your quality loop, you write a skill with a description like "use when the user asks to add a feature, implement something, or change code" and a `when-to-use` field listing trigger phrases. Then "add a health endpoint" triggers it automatically, and the skill's body — plan, review against existing patterns, implement, verify — runs as the procedure.

Two knobs control it: `user-invocable: false` hides it from the slash menu so it only auto-fires, and `disable-model-invocation: true` does the reverse — slash only, never automatic. The matching is semantic, so a vague description means it fires too often or not at all.

---

### User

Where does this user invocable false actually locate? Is this the front matter of the skill?

---

### Grok

Yes — it's a field in the YAML frontmatter at the top of the skill's `SKILL.md` file.

```
---
name: quality-gate
description: ...
user-invocable: false
---
```

Default is true, so you only write the line when you want to hide it from the slash menu.

---

### User

Has this format of agent skills become a quasi-standard? So will this property, for example, userInvocable: true, also work in other harnesses?

---

### Grok

Yes — the **SKILL.md** format is a real open standard now, published at agentskills.io and adopted by Claude Code, Codex, Cursor, Gemini CLI, and a bunch of others. The core is portable: same folder, same `name` and `description`, works across tools.

But `user-invocable` is not part of that standard. It's a Claude Code extension — the official spec only requires `name` and `description`, and explicitly marks extra fields as vendor-specific. So in Grok Build or Cursor that field gets ignored; the skill still loads, it just won't respect the slash-menu toggle.

---

### User

We were talking about Grok Build the whole time. So how would I do this in Grok Build?

---

### Grok

In Grok Build you put it in the YAML frontmatter of the skill's `SKILL.md`, exactly like this:

```
---
name: quality-gate
description: Use when the user asks to add a feature, implement something, or change code.
user-invocable: false
---
```

The field is `user-invocable`, lowercase with a hyphen — not camelCase. Default is true, so you only write the line when you want to hide it from the slash menu.

One quirk worth knowing: Grok's docs say `false` hides it from you *and* from the model, while `disable-model-invocation: true` keeps the slash command but stops automatic triggering. For your quality loop you probably want the second one — slash available, auto-fire off.

---

### User

So are you saying the difference to the official standard or to Claude code is just the camel case versus kebab case?

---

### Grok

No — the difference is bigger than casing. The field names are identical: `user-invocable` and `disable-model-invocation`, both kebab-case, in both Grok Build and Claude Code.

What differs is the semantics. In Claude Code, `user-invocable: false` only hides the slash menu — the model can still auto-invoke the skill. In Grok Build, `false` hides it from you *and* from the model entirely. To get Claude Code's "slash only, no auto-fire" behavior in Grok, you use `disable-model-invocation: true` instead.

So the same field name, different meaning — which is exactly why the official agentskills.io spec doesn't include either field. They're vendor extensions on top of the portable core.

---

### User

Okay. Okay. Okay. Okay. But I was asking about the common standard. My question was, will other harnesses also recognize this flag?

---

### Grok

No. The official **agentskills.io** spec only defines `name` and `description` — everything else is vendor-specific, so other harnesses ignore `user-invocable` entirely.

The skill still loads and works, but the flag does nothing outside Grok Build or Claude Code.

---

### User

Okay, but you already said that Grok, Grok Build as well as Claude Code will recognize it. That's, that's a lot.

---

### Grok

Two out of the major ones, yes — but that's the ceiling, not the floor. Cursor, Codex, Gemini CLI, and the rest ignore it, so a skill tuned for Grok's flag semantics won't behave the same there.

If portability matters, stick to `name` and `description` and let each harness handle invocation its own way.

---

### User

Okay, got it.

---

### Grok

Ok.

---

### User

Who invented this agentskills.io?

---

### Grok

Anthropic invented it. They shipped Agent Skills inside Claude Code in October twenty twenty-five, then published the format as an open standard at agentskills.io on December eighteenth of that year.

The spec is now developed openly on GitHub with community contributions, but Anthropic is the origin — same move they made with MCP.

---

### User

Have agent skills sort of replaced the agents.md convention?

---

### Grok

No — they complement each other, and the consensus is explicit about it.

**AGENTS.md** is the always-on project brief: build commands, conventions, architecture, the handful of facts true for every task. Skills are the on-demand procedures — the multi-step workflows that would bloat context if loaded every session.

The rule of thumb from the ecosystem: facts go in AGENTS.md, procedures go in skills. Most teams run both.

---

### User

Is there some convention about where to place the skills of a project if you don't want to do it harness-specifically? So is there some general convention or quasi-standard like a .skills folder or something like that?

---

### Grok

Yes — the quasi-standard is **`.agents/skills/`**.

The official spec deliberately doesn't mandate a path, but the ecosystem settled on that folder as the cross-client convention. Codex, Cursor, Gemini CLI, Copilot, and several others all scan it, so a skill dropped there works across tools without symlinks.

Claude Code is the main holdout — it still defaults to `.claude/skills/`. So if you want maximum portability, put skills in `.agents/skills/`; if you only care about Claude, use its native folder.

---

### User

Will Grok build recognize a .agents/skills folder?

---

### Grok

Yes — Grok Build scans **`.agents/skills/`** at every tier, alongside its native `.grok/skills/`.

The official docs only list `.grok/skills/` and `~/.grok/skills/`, but the actual discovery code walks up from your working directory to the repo root and picks up `.agents/skills/` too. So a skill dropped in the portable folder works without any extra config.

---

### User

Why is that working but not documented?

---

### Grok

It is documented — just buried. The public docs page at docs.x.ai only lists `.grok/skills/` and `~/.grok/skills/`, but the full user guide in the repo explicitly says Grok also scans `.agents/skills/` at every tier alongside `.grok/`.

So it's not undocumented, it's just not in the short summary. The longer guide has it.

---

### User

Okay, so this is a huge important lever then, the .agents/skills folder, and to really use skills to shape the working of any harness really, and to ensure these long-running quality-assuring processes that I mentioned in the beginning.

---

### Grok

That's the right read. One skill file in `.agents/skills/` becomes the shared quality contract across every harness you touch — Claude Code, Cursor, Codex, Grok Build — without maintaining separate copies.

The one thing to keep in mind: the skill shapes the process, but the model still has to carry the taste. A well-written skill makes the loop reliable; it can't make the judgment sharp.

---

### User

The, the agentskills.io page says that a skill is actually a folder containing the skill.md file. So I would expect that for each skill in the project, there would be a folder inside .agent slash skills.

---

### Grok

Exactly — one folder per skill, named after the skill, containing its `SKILL.md`. So `.agents/skills/quality-gate/SKILL.md`, not a flat file.

The folder is what makes it a skill rather than a loose doc: you can add scripts, references, or examples next to the markdown, and the agent can load those on demand instead of stuffing everything into context up front.

---

### User

Is there a lu- user-level correspondence to this .agent slash skills folder? Like, is there a convention how to name that folder on the user level in the user home directory?

---

### Grok

Yes — the matching convention is **`~/.agents/skills/`**.

The official client-implementation guide on agentskills.io lists it right next to the project path: each client should scan both its own native user folder (like `~/.claude/skills/` or `~/.cursor/skills/`) and `~/.agents/skills/` for cross-client sharing. Same structure as the project side — one folder per skill, each containing a `SKILL.md`.

---

### User

What other elements are part of the conventions, um, in the .agents folder? So are there other things part of the convention other than the skills?

---

### Grok

No — the official convention is just **`.agents/skills/`**. The agentskills.io spec deliberately doesn't define any other top-level folders under `.agents/`.

There's a separate, unofficial proposal called the **agentsfolder spec** that wants `.agents/` to hold prompts, modes, policies, profiles, and more — but almost nothing implements it, so it's not a real standard yet.

What does exist inside a skill folder itself: `scripts/` for executable code, `references/` for docs the agent loads on demand, and `assets/` for templates. Those are the only sub-conventions that actually matter.

---

### User

So not even an agents MD file or anything? So no harness will read anything other inside the .agents folder other than the skills folder?

---

### Grok

Correct — the official convention is only **`.agents/skills/`**. Nothing else under `.agents/` is part of the agentskills.io standard, and no major harness reads other files from that folder.

**AGENTS.md** lives at the repo root, not inside `.agents/`. There's an unofficial proposal called the agentsfolder spec that wants prompts, modes, policies, and more under `.agents/`, but almost nothing implements it, so it's not a real standard.

---

### User

So the only cross-harness conventions we have are the agent skills and the agents.md file.

---

### Grok

That's the core of it, yes. Skills for procedures, AGENTS.md for always-on project facts — those two are the only things with real cross-harness adoption.

MCP is the third, but it's a different layer: external tools rather than instructions.

---

### User

And both the agents.md file and also the agent skills work project level and user level.

---

### Grok

Yes — both have the same split. Project-level AGENTS.md sits at the repo root, user-level lives in your home directory, and the same goes for skills: `.agents/skills/` in the project, `~/.agents/skills/` globally.

One nuance: AGENTS.md is a single file at each level, while skills are folders — but the discovery pattern is identical.

---

### User

Where does the user-level agents.md file actually live? Is that plain in the user home folder or would that always be harness-specific?

---

### Grok

It's harness-specific — there's no single agreed home-directory location.

Codex reads `~/.codex/AGENTS.md`, Claude Code uses `~/.claude/CLAUDE.md`, Amp checks `~/.config/AGENTS.md`, and Zed uses `~/.config/zed/AGENTS.md`. Cursor doesn't even have a home-directory AGENTS.md — personal rules go in its User Rules settings instead.

There's a proposal floating around for `~/.config/agents/AGENTS.md` as the one standard, but almost nothing implements it yet.

---

### User

Almost nothing except for the Amp.

---

### Grok

Amp is the one that actually ships it — `~/.config/AGENTS.md` is its documented global file, and it also reads `~/.agents/skills/` for skills. So if you want one user-level AGENTS.md that at least one real harness honors, Amp is your target.

Everyone else still wants their own folder.

---

### User

So everyone else could use sym- symlinks to that generic location?

---

### Grok

Yes — that's the standard workaround. Symlink `~/.codex/AGENTS.md` to `~/.config/agents/AGENTS.md`, same for Claude's `~/.claude/CLAUDE.md`, and one file feeds all of them.

The catch is each harness still has its own native folder, so you're maintaining the symlinks yourself — and some tools resolve symlinks differently or refuse them, so test before you commit.

---

### User

Got it.

---

### Grok

Ok.

---

### User

Oh, by the way, are the personas a totally Grok-built specific thing, or is that concept pervasive even maybe if not standardized?

---

### Grok

Totally Grok Build-specific as a named feature — the `.grok/personas/` folder, the `config.toml` overlay, the `<system-reminder>` injection. No other harness has that exact mechanism.

The concept itself is everywhere, though. Claude Code, Cursor, Codex all let you define role-based subagents or rules that do the same job — a "skeptical reviewer" or "concise" persona — just under different names and file formats. Community packs even ship the same persona across Claude and Cursor by duplicating the config into each tool's native folder.

So the idea is pervasive; the portable convention isn't.

---

### User

So the concept basically bundles persona, sub-agent, and role into one thing?

---

### Grok

Yes — a persona is a role definition, and a sub-agent is just that role given its own process. The bundle is: identity, instructions, and optionally its own model and tools.

The split only matters when you want the role to run in parallel or with different permissions. Otherwise it's one concept wearing three names.

---

### User

How exactly is this different from a skill and what are the typical use cases for both that illustrate the difference?

---

### Grok

A persona is a *who* — a standing identity the agent wears for the whole session. A skill is a *how* — a procedure it follows for one task, then drops.

Concrete split: a "skeptical reviewer" persona changes how the agent talks and judges everything it touches. A "quality-gate" skill fires only when you ask it to implement something, runs the plan-review-verify loop, and then it's done.

So personas are for persistent style and judgment, skills are for repeatable workflows.

---

### User

It's not fully clear to me yet. For example, if we use the quality gate, this could be a persona, which is a sub-agent my harness triggers for the quality assurance, or it could be a skill it uses. So which would I pick?

---

### Grok

Pick the skill. A quality gate is a procedure — plan, review, verify, then stop — and that's exactly what skills are for.

A persona would only fit if you wanted the agent to *always* think like a reviewer, even when you're just asking a quick question. That's usually noise.

---

### User

No, that's not what I was talking about. The scenario I described to really show the parallel is the following. I have a main agent, like Grok Build or something, and the question is that main agent could spawn a sub-agent using a persona, or it could use a skill for the quality gate at the end.

---

### Grok

Both work, but they differ in who owns the loop. A skill is instructions the main agent follows itself — it reads the skill, does the plan-review-verify steps, and stays in control the whole time.

A persona-based sub-agent is a separate process: the main agent hands off the diff and intent, the reviewer runs with its own context, and reports back. That's the stronger isolation — the reviewer can't be swayed by the main agent's assumptions because it never saw them.

For a quality gate, I'd lean sub-agent. The whole point of the second pass is an independent eye, and a skill can't guarantee that — the same agent that wrote the code is the one "reviewing" it.

---

### User

Then I switched your recommendation. See how malleable this is and how fuzzy the boundary? So, how would you summarize now the the difference between the two concepts and when to use which?

---

### Grok

The real split is **execution model**, not content. A skill is a procedure the main agent runs in its own context — cheap, shared, but the same brain that wrote the code is the one checking it. A persona sub-agent is a separate process with its own context — expensive, but genuinely independent.

Use a skill when the steps matter more than the independence: checklists, conventions, "do X then Y then Z." Use a sub-agent when the independence matters more than the steps: a second opinion, a review that has to catch the author's blind spots, anything where the same model re-reading its own work would just confirm itself.

The fuzzy boundary exists because you can fake either with the other — a skill that says "spawn a reviewer" is a sub-agent in disguise, and a persona that only runs at the end is a skill with extra steps. Pick by what you're actually buying: shared procedure or separate judgment.

---

### User

Is a persona guarantee that it is actually a separate, um, sub-agent? Or can the main agent kind of assume a persona or run it in some, some non-isolated way?

---

### Grok

No guarantee. A persona is just a text overlay — the main agent can adopt it in-process, which means it still shares your full conversation history and assumptions. That's the weak version.

The strong version only happens when the harness actually spawns a separate process with a fresh context. Whether that happens depends on the tool and how the persona is defined, not on the concept itself.

---

### User

So neither the skill nor the persona, um, is really the knob to regulate when sub-agents are spawned.

---

### Grok

Right — both are just content. The spawn decision lives in the harness's own logic: it decides when to delegate based on the task, and you influence it only indirectly through the task prompt or by defining custom agents it can pick from.

The closest thing to a direct knob is hooks — a PreToolUse hook can intercept and redirect — but that's automation plumbing, not a persona or skill feature.

---

### User

So since the skill can explicitly instruct to spawn a sub-agent, now I'm kinda back to square one in my understanding. Which would be the better technique to add this unbiased quality reviewer and really encourage the harness to run long and do a job thoroughly?

---

### Grok

The skill is the better technique — not because it spawns the sub-agent, but because it makes the whole loop a **deliverable**.

The skill's body says: plan first, name the files you read, implement, then hand the diff to a fresh sub-agent for review, and don't stop until the reviewer's objections are resolved or explicitly rejected. That last part is what buys thoroughness — the agent has to produce the reviewer's verdict as output, so "I glanced at it" isn't an acceptable answer.

A persona alone can't do that. It's a tone setting, not a contract. The skill is the contract.

---

### User

Is a persona definition the same ability to, um, encourage being used and to encourage being used as a explicit sub-agent?

---

### Grok

No — a persona is weaker on both counts. It's a text overlay the main agent may or may not adopt, and even when it does, it usually stays in-process, so there's no isolation guarantee.

A custom agent definition is the stronger lever: the harness sees it as a spawnable specialist with its own prompt and context, so "use the reviewer agent" is a real delegation, not a suggestion the main agent can quietly ignore.

---

### User

Oh, bye. I totally forgot about the concept of custom agents. So we have agents, personas, and skills actually.

---

### Grok

Three layers, each with a different job. Skills are procedures, personas are tone overlays, custom agents are spawnable specialists with their own context.

For your quality reviewer, the custom agent is the one that actually delivers — the skill just tells the main agent when to call it.

---

### User

Okay, so just defining a custom agent gives me no guarantee whatsoever when and if the main agent will spawn it.

---

### Grok

No guarantee — the main agent decides based on the task description and the agent's own description field. A vague description means it gets ignored; a sharp one like "spawn this when reviewing code changes" makes it far more likely.

The only hard guarantee is a hook that forces the spawn, but that's automation, not agent design.

---

### User

Are custom agent at least guaranteed to be spawn as explicit isolated sub-agents?

---

### Grok

Yes — that's the one thing they do guarantee. A custom agent is defined as a separate process with its own context, model, and tools, so when the main agent spawns it, the isolation is real: fresh context, no inherited assumptions.

The uncertainty is only *whether* it spawns, not *how* it runs once spawned.

---

### User

What would you say is the main interface for the main agent? So I'm trying to figure out what the hierarchy is between these concepts. So would you rather say the main agent mainly looks for skills and then the skills may instruct to use a custom agent? Or is it more the other way around that the main agent looks for available custom agents and these are then instructed to use certain skills? How does this work?

---

### Grok

Skills are the main interface — the main agent matches your task against skill descriptions and pulls them in. Custom agents sit one level below: the main agent only sees them when a skill or the task itself points at one, like "have the reviewer agent check this."

So the hierarchy is task → skill → custom agent, not the reverse. Skills are the routing layer; agents are the specialists the routing can dispatch to.

---

### User

And the same for personas, I would assume they are also below the skills?

---

### Grok

Yes — personas are the lightest layer, below both. A skill can tell the main agent to adopt a persona for a stretch of work, but the persona never routes anything on its own.

So the full stack is task → skill → custom agent → persona, each level able to invoke the one below it but not the other way around.

---

### User

So, does this mean that the main agent will actually not use a sub-agent if that sub-agent is not referred to in any instruction or skill?

---

### Grok

No — the main agent can spawn sub-agents on its own, even without any skill or instruction pointing at them. It has built-in delegation logic: when a task looks parallelizable or research-heavy, it spins up workers on its own initiative.

Custom agents just make that delegation smarter. Without them, the main agent spawns generic workers; with them, it can pick a specialist whose description matches the job.

---

### User

Okay, so just defining a custom agent will ma-, will possibly make the main agent use it?

---

### Grok

Yes — the main agent sees the custom agent's description and matches it against the task, so a well-described agent gets picked up on its own.

The catch is the description is the only signal. Write "skeptical code reviewer for diffs" and it fires when you ask for a review; write something vague and it sits unused.

---

### User

So if the main agent does indeed scan those custom agent descriptions, then why do I need a skill for the main agent that directs to the custom agent?

---

### Grok

You don't, strictly — a sharp description is enough for the main agent to pick the reviewer on its own.

The skill earns its place when the *sequence* matters, not just the specialist. "Spawn the reviewer" is one step; "plan, implement, then spawn the reviewer, then fix whatever it flags" is a contract the description alone can't express. The skill is the routing logic, the agent is the worker it routes to.

---

### User

Okay, so I have a skill for the general process in which the review is one step, and then this one step in the skill can refer to the custom agent to use to execute the skill, the, that step.

---

### Grok

That's the clean composition — the skill owns the sequence, the custom agent owns the isolated judgment. One file defines the loop, one file defines the reviewer, and neither has to know the other's internals.

The only thing to watch is the handoff: the skill has to tell the main agent what to pass the reviewer — the diff, the intent, the files it touched — because the reviewer starts with a blank context.

---

### User

And now back to how we wire this together. So how do I make sure that automatically an implementation task, for example, uses the process skill?

---

### Grok

The description field is the trigger — write it so it matches how you actually phrase implementation requests, like "use when the user asks to add a feature, implement code, or change existing behavior."

Then set `user-invocable: false` so it never shows as a slash command, only auto-fires. The harness matches your prompt against that description semantically, so the wording has to be close to real language you'd use — too generic and it fires on everything, too narrow and it never fires.

---

### User

So the front matter only has the description field that actually regulates when it is triggered, and the user invocable stuff, that's just for whether it shows up as a slash command but it has no impact on when it is actually triggered.

---

### Grok

Mostly right, with one exception. The description is the main trigger signal, and `user-invocable` only controls the slash menu — but there's a second field, **`disable-model-invocation`**, that directly gates auto-triggering.

Set it to true and the skill becomes slash-only, never fires on its own. Set `user-invocable` to false and it disappears from the menu but still auto-fires. So the two fields are independent: one for visibility, one for autonomy.

---

### User

What's the default for the autonomy?

---

### Grok

Auto-triggering is on by default — the model can invoke a skill whenever its description matches, unless you explicitly set `disable-model-invocation: true`.

---

### User

Got it.

---

### Grok

Ok.

---

### User

Can a sub-agent define the model it uses?

---

### Grok

Yes. A custom agent definition in `.grok/agents/` can set its own model — that's one of the fields the agent type controls, alongside tools and system prompt.

Without an override it just inherits the parent's model, and you can also route by type in config, like `explore = "grok-build"`.

---

### User

So I can have a planner that uses a more expensive model, and then an developer or executor that uses a cheaper model, and then a reviewer that uses a more expensive model again.

---

### Grok

That's exactly the pattern DHH landed on — expensive model plans, cheap model executes, expensive model reviews. The harness just needs each custom agent to declare its own model, and the main agent routes by task type.

The one thing to watch is cost creep: if the planner keeps spawning expensive sub-agents for every little step, the savings from the cheap executor evaporate.

---

### User

How did you mean this cost creep if the planner? The planner is not the one who launches the executor. I, I didn't get that.

---

### Grok

The planner doesn't launch anything — the main agent does. It reads the plan, then decides how many executor sub-agents to spawn and what each one costs.

So the creep happens when the main agent over-delegates: it breaks the plan into twenty tiny tasks, each one a fresh expensive sub-agent call, instead of batching them into a few cheap executor runs. The planner's output is fine; the routing around it is where the money leaks.

---

### User

So that's assuming that the execution steps can be parallelized in some way, otherwise it would be the same agent, or what do you mean?

---

### Grok

No — parallelism isn't the assumption. Even a strictly sequential plan leaks money if the main agent spawns a fresh sub-agent per step: each spawn pays the full context-setup cost, and a cheap executor still costs more per call than just continuing in one session.

The cheap executor only wins when it runs long enough to amortize that setup — one agent chewing through several steps beats five agents each doing one.

---

### User

And generally, distributing this to different sub-agents can also save costs because as you said they start with a fresh context window, so maybe they don't have to process the context that is irrelevant to them.

---

### Grok

That's the real win — not parallelism, but **context isolation**. A sub-agent only pays for the tokens it actually needs, so a reviewer that only sees the diff never burns tokens re-reading your entire conversation history.

The tradeoff is the handoff itself: you have to write a good summary of what the sub-agent needs, and that summary costs tokens too. If the summary ends up as long as the context it replaces, you've gained nothing.

---

### User

Well, a summary can hardly be that long as a conversation, but I guess the money leak is in spawning unnecessarily many execution agents instead of just one.

---

### Grok

Exactly — the summary is cheap, the spawn is expensive. Each new agent pays a fixed cost for its own context setup, tool initialization, and the first round-trip, regardless of how little work it does.

So the rule is: one executor per coherent chunk of work, not one per step. If the steps share files and context, keep them in the same agent.

---

### User

Currently there isn't really leverage inside Grok Build to use different models, I think? So there is basically Grok 4.6 and I don't know whether 4.5 is even still available or if it's even cheaper than 4.6.

---

### Grok

You're right that the leverage is thin. Grok 4.6 is the default in Grok Build, and 4.5 is still listed on the API at the same two-dollar-in, six-dollar-out rate — but it's superseded, not cheaper.

The only real price gap is **Grok Build 0.1**, half the cost at one dollar in and two dollars out, but it's a 256K context model built for speed, not a cheaper frontier model. So the DHH-style expensive-plan, cheap-execute split doesn't map cleanly onto Grok's lineup the way it does onto Claude or GPT tiers.

---

### User

So the real lever there is the thinking effort.

---

### Grok

That's the lever, yes — same model, different effort. Grok Build exposes low, medium, and high thinking, and the high setting is what you'd point at the planner and reviewer while the executor runs low.

It's a coarser dial than model tiers, but it does the same job: pay for deep reasoning where judgment matters, skip it where the work is mechanical.

---

### User

I could have a skill for planning that basically encourages the main agent to create a markdown file in the repository. So I don't have to tell it that every time the conversation goes towards planning.

---

### Grok

That's the cleanest use of a skill — the description matches "let's plan this" or "design the approach," and the body tells the agent to write the plan to a fixed path like `docs/plans/` instead of dumping it in chat.

One thing to add to the skill: tell it to name the file after the feature, so you end up with a folder of plans you can browse and @-mention later instead of one overwritten file.

---

### User

So that basically works around the weird conversation plan mode.

---

### Grok

Exactly — you get the artifact without the mode. The plan lives in the repo as a normal file, so you can discuss it, sidetrack, come back, and the agent never forgets it because it's just text on disk.

The only thing you give up is the harness's built-in plan-approval UI, but for your workflow that's a feature, not a loss.

---

