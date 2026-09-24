# Task execution

How to execute a card that links this file. A prompt with no task document does not load it. The card adds acceptance. It does not replace this.

1. Read the card, its parent epic if it has one, the goal or philosophy it links, and the as-is notes it points at. Set **Status** to `in progress`, move its checkbox on [the board](BOARD.md) under the heading that matches, and log that the work started.
2. Stay inside **Scope** and non-goals. Stop and ask, and do not implement around it, when the change would land outside those files, folders, or types, a file is past the limit below, or a new concern would be stuffed into an existing type. The next card introduces the type this one was not allowed to invent inline.
3. Implement. Use a toolbox means when the card or this file links one.
4. Fresh review against the parent epic, the linked goal or philosophy, and this file. Prefer the reviewer specialist when this repo has one.
5. Run the project's checks and the card's acceptance.

**File limit:** 200 lines. A file already past that must not grow.

## Done

- Checks pass, or the card says why a check does not apply.
- Acceptance items are met.
- The diff contains only this task.
- **Status** is `done`, the log records that the work completed, and the board shows the card under `## done` as `- [x]`.

## While in progress

Append a log line when something matters: a hypothesis, what was tried, a blocker, a branch or PR, and the start and completion of the work. Enough for the next session to resume.
