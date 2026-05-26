# Coding Agents

## ACP Coding Agents Comparison (March 2026)

ACP allows using the agents in any IDE, most notably in Zed. It enables rotating through several different agents in the same IDE. Also Zed is much faster, memory efficient and open than VS Code based IDEs, so it's the way to go anyways. So we limit this to agents with ACP integration in Zed plus Zed's own agent.

| Agent              | Agentic Performance | BYOK | Cost Min                                      | Cost Max                                      | Token Efficiency | Free Tier                                      |
|--------------------|---------------|------|-----------------------------------------------|-----------------------------------------------|--------------------|------------------------------------------------|
| **Grok Build**   | ??            | 🛑 | ?? (Grok Code Fast 1)                     | ?? (Grok 4.3)                      | ??                 | too tight limits ($30/mo excellent)          |
| **Claude Code**   | 98            | 🛑 | $1.00 (Claude Haiku 4.5)                     | $5.00 (Claude Opus 4.6)                      | 96                 | None (Pro $20/mo required for agent)          |
| **Codex** (CLI)   | 93            | 🛑 | $0.20 (GPT-5.4 Nano)                         | $2.50 (GPT-5.4)                              | 91                 | Limited (30–150 messages/5 hrs with Plus $20/mo) |
| **Cursor Agent**  | 89            | 🛑 (many models though)   | $0.10 (Gemini 2.5 Flash-Lite)                | $5.00 (Claude Opus 4.6)                      | 68                 | Limited agent requests (Hobby free tier)      |
| **Kimi CLI**      | 87            | 🛑 | $0.60 (Kimi K2.5)                            | $0.60 (Kimi K2.5)                            | 85                 | Limited daily queries (casual-use free tier)  |
| **Gemini CLI**    | 84            | 🛑 | $0.10 (Gemini 2.5 Flash-Lite)                | $2.00 (Gemini 3.1 Pro)                       | 89                 | 1,000 requests/day (free Google account)      |
| **OpenCode**      | 78            | ✅ | $0.10 (Gemini 2.5 Flash-Lite)                | $5.00 (Claude Opus 4.6)                      | 82                 | 1,000 req/day (Gemini free) **or** unlimited local |
| **GitHub Copilot**| 72            | 🛑 | Subscription ($10–39/mo + usage)             | Subscription ($10–39/mo + usage)             | 65                 | 2,000 completions + 50 premium req/mo         |
| **Kilo**          | 70            | ✅ | $0.10 (Gemini 2.5 Flash-Lite)                | $5.00 (Claude Opus 4.6)                      | 75                 | 1,000 req/day (Gemini free) **or** unlimited local |
| **Cline**         | 67            | ✅ | $0.10 (Gemini 2.5 Flash-Lite)                | $5.00 (Claude Opus 4.6)                      | 73                 | 1,000 req/day (Gemini free) **or** unlimited local |
| **Zed Agent**     | 60            | ✅ | $0.10 (Gemini 2.5 Flash-Lite)                | $5.00 (Claude Opus 4.6)                      | 62                 | 1,000 req/day (Gemini free) **or** unlimited local |

**Note on Cursor agent**:
* It offers virtually all models but provides them through its own plans with no true BYOK option.
* It offers no pure per token pricing but ties everything to subscriptions.
* Its free tier has maybe worthwile rate limits but does not support ACP.

### Install ACP Agents in Zed

* 🚨 To set up an agent via ACP in Zed, install it within Zed from the ACP registry (Shift + Cmd + P -> "zed: acp registry"). Do **not** add a regular (Homebrew-) installation of the same agent as a custom agent to settings.json, since that will likely not work, as ACP support (from Zed and from agents) is generally still immature anyway. The installs offered via the registry are optimized and tested for ACP and Zed.
* However, at least the registry install of an agent is exclusively managed and used by Zed and will never conflict with a regular system-wide install of the same agent.
* In theory, ACP registry installs all support authentication via ACP, but that does not work with all registry-installed agents. The reliable route is to also have a regular system-wide (Homebrew-) install of the same agent and use that one for initial authentication (connecting the agent to a/its provider).

## OpenCode

OpenCode is the best open-source- and the best BYOK coding agent.

**Why OpenCode?**
- Open-source and highly established (130k GitHub stars)
- Built from the ground up to work with any model/vendor
- Native support for local models
- Pure CLI agent (with ACP) as well as desktop app
- Desktop app is much leaner than VS Code based IDEs (memory footprint)
- Native pay-as-you-go pricing is offered (OpenCode Zen) and gives model variety (but charges 6.15% fee)
- No lock-in into subscriptions, models, APIs or even agents (zen can be used in any agent/app via API key)

**Offerings:**
* **OpenCode Core (Standard BYOK):** The core OpenCode software naturally lets you inject an API key from any provioder (e.g., an OpenRouter key, an xAI API key, or a Google AI Studio key). **Your cost is $0 to OpenCode.** You rely 100% on the inference pricing defined by your external model provider. OpenCode supports **75+ model providers** directly via the AI SDK + Models.dev.
* **OpenCode Zen:** This is their pay-as-you-go proxy service. Zen allows you to access a curated list of open models hosted by OpenCode partner providers.
* **OpenCode Go:** A $10/month flat-rate subscription that gives access to set models without worrying about usage tokens.

