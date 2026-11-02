---
name: review
description: The main agent's review of a task card's change, before final-review. Use when that card's quality gate says the main agent reviews.
---

Read the card, its parent `README.md` if it has one, the goal it links, and the diff.

Report gaps. Cite the file. Do not propose extra scope.

- **Scope** and **Non-goals** respected. No new concern stuffed into an existing type.
- **Acceptance criteria** met. Named checks ran.
- Diff is only this task.
- File limit in [TASK-EXECUTION.md](../../../tasks/TASK-EXECUTION.md) respected.
- A comment states a fact the code cannot. It does not narrate the edit.

This is the main agent's own review. [final-review](../final-review/SKILL.md) runs after this one, in a fresh agent.
