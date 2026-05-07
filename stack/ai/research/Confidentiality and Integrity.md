# Confidentiality and Integrity with Agents

Context: We target a setup where AI is applied to all knowledge work, so sensitive personal/company/client data lives in the same git-managed substrate as code. Loose practices that seem to work for code-only repos clearly do not work for this generalized use case.

So even from a super pragmatic, risk-taking, fast-moving perspective, we have to deal with the major risks in at least some minimal way, before letting agents take over. For any sort of client work, this requirement is even stricter.

Our baseline use case is leveraging AI to 10x or 100x a knowledge worker's or client's productivity. Here, data confidentiality and data integrity are far more critical than agent-/data availability, given also that 99% of availability comes for free anyway. So the basic major risks are in compromised data confidentiality and compromised data integrity.

> Note: There is the 3rd risk of super low quality, and that can be destructive too, like when an agent sends a wrong email or spends too much money. But such performance issues are covered by other research topics and are sort of the obvious central limiting factor for scaling up agent work in the first place.

Most loud productivity claims operate in a regime where these risks are minimal (own code, vendor no-train defaults, no client data); for sensitive data and serious client work the same practices break down.

## Confidentiality Risk/Solution Brainstorm

Risk: The agent scans local context scooping up sensitive data, and then sends that data over the wire, either to remote models as part of their context or to web service as part of their input. Control on confidentiality is lost, even credentials can leak.

> Note that this does not require agents to be "evil" but is just a likely effect of how they work.
> 
> The local preprocessing that agents do is typically not even intelligent but based on deterministic dumb algorithms. The actual agent itself has no brain of its own. It does not understand when some local data is a password, it just sends the password out to its remote brain.
> 
> At the point where intelligence finally kicks it's already too late, because that intelligence sits anywhere on the planet, is not in your control and is subject to the competence of countless other people as well as who knows which laws and regulations (that might enforce back doors, government access, retention obligations etc.).

Specific examples of affected sensitive data together with solution ideas:
- credentials and other secrets in `~/`, for example in `~/ssh/`
	- ❓maybe reduced by using dedicated macOS user for running agents
	- ❓ maybe avoided on an agent-specific level using the agent's ignore file (like `.cursorignore`)
- encryption password in unlocked repository that uses `transcrypt`
	- ✅ don't freaking do that. never unlock the main working copy you work on. use a dedicated separate unlocked working copy for managing sensitive data. 
	- ❓ better even run agent with dedicated macOS user to make it impossible for the agent to read the unlocked working copy.
	- ❓ maybe avoided on an agent-specific level by using the agent's ignore file (like `.cursorignore`)
- plaintext sensitive data in project folder
	- ✅ don't freaking do that. use encryption for sensitive data.
	- ❓ or use some form of anonymization
- encrypted but temporarily unlocked sensitive data (unlocked like is possible with `transcrypt`)
	- ✅ don't freaking do that. never unlock the main working copy you work on. use a dedicated separate unlocked working copy for managing sensitive data. 
	- ❓ better even run agent with dedicated macOS user to make it impossible for the agent to read the unlocked working copy.
- sensitive data outside project folder since agents can generally access everything the user can access who runs them
	- ❓maybe reduced by using dedicated macOS user for running agents
	- ❓ maybe reduced on an agent-specific level by using the agent's ignore file (like `.cursorignore`)

## Integrity Risk/Solution Brainstorm

Risk: agent damages or destroys data or code by editing or deleting it without the user's awareness

Specific examples of affected data locations together with solution ideas:
- within project folder
	- ✅ easily avoided by using git
- outside project folder on the user's system
	- ❓maybe reduced by using dedicated macOS user for running agents
	- ❓ maybe reduced on an agent-specific level by using the agent's ignore file (like `.cursorignore`)
	- ❓ risk of data loss may be partially reduced by regular backup of critical data

## Levels of Agent Isolation