## Essential Combinations: Coding Agent + Provider

### Selection Criteria

The basic category here is coding (not general purpose) and cloud inference (not local inference). Further criteria for combo selection were:
* Use lean client apps like Zed or OpenCode Desktop (instead of the many bloated, memory-inefficient, slow forks of VS Code)
* Include the option to decouple client app from agent by leveraging ACP
* Cover range of cheap/fast- versus intelligent models as well as open weights- versus proprietary models
* Use a given provider only with the best agents available for it (for example, Anthropic API key in OpenCode makes no sense)
* Avoid free variants with impractically tight rate limits (OpenCode Zen free models)
* Avoid low performing agents (Zed's own internal Zed agent)
* Avoid inference outside US/Europe
* Avoid OpenAI

### Agents via ACP (in Zed) and via TUI

| Agent | Provider | free/paid | ACP (Zed)? | TUI? | Viable? |
| --- | --- | --- | --- | --- | --- |
| Grok Build | xAI | subscription / API key | ✅ (custom) | ✅ (best) | ✅ (flawless) |
| Gemini CLI | Google AI | free (login) | ✅ (5?) | ✅ (5) | ✅ |
| OpenCode | DeepInfra | API key | ✅ (2) | ✅ (2) | ✅ |
| OpenCode | xAI | API key | ✅ | ✅ | ✅ |
| Gemini CLI | Google AI | API key / subscription | ✅ (5?) | ✅ (5) | ✅ |
| Claude Code | Anthropic | API key / subscription | ❓ (6) | ✅ | ✅ |
| Amp | Amp | usage based | 🛑 (10) | ❓ | ❓ |
| Cursor CLI | Cursor | subscription | ✅ (4) | ✅ | 🛑 (8) |
| OpenCode | OpenCode Zen | paid models (+6.15% fee) | ✅ | ✅ | 🛑 (9) |
| Cursor CLI | Cursor | free tier | 🛑 (3) | ⚠️ (7) | 🛑 (7) |
| OpenCode | OpenRouter | free models | 🛑 (1) | ✅ | 🛑 |
| OpenCode | OpenRouter | paid models (+5.5% fee) | 🛑 (1) | ✅ | 🛑 |

#### Comments

1. 🛑 OpenCode + OpenRouter: does currently not work in Zed at all, whether with free or paid models. Seems to be a known issue with OpenRouter, which does not even work in the Zed agent (without ACP).
2. ℹ️ OpenCode + DeepInfra: The model list is outdated because DeepInfra updates its available models rapidly, while OpenCode relies on models.dev. Solution: add a opencode.json file in ~/.config/opencode/ and define some desired but missing models in there. Prefix their names with "di-custom: " or so to make them discoverable. Backup/example: [opencode.json](opencode/opencode.json). (Related GitHub issue: [#6231](https://github.com/anomalyco/opencode/issues/6231))
3. 🛑 Cursor CLI + Cursor free tier: ACP is [explicitly not offered on the free tier](https://cursor.com/blog/jetbrains-acp).
4. ℹ️ Cursor CLI + Cursor paid subscription: Works comparatively well. Good ACP integration (tested with Sonnet 4.5 and 4.6).
5. ℹ️ Gemini CLI: Tuning model params (temperature etc.) can impact agentic performance. My setup is documented [here](gemini/README.md). I could not fully verify that the custom config is also loaded in Zed via ACP, but it is strongly indicated.
6. ❓ I have not yet tested Claude Code via ACP in Zed, only stand-alone Claude Code.
7. ⚠️ Cursor CLI + Cursor free tier (TUI): Possible but rate limits are tight enough to possibly be annoying -> has to be used for short tasks only. And only would works via TUI anyway.
8. 🛑 Cursor CLI + Cursor paid subscription:
    - Bound to subscription as in BYOK is no option.
    - Can't compete with the whole package that Anthropic subscription would offer (agent, cowork, chatbot, native mac app ...)
    - above all: subscription gives NO benefit when selecting specific model (instead of using Auto). With model selection they effectively charge api rate plus fee (giving 20 bucks credit on a 20 bucks sub). but we wanna know what model we get, so cursor sub is worthless.
9. 🛑 OpenCode + OpenCode Zen: technically possible but can't compete with DeepInfra on price while offering no performance advantage.
10. Amp: ACP registry install does NOT provide full agent (in contrast to other registry installs). But native Amp in TUI can be set up to see current IDE context.

**Every ACP Agent:**
* ⚠️ Basic thread management functions like "resuming threads from history" do not even work with "the reference ACP implementation" (Gemini CLI). This also means Zed offers no way to edit the agent's thread history (if it is even created) -> delete OpenCode threads by deleting `~/.local/share/opencode/opencode.db*`. Apply an equivalent solution with other agents.

### OpenCode Agent in OpenCode Desktop App

Mainly for the combinations that showed technical issues in Zed. But the OpenCode agent was generally not as reliable via ACP in Zed, so the OpenCode desktop app could be a fallback.

| Provider | free/paid | Works? | Viable? |
| --- | --- | --- | --- |
| OpenRouter | free models |  |  |
| DeepInfra | API key |  |  |
| xAI | API key |  |  |
| OpenRouter | paid models (+5.5% fee) |  |  |
| OpenCode Zen | paid models (+6.15% fee) |  |  |
