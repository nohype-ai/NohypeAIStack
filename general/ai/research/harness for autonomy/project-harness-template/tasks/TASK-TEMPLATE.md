# Task template

The card is the plan. There is no separate plan. A filled-in field list is not yet a plan. The [Plan](#plan) section below is the planning work: enough detail, in that structure, that a human can approve it.

Every field is a line in the card. **Status** is one of `concept`, `ready to implement`, `in progress`, `done`. It stays `concept` until every other line is filled or marked none, the plan section is written, and a human has approved that plan. Only then may **Status** become `ready to implement`. An agent does not make that change. The execution link is never none.

- **Status:** `concept`
- **Parent:** an epic in this folder that groups the card, or none.
- **Goal:** a link to [a high-level goal](../docs/GOALS.md) or to [the philosophy](../docs/PHILOSOPHY.md), or none.
- **Execution:** link to [TASK-EXECUTION.md](TASK-EXECUTION.md). Required on every card.
- **Skills:** the skills this task depends on, or none. A task that changes code structure includes [architecture](../.agents/skills/architecture/SKILL.md). A task that writes or reviews Swift includes [swift](../.agents/skills/swift/SKILL.md).
- **Outcome:** what is true when the task is done.
- **Scope:** the files, folders, and types that hold the solution. None when the card does not touch code.
- **Non-goals:** what this task will not change.
- **Acceptance:** checks a stranger can run or read.
- **Risks / deps:** what can make it fail, and what it waits on.

## Plan

Required. This is the planning work.

- **Fit:** where this change lands in what already exists, and why that place.
- **Steps:** the ordered changes. Each step names what it changes and what it leaves alone.
- **Open:** what is still unresolved. None when the plan is ready for a human to approve.

## Quality gate

Required for every card.

1. The main agent reviews with the [review](../.agents/skills/review/SKILL.md) skill.
2. Then the [final-review](../.grok/agents/final-review.md) subagent reviews. It starts fresh and does not edit.

## Log

Events as they happen. Nothing is filled in advance.

Place the card in its epic folder, or directly in `tasks/` when it has no parent.