Solving confidentiality and integrity is about controlling the boundaries between agent, your data, and the web.

- **tasks**: Isolating critical from less critical tasks is the most basic and effective level of isolation. This comes down to "human in the loop" variants. For example: only the human has access to credentials and must get involved when it comes to pushing and pulling a repo. 
- **agent customization**: Part of the confidentiality/integrity story is understanding, monitoring and controlling the agent's environment, including its tools, rules and ignore files. so one level is just [general ai research topics](to%20do.md) like agent customization and agent environment.
	- → ❗ agent ignore files could be the next major low hanging fruit for confidentiality and integrity. I need to explore that for cursor, opencode, gemeini cli and claude code, and add an overview here or in the agent customization overview ...
- **network connection control**: firewalls, allowlist proxies, a dedicated network namespace, network monitors, DNS-level filtering etc. are ways to let the agent use the web but to control that usage.
- **git working trees**: less about confidentiality or integrity and more about letting multiple agents work in parallel on the same repo.
- **Process-level sandboxes**: macOS `sandbox-exec` / App Sandbox profiles, Linux namespaces, or the agent CLI's own sandbox (Cursor CLI sandbox mode, Claude Code permissions). Often more practical than spinning up a whole macOS user, and gives per-process FS/network rules.
- **macOS users**: user management is the natural level on which to manage access. agents by their unpredictable autonomous nature are effectively distinct users and should be treated as such, running them in their own user space.
  - → Separate keychain / SSH keys / `gh auth` / fine-grained GitHub PATs / per-repo deploy keys / short-lived cloud creds for the agent user
- **macOS instances**: Docker and VMs allow spinning up dedicated macOS instances for the agent user without needing a dedicated actual machine.
	- ❓ this obviously increases isolation, although practical benefits for confidentiality and integrity are unclear to me right now.
- **macOS machines**: a dedicated agent user can also run on its own dedicated machine.
	- ❓ this obviously increases isolation even further, although practical benefits for confidentiality and integrity are unclear to me right now.
- **local inference**: cutting the agentic system off from the web, or at least avoiding remote inference, is the big hammer that solves basically all confidentiality concerns in one fell swoop. all other confidentiality solutions are ultimately complex fragile workarounds in comparison.

## What Isolation Levels Do 10x Practitioners Use?

> My impression: Most who boast 10x - 100x productivity are not even aware of the risks laid out in this document. Their actual practice is surprisingly thin. I can hardly consider them professionals. Becoming professional at leveraging AI is the whole point of our research here.

### Conversation with Opus 4.7

---

> Prompt: what levels do people who boast about having 100x productivity mostly use? my impression is that most who are indeed very productive are surprisingly not even aware of the risks i laid out in this little file here.

---

From what's visible in the loud "100x productivity" crowd (Twitter/X, YouTube, Discord, blogs), the actual practice is surprisingly thin. Roughly in descending order of prevalence:

**What they actually use:**
1. **Vendor TOS as their entire confidentiality strategy.** "Cursor/Anthropic/OpenAI says they don't train on my data" → done. No further controls.
2. **Git.** Universal. Covers integrity within the project folder, which is in practice ~all the integrity they care about.
3. **Same machine, same user, frontier cloud models.** Cursor or Claude Code or Codex running as their normal `$USER` with full home-directory access, hitting Anthropic/OpenAI APIs.
4. **Ignore files** (`.cursorignore`, `.claudeignore`) — used sporadically, often incompletely, often forgotten.
5. **YOLO / auto-approve modes.** Many explicitly disable per-command approval because it slows them down. The "100x" number basically requires this.
6. **Git worktrees / branches** for parallel agents — increasingly common among power users.
7. **Dev containers / Docker** — used by maybe a vocal minority (the Anthropic-recommended Claude Code devcontainer setup is the most visible example). Gives them some sandboxing almost by accident.

