# Task execution

How to execute a card that links this file. A prompt with no card does not load it. Acceptance for every card: the checks pass, and the final review is green. The card’s acceptance criteria add to that. They do not replace it.

## Progress

Record progress in both places. They must match.

| Status | Folder |
| --- | --- |
| `concept`, `ready to implement` | [backlog/](backlog/) |
| `in progress` | [in progress/](in%20progress/) |
| `done` | [done/](done/) |

Move the card. Keep its path under the epic: `backlog/<epic>/leaf.md` → `in progress/<epic>/leaf.md` → `done/<epic>/leaf.md`. The epic `README.md` stays in `backlog/` until every child is done; then the remaining folder moves to `done/`. Append a log line on each move. Move the matching checkbox on [BOARD.md](BOARD.md) to the same column as the folder.

## Steps

1. If **Status** is not `ready to implement`, stop. Do not set it to ready. That takes a human.
2. Read the card, its parent `README.md` if it has one, the goal it links, and the as-is docs it points at. Set **Status** to `in progress`, move the card into [in progress/](in%20progress/), update [BOARD.md](BOARD.md), log that work started.
3. Stay inside **Scope** and **Non-goals**. Stop and ask when the change would land outside those files, folders, or types, a file would pass the limit below, or a new concern would be stuffed into an existing type.
4. Implement. Use a command from [TOOLBOX.md](TOOLBOX.md) when one applies. Do not search for a substitute. Load a skill when the card names it, or when a skill description matches.
5. Review with [review](../.agents/skills/review/SKILL.md).
6. Run [final-review](../.agents/skills/final-review/SKILL.md) in a fresh agent. It does not edit.
7. Run the checks named in [TOOLBOX.md](TOOLBOX.md).

**File limit:** 200 lines. A file already past that must not grow.

## Done

- Checks pass, or the card says why a check does not apply.
- The diff contains only this task.
- Final review is green.
- The card’s acceptance criteria are met, or the section says none.
- **Status** is `done`, the log records completion, the card is in [done/](done/), and [BOARD.md](BOARD.md) shows it under `## done` as `- [x]`.

## While in progress

Append a log line when something matters: a hypothesis, what was tried, a blocker, a branch or PR, start, completion. Enough for the next session to resume.

On friction, file a harness task. Do not only work around it.
