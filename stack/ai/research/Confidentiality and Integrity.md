# Confidentiality and Integrity with Agents

Even from a super pragmatic, risk-taking, fast-moving perspective, we have to deal with the major risks in at least some minimal way, before letting agents take over. For any sort of client work, this requirement is even stricter.

For the baseline use case of leveraging AI to 10x or 100x a knowledge worker's or client's productivity, data confidentiality and data integrity are far more critical than agent-/data availability, given also that 99% of availability comes for free anyway. So the basic major risks are in compromised data confidentiality and compromised data integrity.

> Note: There is the 3rd risk of super low quality, and that can be destructive too, like when an agent sends a wrong email or spends too much money. But such performance issues are covered by other research topics and are sort of the obvious central limiting factor for scaling agent work up in the first place.

## Confidentiality Risk/Solution Brainstorm

Risk: The agent scans local context and scoops up sensitive data, and then sends it over the wire, either to remote models as part of their context or to web service as part of their input. Control on confidentiality is lost, even credentials can leak.

Note that this does not require agents to be "evil" but is just a likely effect of how they work. The local preprocessing that agents do is typically not even intelligent but based on deterministic dumb algorithms.

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