**What they almost never use:**
- Dedicated macOS user for agents
- Egress firewalls / allowlist proxies
- VMs or dedicated machines
- Local inference (niche; frontier models are still too far ahead for hardcore agentic work)
- `sandbox-exec` profiles or any custom process-level sandboxing
- Scoped credentials / per-agent keychains

**Why they get away with it:**
- They're mostly working on **their own code**, often open-source or low-sensitivity SaaS. The blast radius of a leak is small.
- The data they consider "sensitive" (a `.env` with API keys) is *also* sensitive to them long before agents existed, and their existing habits roughly cover it.
- Catastrophic incidents are rare *and underreported* — when it does go wrong, people don't tweet about it.
- Vendor "no-train" defaults have genuinely de-risked the most obvious leak vector.
- Frontier models are good enough that the agent rarely does something truly destructive that git can't undo.

**Why this matters for your framing:**

The "100x crowd" lives in a regime where confidentiality and integrity are mostly free side-effects of (a) git and (b) vendors' no-train policies. Your file is aimed at a fundamentally different regime: **client work, mixed sensitive data, multi-tenant context.** There, the same loose practices stop being safe — and that's exactly the gap most loud productivity claims silently paper over.

---

> Prompt: i do not fully understand how almost everyone lives with the vendor promises and ignores regular web search. i had debugging sessions where agents poked around in my home folder or repo git config like it's any public website. the local agent could easily embed even passwords and private ssh keys in the context it sends to its remote model. am i the paranoid one here? how is this suddenly thrown aside after decades of meticulously evolving our security practices? agents collide with the traditional OS user management as they are effectively distinct users whom we still treat like any old app. why even set a password for our own macOS user if you log in and then hand everything over to another (even if artificial) user?

---

You're not the paranoid one. Your analysis is technically correct, and the deeper point you're making — that agents break the OS user model — is exactly right and underappreciated.

**You're right on the facts:**
- An agent running as your `$USER` has, by definition, the same access as you. It *can* read `~/.ssh/`, browser cookies, an unlocked Keychain, password-manager databases, `.env` files, `.git/config` with embedded tokens — anything you can read.
- Agents *do* poke around, not because they're malicious but because that's how they work: file globbing, reading configs to "understand the project," following references. The local→remote pipeline is real and largely invisible to the user.
- Your observation about the macOS login password is the punchline of the whole problem. The password gates "is this principal *me*?" — and then we hand everything to a process that emphatically isn't you.

**Why the industry mostly shrugs at this — several reinforcing reasons:**

1. **OS user model is the wrong abstraction, but it's the only one anyone has.** Decades of security practice are built around *identity-based* permissions (this is user X, this is user Y). What agents actually need is *capability-based* permissions (this process has *these specific* capabilities). iOS, Android, browsers all solved this internally with sandboxes — but desktop OSes never did, because dev tools historically needed broad access. So when an agent shows up, the *only* policy lever available is "give it everything the user has." The user-level boundary you're pointing at simply doesn't exist as a usable mechanism for this case yet.

2. **Asymmetry of evidence.** Productivity wins are loud, individual, and tweetable. Security incidents are quiet, legally suppressed (NDAs, insurance, settlements), and almost always attributed downstream — "misconfigured token," "phishing," "engineer error" — rather than "agent embedded a credential in remote context." So the public record looks like all upside.

3. **Trust-in-vendor as substitute for technical control.** "Anthropic/OpenAI/Cursor say they don't train on it" is doing all the work that process isolation, egress control, and least-privilege should be doing. It's a single contractual layer replacing decades of defense-in-depth.

4. **Motivated reasoning.** When a tool gives you 3-5x speedup *today*, the brain finds reasons to discount risks that *might* materialize later. This is the same psychology behind `curl | sudo bash`, public S3 buckets in 2012, npm-install-anything, and "just use admin for everything" Windows in the 2000s. Every era has this pattern.

