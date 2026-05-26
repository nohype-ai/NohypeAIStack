# The AI Coding Stack

Coding is the most impactful use case, applicable to any work on markdown files, and most indicative of agentic performance, so this stack is the baseline and may later inform other specialized use cases.

## Current AI Coding Stack

The research here had exploded and driven me crazy. But it yielded a clear result. Everything contracted quickly when Grok Build finally came out. Our AI coding (knowledge work) stack is now mostly settled:
- IDEs: Zed & Obsidian
- Agent: Grok Build via ACP in Zed and via TUI
- Provider: xAI (duh)
- Model: whatever Grok variants are available in Grok Build

Why Grok Build:
- ACP integration worked instantly and flawlessly, which is absolutely not the norm. What a relief.
- The TUI is already superior to Claude Code.
- xAI iterates rapidly.
- Performance per dollar is excellent with Grok models.
- Speed is excellent.
- Risk of throttling is lower than with competitors.
- CLI agent is first class product and not byproduct, and it shows in so many ways.
- Emphasis on privacy.
- SOTA list of agent features
- High level of polish.

Why Zed:
- Native, fast, efficient memory usage. Not a bloated VSCode fork.
- ACP
- Modern, mature and highly customizable

Why Obsidian:
- English is now the most important programming language. And its format is markdown.
- Yeah that's it. We pull everything into markdown so agents can work on everything. Code and concepts merge. Obsidian is the IDE for exactly that conceptual informal perspective And it still offers visual interfaces on top of markdown: Kanban board, canvas and more.
- In particular, the ai agent harnesses ("process as documentation") and knowledge bases ("LLM wiki") which are becoming part of projects deserve their own specialized editor.

## Preliminary Conclusion on Open-Source Models (like via DeepInfra)

Open-source remote models for knowledge work agents turned out as a dead end. The added complexity of comparing and testing models, working around issues, and staying up to date would not just be an initial investment but a repeated ongoing cost. This effort and cognitive load are not worth the potential marginal cost savings, in particular since Grok Build is finally out. Open-source models will only become relevant to us with local inference.
