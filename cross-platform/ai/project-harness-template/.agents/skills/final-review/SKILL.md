---
name: final-review
description: Final review of a task card's change, after the main agent has reviewed. Read-only, in a fresh agent. Use when the card's quality gate requires this pass.
---

This is the final review. It does not edit. It starts without the implementer's context.

Read the card, its parent epic if it has one, the goal or philosophy it links, the diff, and the main agent's review. Judge only against those and [TASK-EXECUTION.md](../../../tasks/TASK-EXECUTION.md).

Report concrete gaps. Cite the file. Say what is satisfied. Do not propose extra scope.

- The solution landed outside the files, folders, or types named in **Scope**, or a new concern was stuffed into an existing type.
- A comment narrates the change, including one about code that is gone.
- A workaround around a constraint the diff never questions.
- A late hint became its own section instead of landing where the structure already has a place.
