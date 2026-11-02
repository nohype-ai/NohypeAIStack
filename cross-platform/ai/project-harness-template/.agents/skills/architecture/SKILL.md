---
name: architecture
description: How to place a change in the structure that already exists. Use when a task changes code structure. Language-agnostic.
---

Project structure and decisions: [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md).

- The solution lives in the files, folders, and types the task named. A new concern gets its own type rather than joining one that already has a job.
- If the natural home would grow past the file limit in [TASK-EXECUTION.md](../../../tasks/TASK-EXECUTION.md), or a hub would take on another responsibility, stop. The next card introduces the type.
- A constraint that makes the change awkward gets named. It is not worked around in silence.
