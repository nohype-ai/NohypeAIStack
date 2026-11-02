# Agent Isolation For Data Protection

This document describes how to protect sensitive data when working with agents. 

## Levels of True Isolation

- **The agent's own system of hard-enforced permissions**
	- Documented for Grok in [Grok Build Permission System](Grok%20Build%20Permission%20System.md)
	- Grok's kernel sandbox is that hard layer. ACP stdio applies `[sandbox]` before managed account config, which blocks every ACP client. The stored config therefore leaves the sandbox off. Remaining deny rules are a named-path filter on matching tool calls. Isolation for Grok is the three levels below.
- **Locked (partially encrypted) repo clone for the agent**
	- just never run transcrypt there
	- keeps the encryption password out of the agent’s `.git/config`
	- Documented in [Encrypting Repos](../../../cross-platform/git/Encrypting%20Repos.md)
- **Dedicated scoped GitHub PAT for the agent**
	- allows finer grained control over what repos agents can read/write, without giving them  their own GitHub user
- **Dedicated unix user for the agent**
	- helps if that user has nothing worth stealing: anything it can read, it can send to the model
	- it's a great baseline, it can't read anything from the actual human user (SSH keys for example), only what was set up in the agent user
	- Zed/ACP can launch the agent process as that agent user. The editor/IDE stays as the human user.

## Implications for GitHub

Two modes:

1. **Agent never talks to GitHub.** Zero credentials on the agent user. You pull/push. This is the only way to not leak any GH credential.
2. **Agent uses GitHub, commits appear as you.**
	1. Account SSH keys (unscoped). A key on your GitHub account reaches every repo that account can.
	2. Fine-grained PAT on your account, scoped to the repos you want.

Discarded:

- Deploy keys: scoped, but one per repo
- Separate GitHub user: scopes SSH to the repos you add it to, but commit author is that user (agent)

The PAT is still exfiltratable. Scoping limits blast radius; it does not stop the leak.

## Remaining risk

The unix user puts your home, SSH keys, transcrypt password, and other repos out of reach. That is the win. It does not make a remote model safe. It just stops the agent from reaching *you*. ACP Grok sessions run as that unix user, so this boundary is the process-level stop.

What is still exposed:
- Plaintext of the repos it can read, with or without PAT. Repo content is going to the model anyway — that is inherent in using a remote coding agent.
- The PAT itself if used. Same leak as with SSH keys and transcrypt passwords, but smaller blast radius. A stolen PAT acts as you on those repos until you revoke it.

## Evaluation of Remaining Risk

**Acceptable** when those repos are ones you would send to a remote model anyway, and the PAT is treated as disposable: least privilege, short expiry, easy to revoke.

**Not acceptable** for unrekeyable secrets or data that must not leave the machine. That data must stay encrypted in the agent's repo clone or simply out of every repo the PAT can access. Because PAT scope does nothing for the data the agent can read as plaintext.

## Other Mechanisms

### Dedicated virtual or real machine

- ❌ It adds little on top of a unix user, and it costs effort to set up and operate, costs system resources if not on dedicated hardware
- ✅ it could make some aspects easier, since it's cleaner practical separation (not necessarily better isolation with regards to data protection)
	- the human user can not forget to run agent processes as the agent user
	- personal agents (in contrast to coding agents) and agents that run long times and are highly autonomous benefit from hardware that doesn't get shut down

### Kernel process sandbox

The kernel limits one process below what its unix account allows. Files use Landlock on Linux and Seatbelt on macOS. Network is a separate restriction and is not always included. This works without a dedicated unix user.

If the agent user only holds repos you would send to the model anyway, the file limit adds nothing against leaks. The process can still send what that user is allowed to read. A sandbox can still add two things the unix user does not: blocking that process's network, and keeping one session out of other repos or credentials in the same home.

Grok Build is one example. `strict` limits the session to the launch directory plus `~/.grok`, and on Linux it blocks child-process network (`curl`). On macOS the network block does nothing. `grok agent stdio` applies `[sandbox]` from `~/.grok/config.toml` before managed account config loads. Putting `strict` there blocks ACP clients (Zed, Obsidian Agent Client). Daily Grok use here is ACP, so the stored config omits `[sandbox]` and the kernel fence is unused. Permission deny rules still scan matching tool calls.

- ❌ ACP stdio is how Grok is launched, and that path leaves the sandbox off. A TUI-only `strict` profile would still be per process, complex to keep, and not worth those two extras on top of a unix user.

### Local inference

The sensitive step runs on a model on this machine, so that data never goes to a remote model. Local models lag the remote ones.

- ❌ Requires expensive hardware and operations

### Egress allowlist

A firewall rule, written as root, names the agent user and limits where that user's traffic can go. On Omarchy, nftables can allow that user the model API and DNS and drop the rest. The list is addresses, so it has to be maintained, IPv6 included. macOS has no built-in switch for this. Little Snitch and Lulu filter by application, so one rule covers every user of the same binary. The model host stays allowed, so the repo still goes to the model. The rule stops that user from sending data anywhere else.

- ❌ Covers network traffic only, and the rule list requires maintenance