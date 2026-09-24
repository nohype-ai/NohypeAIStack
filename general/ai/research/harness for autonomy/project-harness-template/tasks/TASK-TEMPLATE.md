# Task template

Every field is a line in the card. **Status** is one of `concept`, `ready to implement`, `in progress`, `done`. It stays `concept` until every other line is filled or marked none. The execution link is never none.

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

## Log

Events as they happen. Nothing is filled in advance.

Place the card in its epic folder, or directly in `tasks/` when it has no parent.
