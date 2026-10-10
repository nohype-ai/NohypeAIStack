# AI Stack Layers

The layers of an AI stack, and conclusions that outlive a particular choice of tools. Our current stack is [The AI Stack](../../../cross-platform/ai/README.md). Open research is in [research/](research/).

## The Layers

1. Agent Clients
  - GUI frontends to agents – natively or via ACP.
2. Agents
  - Coding Agents
  - Personal Agents
    - Not deeply explored yet. Grok Bot has good UX but didn't add value.
3. Providers
  - Cloud services that offer access to model inference. Related research is in [byok costs.md](research/byok%20costs.md) and [routers.md](Routers.md).
  - Routers (Aggregators)
    - These poviders do not provide inference themselves but only act as gateways that aggregate- and route to other providers.
  - Open Weights Providers
    - These providers only provide the inference, hosting a wide range of publically available models.
  - Proprietary Providers
    - These providers provide the inference and also train the models and are often the only way to access these models.
4. Models
  - Available models are determined by each agent+provider combination.
  - Costs differ widely - more than performance.
  - [Coding leaderboard](https://arena.ai/leaderboard/text/coding?viewBy=plot&rankBy=labs)
  - [Code leaderboard](https://arena.ai/leaderboard/code?viewBy=plot&rankBy=labs)

## Preliminary Conclusions on Open Layers

### Open-Source Models Are Not Worth It

Open-source remote models (like via DeepInfra) for knowledge work agents turned out as a dead end. The added complexity of comparing and testing models, working around issues, and staying up to date would not just be an initial investment but a repeated ongoing cost. This effort and cognitive load are not worth the potential marginal cost savings, in particular since Grok Build is finally out. Open-source models will only become relevant to us with local inference.

### Vertical Integration Crushes Open Modularity

The whole modular approach of mixing and matching open components turned out to be a costly mess. It is freeing in theory but falters under its own complexity in practice.

between IDE, agent, inference provider and model are three boundaries. if those boundaries are not managed by one company within one product, it is almost guaranteed that something somewhere fails. 

protocols, standards and general landscape are not mature enough to reliably handle these boundaries. often protocols exist but are not strictly adhered to, leading to hangs and other failures (ACP).

this is particularly true because:
1. the inference provider is not just a thin dumb proxy but an involved compatability layer that has to handle each (open-weight-) model individually and has ample room for doing things in unique incompatible interfering ways. so its boundaries to model and agent are two real ones.
2. the IDE is not (yet) made obsolete by TUI agents. reviewing changes, exploring a project, picking context, using IDE features is still easier with IDEs. so the boundary between IDE and agent is also a real one. an example that bridges it seemlessly is the Cursor IDE, but that may lack vertical integration at other boundaries. the default interface here is the ACP.
