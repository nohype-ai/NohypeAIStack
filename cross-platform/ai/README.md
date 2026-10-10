# The AI Stack

## Intro

Here we cover our current AI stack. General layers, and conclusions that are not a choice of tools, are in [General AI Stack](../../notes/cross-platform/ai/README.md). Open research is in [research/](../../notes/cross-platform/ai/research/).

Coding is the most impactful use case, applicable to any work on markdown files, and most indicative of agentic performance, so **this stack is a coding stack**. This baseline may later inform other specialized use cases.

This stack does not yet involve local inference but still focusses on scaling up productivity. Research on local inference for privacy and cost-efficiency at scale [will follow in time](../../notes/cross-platform/ai/research/README.md).

## Current AI Coding Stack

- Agent Clients: Zed & Obsidian
  - [Zed](https://dashboard.zed.dev) (via GitHub account)
  - login unlocks tab completions ("edit predictions")
  - Zed Pro is only for the mediocre internal Zed agent
- Agent: Grok Build via ACP in Zed/Obsidian and via TUI
- Provider: xAI (duh)
- Model: Grok variants

## Zed

### Good
- Native, fast, efficient memory usage. Not a bloated VSCode fork.
- ACP
- Modern, mature and highly customizable
- It's AI first in general: CLI, settings, integrations etc.

### Bad
- Extensions have no good visualization API so they are very limited
- No preview of PDF files or other pervasive office formats

## Obsidian

### Good
- English is now the most important programming language. And its format is markdown.
- Yeah that's it. We pull everything into markdown so agents can work on everything. Code and concepts merge. Obsidian is the IDE for exactly that conceptual informal perspective, and it still offers visual interfaces on top of markdown: Kanban board, canvas and more.
- In particular, the ai agent harnesses ("process as documentation") and knowledge bases ("LLM wiki") which are becoming part of projects deserve their own specialized editor.
- Equally available on Linux/Omarchy
- Extension system makes anything possible
- ACP agent integration works well via extension

### Bad
- Obsidian is based on Electron and gobbles up huge amounts of RAM for a markdown editor

## Grok Build

### Good
- ACP integration worked instantly and flawlessly
- The TUI was world class from the start (UI and UX)
- xAI iterates rapidly
- Performance per dollar is excellent with Grok models
- Speed is excellent
- Risk of throttling is lower than with competitors
- CLI agent is first class product and not byproduct, and it shows in so many ways
- Emphasis on privacy
- Emphasis on real-world engineering and truth seeking
- SOTA list of agent features
- High level of polish

### Bad
- Grok is not frontier at software engineering. It requires a good project harness for actual autonomy/parallelism.
- Grok 4.7 even seems to have regressed in some aspects.
