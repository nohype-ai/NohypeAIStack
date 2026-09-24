---
name: review
description: Review a change against its task card, parent epic, linked goal or philosophy, and the task execution file. Use for a review pass or the fresh review before done.
---

Read the card, its parent epic if it has one, the goal or philosophy it links, and the diff.

Report gaps: scope creep, missed acceptance, a check that was not run, or a poor fit with the surrounding code. Cite the file.

On Grok, spawn the `reviewer` agent for this pass so it starts without the implementer's context. Otherwise do the same review in a fresh pass.
