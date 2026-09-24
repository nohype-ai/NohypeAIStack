---
name: review
description: The main agent's review of a task card's change, before the final-review subagent. Use when that card's quality gate says the main agent reviews.
---

Read the card, its parent epic if it has one, the goal or philosophy it links, and the diff.

Report gaps. Cite the file.

- Scope creep, missed acceptance, or a check that was not run.
- The solution landed outside the files, folders, or types named in **Scope**, or a new concern was stuffed into an existing type.
- A comment narrates the change, including one about code that is gone.
- A workaround around a constraint the diff never questions.
- A late hint became its own section instead of landing where the structure already has a place.

This is the main agent's own review. The final review is a separate subagent and runs after this one.
