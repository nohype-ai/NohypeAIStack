# The AI Stack

This README defines the general layers of an AI stack and lists our specific stack. General research and past decisions are documented in [research/](research/).

Coding is the most impactful use case, applicable to any work on markdown files, and most indicative of agentic performance, so this stack is a coding stack. This baseline may later inform other specialized use cases.

This stack does not yet involve local inference but still focusses on scaling up productivity. Research on local inference for privacy and cost-efficiency at scale [will follow in time](research/README.md).

## Current AI Coding Stack

- Agent Clients: Zed & Obsidian
  - [Zed](https://dashboard.zed.dev) (via GitHub account)
  - login unlocks tab completions ("edit predictions")
  - Zed Pro is only for the mediocre internal Zed agent
- Agent: Grok Build via ACP in Zed and via TUI
- Provider: xAI (duh)
- Model: Grok variants

Why Grok Build:
- ACP integration worked instantly and flawlessly
- The TUI was world class from the start (UI and UX)
- xAI iterates rapidly
- Performance per dollar is excellent with Grok models
- Speed is excellent
- Risk of throttling is lower than with competitors
- CLI agent is first class product and not byproduct, and it shows in so many ways
- Emphasis on privacy
- SOTA list of agent features
- High level of polish

Why Zed:
- Native, fast, efficient memory usage. Not a bloated VSCode fork.
- ACP
- Modern, mature and highly customizable

Why Obsidian:
- English is now the most important programming language. And its format is markdown.
- Yeah that's it. We pull everything into markdown so agents can work on everything. Code and concepts merge. Obsidian is the IDE for exactly that conceptual informal perspective, and it still offers visual interfaces on top of markdown: Kanban board, canvas and more.
- In particular, the ai agent harnesses ("process as documentation") and knowledge bases ("LLM wiki") which are becoming part of projects deserve their own specialized editor.

## General Stack Layers

### Agent Clients

- GUI frontends to agents – natively or via ACP.

### Agents

- Coding Agents
- Personal Agents
  - Not deeply explored yet. Grok Bot has good UX but didn't add value.
  - Check out these:
    - [Grok Bot](https://x.ai/bot)
    - [Hermes Agent](https://hermes-agent.nousresearch.com)

### Providers

Cloud services that offer access to model inference. Related research is in [byok costs.md](research/byok%20costs.md) and [routers.md](research/routers.md).

#### Routers (Aggregators)
These poviders do not provide inference themselves but only act as gateways that aggregate- and route to other providers.

#### Open Weights Providers
These providers only provide the inference, hosting a wide range of publically available models.
- [DeepInfra](https://deepinfra.com) (via GitHub account)
  - cheap and fast inference provider for open models
  - [Model Prices](https://deepinfra.com/models/text-generation)

#### Proprietary Providers
These providers provide the inference and also train the models and are often the only way to access these models.
- [xAI](https://console.x.ai) (normal login)
  - no free models
  - good mix of cheap (Grok 4 Fast) and frontier (Grok 4.20)
  - [Model Prices](https://docs.x.ai/developers/models#model-pricing)

### Models

- Available models are determined by each agent+provider combination.
- Costs differ widely - more than performance.
- https://arena.ai/leaderboard/text/coding?viewBy=plot&rankBy=labs
- https://arena.ai/leaderboard/code?viewBy=plot&rankBy=labs

## Other Preliminary Conclusions

### Open-Source Models Are not Worth It

Open-source remote models (like via DeepInfra)
 for knowledge work agents turned out as a dead end. The added complexity of comparing and testing models, working around issues, and staying up to date would not just be an initial investment but a repeated ongoing cost. This effort and cognitive load are not worth the potential marginal cost savings, in particular since Grok Build is finally out. Open-source models will only become relevant to us with local inference.

### Vertical Integration Crushes Open Modularity

The whole modular approach of mixing and matching open components turned out to be a costly mess. It is freeing in theory but falters under its own complexity in practice.

between IDE, agent, inference provider and model are three boundaries. if those boundaries are not managed by one company within one product, it is almost guaranteed that something somewhere fails. 

protocols, standards and general landscape are not mature enough to reliably handle these boundaries. often protocols exist but are not strictly adhered to, leading to hangs and other failures (ACP).

this is particularly true because:
1. the inference provider is not just a thin dumb proxy but an involved compatability layer that has to handle each (open-weight-) model individually and has ample room for doing things in unique incompatible interfering ways. so its boundaries to model and agent are two real ones.
2. the IDE is not (yet) made obsolete by TUI agents. reviewing changes, exploring a project, picking context, using IDE features is still easier with IDEs. so the boundary between IDE and agent is also a real one. an example that bridges it seemlessly is the Cursor IDE, but that may lack vertical integration at other boundaries. the default interface here is the ACP.