5. **Dev-box exceptionalism.** Many devs treat their machine as semi-disposable, rebuildable, "just code." That logic *kind of* works when the box only has open-source code. It breaks the second client data, customer DB dumps, encryption keys, or business secrets share the same `$HOME`. Most "100x" people are quietly in the first regime, even if they don't articulate it.

6. **Historical precedent.** Every security regression like this has eventually been corrected — but only after incidents accumulated:
   - Plaintext internet → TLS everywhere (took 20 years)
   - Mobile apps with full access → iOS/Android sandboxing (took ~5 years post-iPhone)
   - Public S3 buckets → "block public access" defaults (took ~10 years and many breaches)
   - Browser plugins with full DOM access → site isolation, manifest v3
   
   Agent isolation will follow the same arc. We're in roughly the "2010 cloud security" phase: the tooling exists in primitive form (Cursor's sandbox mode, Claude Code's permissions, MCP scopes, devcontainers), but defaults are wide-open and the discourse hasn't caught up.

**So: you're not paranoid, you're early.** The industry has temporarily suspended its security instincts because the productivity payoff is genuine and the costs are quiet. That suspension is unstable — it'll correct as incidents accumulate, especially around client work, where one leaked credential causes real legal/financial pain. Building isolation thinking into your stack now is exactly the right move for the regime you're targeting (client work, sensitive data), even though it'll feel out of step with the loud crowd for another year or two.

The one nuance I'd add: don't frame it as "everyone else is wrong." Frame it as "they're optimizing for a different regime (own code, low sensitivity, vendor-trust as the security model) — which is fine for them but doesn't transfer to client work." That keeps the document pragmatic rather than preachy.

---

> Prompt: i think my standard is also a consequence of how radically i want to leverage AI. i want to be able to use AI for all knowledge work and not just coding, and i want to leverage the capabilities of coding agents to incorporate local context. so i am on a mission to bring all my documents and company data into markdown form and git management so i can work on it wit coding agents. this however means i have my own sensitive data mixed into the "codebase" and must solve for that. others do not apply AI so consistently (or radically), which is why they do not have to solve the challenge that brings. But i already felt the huge payoff, so it's time to solve this setup in principle for all such repos.

---

That framing nails it — and it actually clarifies *why* this file exists in a way the file itself doesn't currently make explicit.

The dev-tool industry built coding agents assuming the corpus is "code, plus maybe a `.env`." Loose isolation works there because the sensitivity gradient inside the repo is basically flat and low. What you're doing is fundamentally different: you're using coding-agent infrastructure as a **general knowledge-work substrate**, which means your "codebase" mixes:

- public / shareable docs
- company-internal strategy
- client work (with implicit confidentiality obligations)
- personal notes, financials, decisions
- and possibly credentials/secrets adjacent to all of the above

The agents weren't designed for that mix — they assume one sensitivity tier. You're stacking multiple tiers in one substrate, which is why the standard "trust the vendor + use git" recipe stops working for you specifically.

A couple of implications that fall out of this framing:

1. **Architecturally, the unit of isolation is the repo, not the file.** Trying to mark individual files as sensitive within a mixed repo is fragile (ignore files, anonymization, etc. all leak). The cleaner pattern is **tiered repos** — e.g. `public/`, `company/`, `client-X/`, `vault/` — each with its own agent profile, ignore rules, possibly its own model provider, possibly its own macOS user. The file's current bullets (working trees, users, instances) become *tools to express tiers*, not standalone solutions.

2. **The ROI math is also different.** When AI applies to *all* knowledge work, even modest per-task gains compound across your whole working life — which justifies a much higher upfront investment in the isolation setup than someone using AI only for code would rationally make. So you're not over-engineering; you're amortizing.

3. **This is also a genuinely novel-ish problem.** "Multi-tier sensitive corpus accessed by autonomous agents" isn't a solved pattern in the public discourse yet. So expect to invent some of this rather than copy it.
