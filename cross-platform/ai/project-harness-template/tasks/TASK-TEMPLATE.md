# Task template

The card is the plan. A filled field list is not yet a plan: the **Plan** section is. **Status** stays `concept` until every required field is filled, plan and acceptance criteria are written, and a human has approved that plan. An agent does not set **Status** to `ready to implement`.

## Hierarchy

Non-leaves are folders. Each has a `README.md` (intent, non-goals, child order) plus leaf cards and/or further folders.

```
tasks/backlog/
  example-epic/
    README.md              ← epic (non-leaf)
    example-task.md        ← leaf (this template)
    sub-epic/
      README.md
      leaf.md
```

An unparented leaf may sit directly in `backlog/`. Status and folder must match; see [TASK-EXECUTION.md](TASK-EXECUTION.md).

## Fields

`none` is allowed only where marked. **Execution** is never none.

- **Status:** `concept` | `ready to implement` | `in progress` | `done`
- **Parent:** the epic folder this card belongs to, or none
- **Goal:** a link to a goal in [VISION.md](../docs/VISION.md), or none
- **Execution:** [TASK-EXECUTION.md](TASK-EXECUTION.md)
- **Skills:** skills this task needs, or none. A structure change includes [architecture](../.agents/skills/architecture/SKILL.md). A language change includes that language’s skill under `.agents/skills/`
- **Outcome:** what is true when the task is done
- **Scope:** files, folders, and types that hold the solution, or none if the card does not touch code
- **Non-goals:** what this task will not change
- **Risks / deps:** what can make it fail, and what it waits on, or none

## Plan

Required.

- **Fit:** where this change lands in what already exists, and why that place
- **Steps:** the ordered changes. Each step names what it changes and what it leaves alone
- **Open:** what is still unresolved, or none when a human may approve

## Acceptance criteria

Required. What is true of this change, beyond the checks and the final review that every card goes through. `none` when those are enough.

## Quality gate

Required on every card.

1. The main agent reviews with [review](../.agents/skills/review/SKILL.md).
2. A fresh agent reviews with [final-review](../.agents/skills/final-review/SKILL.md). It does not edit.

## Log

Events as they happen. Empty until work starts.
