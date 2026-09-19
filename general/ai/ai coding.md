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
- Yeah that's it. We pull everything into markdown so agents can work on everything. Code and concepts merge. Obsidian is the IDE for exactly that conceptual informal perspective, and it still offers visual interfaces on top of markdown: Kanban board, canvas and more.
- In particular, the ai agent harnesses ("process as documentation") and knowledge bases ("LLM wiki") which are becoming part of projects deserve their own specialized editor.

## Preliminary Conclusion on Open-Source Models (like via DeepInfra)

Open-source remote models for knowledge work agents turned out as a dead end. The added complexity of comparing and testing models, working around issues, and staying up to date would not just be an initial investment but a repeated ongoing cost. This effort and cognitive load are not worth the potential marginal cost savings, in particular since Grok Build is finally out. Open-source models will only become relevant to us with local inference.

## Vertical Integration Crushes Open Modularity

The whole modular approach of mixing and matching open components turned out to be a costly mess. It is freeing in theory but falters under its own complexity in practice.

between IDE, agent, inference provider and model are three boundaries. if those boundaries are not managed by one company within one product, it is almost guaranteed that something somewhere fails. 

protocols, standards and general landscape are not mature enough to reliably handle these boundaries. often protocols exist but are not strictly adhered to, leading to hangs and other failures (ACP).

this is particularly true because:
1. the inference provider is not just a thin dumb proxy but an involved compatability layer that has to handle each (open-weight-) model individually and has ample room for doing things in unique incompatible interfering ways. so its boundaries to model and agent are two real ones.
2. the IDE is not (yet) made obsolete by TUI agents. reviewing changes, exploring a project, picking context, using IDE features is still easier with IDEs. so the boundary between IDE and agent is also a real one. an example that bridges it seemlessly is the Cursor IDE, but that may lack vertical integration at other boundaries. the default interface here is the ACP.