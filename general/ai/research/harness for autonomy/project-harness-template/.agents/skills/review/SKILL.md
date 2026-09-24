---
name: review
description: Review a change against its task card, parent epic, linked goal or philosophy, and the task execution file. Use for a review pass or the fresh review before done.
---

Read the card, its parent epic if it has one, the goal or philosophy it links, and the diff.

Report gaps. Cite the file.

- Scope creep, missed acceptance, or a check that was not run.
- The solution landed outside the files, folders, or types named in **Scope**, or a new concern was stuffed into an existing type.
- A comment narrates the change, including one about code that is gone.
- A workaround around a constraint the diff never questions.
- A late hint became its own section instead of landing where the structure already has a place.

On Grok, spawn the `reviewer` agent for this pass so it starts without the implementer's context. Otherwise do the same review in a fresh pass.
