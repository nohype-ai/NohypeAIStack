# Task template

Every field is a line in the card. **Status** is one of `concept`, `ready to implement`, `in progress`, `done`.

Move it to `ready to implement` only when every other line is filled or marked none. The execution link is never none.

- **Status:** `concept`
- **Parent:** an epic in this folder that groups the card, or none.
- **Goal:** a link to [a high-level goal](../docs/GOALS.md) or to [the philosophy](../docs/PHILOSOPHY.md), or none.
- **Execution:** link to [TASK-EXECUTION.md](TASK-EXECUTION.md). Required on every card.
- **Outcome:** what is true when the task is done.
- **Scope:** the files, modules, or behavior in play.
- **Non-goals:** what this task will not change.
- **Acceptance:** checks a stranger can run or read.
- **Risks / deps:** what can make it fail, and what it waits on.

## Log

- **Started:** when **Status** becomes `in progress`.
- **Completed:** when **Status** becomes `done`.

Place the card in its epic folder, or directly in `tasks/` when it has no parent. On [the board](BOARD.md), put a checkbox link to the card under the heading that matches **Status**. A done card is `- [x]`.
