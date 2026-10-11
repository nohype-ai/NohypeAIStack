# Agent Isolation For Data Protection

This document describes how to protect sensitive data when working with agents. 

## Levels of True Isolation

- **The agent's own system of hard-enforced permissions**
	- Example: [Grok Build Permission System](Grok%20Build%20Permission%20System.md)
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

The unix user puts your home, SSH keys, transcrypt password, and other repos out of reach. That is the win. It does not make a remote model safe. It just stops the agent from reaching *you*.

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

Grok Build is one example. Its sandbox profile is off unless you turn it on. `strict` blocks network in commands such as `curl` on Linux. On macOS that block does nothing. It limits the session to the launch directory, plus `~/.grok`.

- ❌ Per process, so the setup is complex to maintain and easy to forget. Those two extras are not worth that on top of a unix user.

### Local inference

The sensitive step runs on a model on this machine, so that data never goes to a remote model. Local models lag the remote ones.

- ❌ Requires expensive hardware and operations

### Egress allowlist

A firewall rule, written as root, names the agent user and limits where that user's traffic can go. On Omarchy, nftables can allow that user the model API and DNS and drop the rest. The list is addresses, so it has to be maintained, IPv6 included. macOS has no built-in switch for this. Little Snitch and Lulu filter by application, so one rule covers every user of the same binary. The model host stays allowed, so the repo still goes to the model. The rule stops that user from sending data anywhere else.

- ❌ Covers network traffic only, and the rule list requires maintenance