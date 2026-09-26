# Agent Isolation

## Takeaway

True isolation is:
- **Locked (encrypted) repo clone for the agent** (never run transcrypt there) keeps the encryption password out of the agent’s `.git/config`.
- **Dedicated unix user for the agent** helps if it has nothing worth stealing: anything it can read, it can send to the model. But it's a great baseline, it can't read anything from the actual human user (SSH keys for example), only what was set up in the agent user.
	- Zed/ACP can launch the agent process as that agent user. The editor/IDE stays as the human user.
- [Optional] **Dedicated scoped GitHub PAT for the agent**

Docker was rejected as too much.

### Implications for GitHub

Two modes:

1. **Agent never talks to GitHub.** Zero credentials on the agent user. You pull/push. This is the only way to not leak any GH credential.
2. **Agent uses GitHub, commits appear as you.** Fine-grained PAT on your account, scoped to the repos you want.

Discarded:

- Account SSH keys — unscoped; a key on your GitHub account reaches every repo that account can.
- Deploy keys — scoped, but one per repo.
- Separate GitHub user — scopes SSH to the repos you add it to, but commit author is that user.

The PAT is still exfiltratable. Scoping limits blast radius; it does not stop the leak.

### Remaining risk

The unix user puts your home, SSH keys, transcrypt password, and other repos out of reach. That is the win. It does not make a remote model safe. It just stops the agent from reaching *you*.

What is still exposed:
- Plaintext of the repos it can read, with or without PAT. Repo content is going to the model anyway — that is inherent in using a remote coding agent.
- The PAT itself if used. Same leak as with SSH keys and transcrypt passwords, but smaller blast radius. A stolen PAT acts as you on those repos until you revoke it.

### Evaluation of Remaining Risk

**Acceptable** when those repos are ones you would send to a remote model anyway, and the PAT is treated as disposable: least privilege, short expiry, easy to revoke.

**Not acceptable** for unrekeyable secrets or data that must not leave the machine. That must stay encrypted or out of the PAT scope.

---
## Original Conversation

**Date:** 2026-05-05 06:42:31
**ID:** 00cbe425-3d29-4f75-a41b-254a12fd90b4

---
### User

I use transcrypt to encrypt sensitive parts of my repo. When the repo is unlocked the password locates plainly in .git/config. This is problematic when using ai coding agents on the repo since they could read the password into their context and send it out to the remote models, which I find problematic. When the repo is locked the problem doesn't exist. But locking and unlocking take time. So i guess the cleanest solution would be to give the agents their own checkout of the repo that remains locked locally (encrypted). What is generally the best technique to achieve some separation? Separate repo folders? Separate worktrees? Separate macOS users? Separate machines? Or simply just using agent ignore files like .cursorignore?

---

### Grok (grok-420-computer-use-sa)

**Separate dedicated clone (a second repo folder) kept permanently locked is the cleanest, most practical solution.**

### Why this wins
- The agent clone never runs `transcrypt -c ... -p ...`, so **no password ever appears in its `.git/config`**.
- Encrypted files stay as ciphertext in the working tree (graceful degradation built into Transcrypt). Agents see unreadable blobs for sensitive files and can only usefully edit non-encrypted ones.
- Plain files work completely normally for git operations (commit, push, pull, etc.).
- You keep your main clone unlocked for daily work. Sync is just normal `git pull`/`git push` to the shared remote — no repeated lock/unlock cycles.
- Fully isolated `.git/` directories, so no shared config leakage.

This directly solves the exact problem you described without the overhead of user switching or extra machines.

### Comparison of your options

| Option                  | Password Isolation | Encrypted Files Stay Encrypted | Overhead | Best For                  | Verdict |
|-------------------------|--------------------|--------------------------------|----------|---------------------------|---------|
| **Separate clone/folder** | Excellent         | Yes (by design)               | Low     | Daily AI agent use       | **Winner** |
| Separate worktrees      | Poor (shared config by default) | Only if base is locked       | Very low | Parallel agents on *locked* base | Good supplement |
| macOS separate users    | Excellent         | Yes                           | High    | Extreme paranoia         | Overkill |
| Separate machines/VM    | Nuclear           | Yes                           | Highest | High-security envs       | Only if needed |
| `.cursorignore` alone   | Good (context only) | No (if unlocked)              | None    | Quick extra layer        | Use *with* clone |

**Worktrees note**: Great for parallel agents (one branch per agent), but only safe if you run them *inside* the locked agent clone. On your unlocked main clone they inherit the password via shared config.

### Recommended setup (minimal friction)

1. **Main (you)**: Normal unlocked clone. Use `transcrypt --flush-credentials` when you're not actively touching encrypted files.

2. **Agent clone** (one-time):
   ```bash
   git clone <your-repo-url> /path/to/agent-repo
   # Do NOT run any transcrypt command here
   ```

3. **Add `.cursorignore`** (or equivalent for your agent tool) in the agent folder:
   ```
   .git/
   # Add any other paths you want to be extra sure about
   ```

4. Point Cursor / your AI tool at `/path/to/agent-repo`. Done.

### Extra hardening (optional but cheap)
- Put the agent clone on a different filesystem mount or in a container/VM if the repo contains *extremely* sensitive material.
- For multiple simultaneous agents: Use one locked base clone + `git worktree add` inside it (each agent gets its own directory + branch, zero extra object duplication).
- Keep `transcrypt --flush-credentials` as your muscle memory on the main clone.

This pattern is used by people who run AI agents against repos with secrets. It gives you the separation you want with almost zero ongoing cost. Separate clones are the sweet spot between security and convenience here.

---

### User

Related question: not sure this was always the case but recently i was often delighted and creeped out simultaneously that agents are able to read files from outside the project- or repo folder they were launched in. I was previously assuming they would be sandboxed in this file system sense that they could only read (let alone write) inside the project, but both is not the case. They can read and write on the whole system. How can i generally limit them ro the project folder, for example using cursor agent, opencode and gemini cli?

---

### Grok (grok-420-computer-use-sa)

**Yes, this is a very common (and valid) concern.** Most AI coding agents default to broad filesystem access because they’re designed for convenience, not strict isolation. They can read/write almost anywhere your user account can — including `~/.ssh`, `~/.aws`, `~`, `/tmp`, etc. — unless you explicitly restrict them.

Here’s how to limit them to the **project folder only**, ranked from strongest to quickest:

### 1. Strongest & Most Reliable: Docker (works for all tools)
Run the agent inside a container that only sees your project directory.

```bash
# Example for any agent
docker run -it --rm \
  -v /absolute/path/to/your/project:/workspace \
  -w /workspace \
  your-agent-image
```

- Only the project is mounted — everything else is invisible.
- Add `--user $(id -u):$(id -g)` for same permissions.
- For Cursor/OpenCode/Gemini, you can even wrap the CLI commands this way.
- Bonus: Combine with your locked Transcrypt clone inside the container.

This is the cleanest general solution.

### 2. Tool-Specific Controls

**Gemini CLI** (best built-in sandbox)
- It has **native sandboxing** enabled by default (uses `sandbox-exec` on macOS).
- Starts restricted to the current project directory.
- Run with: `gemini -s` or `gemini --sandbox`
- Customize extra mounts only if needed via `SANDBOX_MOUNTS` env var.
- Very good out of the box — start the CLI from inside your project folder.

**Cursor Agent**
- No hard “project-only” wall by default (agents can read outside files via tools or shell).
- **Best mitigations**:
  - Create `.cursorignore` in project root with aggressive patterns:
    ```
    ../**
    ~/**
    /Users/**
    /private/**
    .git/
    ```
  - Enable **“Run in Sandbox”** (Cursor 2.0+) for terminal commands — uses macOS Seatbelt and heavily restricts writes outside workspace + /tmp.
  - Keep terminal commands on manual approval (don’t enable “Run Everything”).
  - Use Workspace Trust + Restricted Mode when opening new folders.
- Still not perfect for reads — many users complain about this exact issue.

**OpenCode** (or similar open coding agents)
- Usually has minimal built-in restrictions.
- Check `~/.config/opencode/opencode.json` (or similar) for safety plugins / tool restrictions.
- Best approach: Wrap it in Docker (see #1) or run via a dedicated restricted user.

### 3. OS-Level Sandboxing (macOS — very effective)
Since you’re on macOS:

- **Dedicated low-privilege user**:
  1. Create a new user (System Settings → Users & Groups) with minimal rights.
  2. Give that user access *only* to your project folder (`chmod` + `chown`).
  3. Run Cursor / OpenCode / Gemini CLI as that user (via Fast User Switching or `su` / launchd).

- Manual `sandbox-exec` (Seatbelt) for specific commands — Cursor already uses this internally in sandbox mode.

### Quick Daily Habits
- Always open/launch the agent **from inside the project folder**.
- Use `.cursorignore` (or equivalent) aggressively.
- Keep approval prompts on for terminal/file writes.
- For maximum paranoia: Combine **Docker + locked separate clone** (from previous answer) + dedicated user.

**Recommended stack for you** (given your Transcrypt + security concerns):
1. Separate locked clone for agents (no password in `.git/config`).
2. Run agents inside Docker mounted only to that clone.
3. Or use Gemini CLI (strongest native sandbox) when possible.

Would you like concrete Docker examples or `.cursorignore` templates tailored to your setup?

---

### User

Docker too much. Tell me how to use a "Dedicated low-privilege user" to run the agents. In particular, i run the agents from within Zed via ACP. Is it still possible to have the agents run in a dedicated macOS user?

---

### Grok (grok-420-computer-use-sa)

**Yes — this works well**, especially with Zed + ACP.

Zed launches **external agents** (Claude, Gemini CLI, OpenCode, etc.) as **separate processes** via the Agent Client Protocol (ACP). This means you don’t need to run the entire Zed editor as another user — you only need to run the *agent processes* as the low-privilege user.

### Step-by-step: Dedicated low-privilege user on macOS

1. **Create the dedicated user**
   - Go to **System Settings → Users & Groups → Add User**.
   - Choose **Standard** user (not Administrator).
   - Name it something like `agent` or `coding-agent`.
   - Give it a password.

2. **Give it access only to your project (and locked clone)**
   ```bash
   # Best option: change ownership of your project folder
   sudo chown -R agent:staff /path/to/your/project

   # Or use ACLs for more control (keeps your main user as owner)
   sudo chmod -R +a "agent allow read,write,execute" /path/to/your/project
   ```

   The `agent` user will now only be able to read/write inside that folder (and its own home directory). Everything else (`~/.ssh`, `~`, system files, etc.) will be inaccessible.

3. **Configure Zed to run agents as this user**

   In Zed settings (`Cmd+,` → search for "agent" or edit `settings.json`):

   For external ACP agents, set the command with a prefix. Example for Gemini CLI:

   ```json
   {
     "agent": {
       "external": {
         "gemini": {
           "command": "sudo -u agent /opt/homebrew/bin/gemini",
           "args": ["-s"]   // or whatever flags you use
         }
       }
     }
   }
   ```

   Same pattern for OpenCode, Claude via ACP, or any other agent:
   - Use `sudo -u agent /full/path/to/agent-binary ...`

   You can also create a small wrapper script (`/usr/local/bin/agent-gemini`) that does the `sudo -u agent ...` and point Zed to that instead.

4. **Test it**
   - Restart Zed or reload settings.
   - Start an agent session.
   - In Terminal (as your main user) run `ps aux | grep agent` — you should see the process running as the `agent` user.
   - Try to make the agent read `~/.ssh/id_rsa` or a file outside the project — it should fail with permission denied.

### Extra tips for your Transcrypt setup

- Put your **locked clone** inside the project folder (or make the locked clone owned by `agent`).
- The agent user will see encrypted files as ciphertext and have no password in its `.git/config`.
- Give the `agent` user its own minimal home directory — it won’t have your SSH keys, AWS creds, etc.

### Caveats

- You’ll need to enter your password (or set up passwordless `sudo` for that specific command via `/etc/sudoers` — use with care).
- Some agents may need occasional extra permissions (e.g., for git push). You can temporarily grant them via ACLs.
- GUI apps (Zed itself) are annoying to run as another user — but you don’t need to, thanks to ACP.

This gives you real OS-level isolation without Docker. It’s one of the cleanest lightweight options on macOS.

Want a ready-to-use wrapper script example or the exact `sudoers` line for passwordless execution?

---

### User

Explain how i give the agent user the ability to push and pull without giving it my git credentials (like ssh keys in its ssh config).

---

### Grok (grok-420-computer-use-sa)

**Best solution: Use a Git Deploy Key (SSH)**

This is the cleanest way. The agent user gets its own SSH key that only has access to *this specific repository*. Your personal SSH keys stay completely untouched and invisible to the agent user.

### Step-by-step setup

1. **Switch to the agent user and generate a dedicated key**
   ```bash
   sudo -u agent -i
   ssh-keygen -t ed25519 -C "agent-user@your-repo" -f ~/.ssh/id_ed25519_agent
   # Leave passphrase empty (or set one and use ssh-agent later)
   cat ~/.ssh/id_ed25519_agent.pub
   ```

2. **Add the public key as a Deploy Key on your Git host**
   - **GitHub**: Repo → Settings → Deploy keys → Add deploy key
     - Paste the public key
     - Check **"Allow write access"** (so it can push)
   - **GitLab**: Repo → Settings → Repository → Deploy keys → Add key (enable write access)
   - **Other hosts**: Look for “Deploy keys” or “Machine keys”

   This key can **only** access this one repository — nothing else.

3. **Configure the agent user’s SSH to use this key**
   ```bash
   # Still as the agent user
   cat >> ~/.ssh/config <<EOF
   Host github.com
       HostName github.com
       User git
       IdentityFile ~/.ssh/id_ed25519_agent
       IdentitiesOnly yes
   EOF
   ```

4. **Update the remote in your locked clone (as the agent user)**
   ```bash
   cd /path/to/locked-clone
   git remote set-url origin git@github.com:your-org/your-repo.git
   ```

5. **Test it**
   ```bash
   git pull
   git push
   ```

   It should work without ever touching your personal SSH keys.

### Alternative (if you prefer HTTPS)

Create a **fine-grained Personal Access Token (PAT)** with minimal permissions:

- Only this repository
- Only `Contents: Read & Write` (and `Metadata: Read` if needed)
- No other scopes

Then store it in the agent user’s git credential helper:

```bash
sudo -u agent git config --global credential.helper osxkeychain   # or store
```

When the agent first pushes/pulls, it will prompt for the token once and save it.

### Recommendation

Use the **Deploy Key (SSH)** method — it’s more secure and isolated than a PAT. The agent user’s key has the narrowest possible permissions and lives entirely in its own home directory.

You now have:
- Your main user → full personal credentials
- Agent user → only a repo-specific deploy key
- No credential leakage possible

Would you like the exact commands wrapped into a small setup script?

---

### User

That does not solve the issue that the agents can read these keys and could send them in their context to the remote models exposing potentially the repos. Correct? How do we solve this?

---

### Grok (grok-420-computer-use-sa)

**Yes, you are correct.** 

The deploy key private key lives in `~agent/.ssh/` and is readable by any process running as the `agent` user (including the AI agent). The agent could read it and send it to the model. We’ve only moved the problem, not eliminated it.

### How to truly solve it (credential not readable by the agent)

The only practical way on macOS is to **never store the credential on disk in the agent user’s home directory**. Instead, inject it at runtime via environment variable when launching git operations.

#### Best method: HTTPS + runtime-injected fine-grained PAT

1. **Create a minimal Personal Access Token (GitHub/GitLab)**
   - Fine-grained token
   - Only this repository
   - Only `Contents: Read & Write`
   - No other permissions

2. **Create a wrapper script owned by your main user**

   ```bash
   # As your main user
   sudo mkdir -p /usr/local/bin
   sudo tee /usr/local/bin/agent-git <<'EOF'
   #!/bin/bash
   # This script runs as the agent user but the token is injected by the parent
   export GIT_ASKPASS=/bin/echo
   export GIT_USERNAME=git
   export GIT_PASSWORD="ghp_your_fine_grained_pat_here"   # <-- put your PAT here

   exec /usr/bin/git "$@"
   EOF

   sudo chmod 755 /usr/local/bin/agent-git
   sudo chown root:wheel /usr/local/bin/agent-git   # or keep as your user
   ```

3. **Update Zed / ACP configuration**

   Point the agent command to use the wrapper instead of raw `git`:

   ```json
   {
     "agent": {
       "external": {
         "gemini": {
           "command": "sudo -u agent /usr/local/bin/agent-git"
         }
       }
     }
   }
   ```

   Or for any agent that calls git internally, make sure it uses this wrapper (or set `GIT_ASKPASS` + `GIT_PASSWORD` in the environment when you launch the agent).

### Why this is better

- The PAT never exists as a file in `~agent/`.
- It only lives in the environment of that specific process (in memory).
- If the agent tries to read `~/.gitconfig` or `~/.ssh/`, it finds nothing useful.
- You can rotate/revoke the PAT instantly from GitHub without touching the agent setup.

### Even stronger (optional)

If you want zero secrets in any file the agent can read:

- Put the PAT in **macOS Keychain** under the `agent` user (once, by you).
- Use a custom `credential.helper` that calls `security find-internet-password` at runtime.
- The token is still exfiltratable in theory (the agent can run the `security` command), but it’s no longer sitting in plaintext.

For most people the **runtime environment variable** method above is the sweet spot between security and convenience.

Would you like the full setup script + Zed settings example for this pattern?

---

### User

How about letting the agent work for a while locally, and then for pushing tge commits requiring the user (me) to provide a password or other authentication? Note though that github doesn't support https auth anymore I believe.

---

### Grok (grok-420-computer-use-sa)

**Yes — this is an excellent pattern.** It’s one of the cleanest ways to keep strong security while still letting agents be productive.

### Core Idea (Human-in-the-loop for remote operations)

- The agent (running as the low-privilege `agent` user) can **freely commit locally** — no credentials needed.
- `git push` and `git pull` are **blocked or require your explicit approval**.
- When you approve, the push happens under **your main user account** (which has your real credentials).

This way the agent never sees or stores any credentials.

### How to implement it with Zed + ACP + dedicated user

#### 1. Let the agent work locally (no changes needed)
The agent can create commits, branches, etc. as usual. Local git operations require zero authentication.

#### 2. Block or gate remote operations

**Option A – Best & simplest (recommended)**

In Zed, configure tool permissions so that `git push` and `git pull` **always require your approval**:

```json
{
  "agent": {
    "tool_permissions": {
      "terminal": {
        "default": "confirm",
        "always_allow": ["git status", "git diff", "git log", "git commit"]
      }
    }
  }
}
```

When the agent tries to push, Zed will ask you for confirmation. You can then:
- Approve, or
- Reject and run the push yourself manually.

**Option B – Fully automated but still human-controlled (my favorite)**

Create a small wrapper that only your main user can run:

```bash
# As your main user
sudo tee /usr/local/bin/agent-push <<'EOF'
#!/bin/bash
echo "Agent wants to push. Press Enter to continue as $(whoami) or Ctrl+C to cancel."
read
git push "$@"
EOF

sudo chmod +x /usr/local/bin/agent-push
```

Then tell the agent (via prompt or system instructions) to run:
```bash
sudo -u yourmainusername /usr/local/bin/agent-push
```

This switches execution to your main user (who has credentials) only when you explicitly allow it.

#### 3. About GitHub HTTPS authentication

**GitHub still fully supports HTTPS** — you just can’t use your account password anymore.  
You use a **Personal Access Token (PAT)** instead. It works exactly like before over HTTPS.

So you have two clean choices:

- Keep using SSH with your personal key (as your main user) → push via the wrapper above.
- Or switch the remote to HTTPS + PAT for your main user only.

### Recommended overall workflow

1. Agent works in the **locked clone** as the `agent` user.
2. Agent makes commits locally.
3. When it wants to push, it either:
   - Asks you via Zed (tool approval), **or**
   - Runs your wrapper that switches to your main user.
4. You review + approve → push happens with your credentials.
5. Pulls can follow the same gated pattern.

This gives you almost the same convenience as before, but the agent never has access to any credentials.

Would you like me to give you the exact Zed settings + wrapper script tailored to your current setup (including the locked clone)?

---

### User

Not sure what you mean, this is not about approval for pudh and pull commands. The question is how to surface the password prompt to me without the agents aborting its task. Or i can do the pushing manually that's likely the easiest cleanest separation...

---

### Grok (grok-420-computer-use-sa)

**Yes — doing the pushing manually is the cleanest and safest separation.**

### Recommended simple workflow

1. **Agent works completely locally**
   - Runs as the `agent` user on the locked clone.
   - Can edit files, commit, create branches, etc.
   - **Never** runs `git push` or `git pull`.

2. **You handle remote operations**
   - When the agent is ready (or at regular intervals), you switch to your main user and run:
     ```bash
     cd /path/to/locked-clone
     git push
     ```
   - Or even simpler, create an alias in your main shell:
     ```bash
     alias agent-push='cd /path/to/locked-clone && git push'
     ```

### Why this is actually the best option here

- Zero credentials ever given to the agent user.
- No wrappers, no environment variables, no Keychain tricks.
- No risk of the agent reading or exfiltrating anything.
- You stay in full control of what actually reaches the remote.
- Very low friction once you get used to it (especially if you keep a terminal tab open for the locked clone).

### Optional quality-of-life improvements

- Tell the agent explicitly in its system prompt / rules:
  > "You are only allowed to commit locally. Never run `git push` or `git pull`. When you finish a task, just say 'Ready to push' and stop."

- You can make `git pull` also manual, or let the agent do pulls if you’re comfortable with a deploy key (since pulls are read-only).

This pattern (agent = local only, human = remote sync) is widely used by people who are serious about not leaking credentials to AI agents.

Would you like a tiny script that makes switching to the locked clone and pushing one command?

---

### User

Problem is not the agent damaging the remote data but the agent exposing the repo data, so read only PAT is no solution...

---

### Grok (grok-420-computer-use-sa)

**Correct — that's the key distinction.**

A read-only PAT (or read-only deploy key) would let the agent `git pull` / fetch, which means it could bring the entire repo history and all files (including any newly decrypted or sensitive content) into its working directory and context. That defeats the whole point of protecting the repo data.

### Current best setup for your threat model (exfiltration prevention)

Keep the agent **completely disconnected from the remote**:

- **Locked clone** (encrypted files stay as ciphertext)
- Runs as the dedicated low-privilege `agent` user
- **No credentials at all** for the agent (no PAT, no deploy key, no SSH key)
- Agent can only work with whatever is **already checked out locally**
- You (main user) do the occasional manual `git pull` + `git push`

This way:
- The agent never has the ability to fetch new data from the remote.
- Sensitive files remain ciphertext (unreadable).
- Only non-sensitive plaintext files are visible to it.
- No risk of the agent pulling and then leaking fresh repo content.

### Recommended daily workflow

1. You occasionally run (as your main user):
   ```bash
   cd /path/to/locked-clone
   git pull          # brings latest changes (still encrypted where needed)
   ```

2. Agent works locally on the updated checkout.

3. When the agent finishes a task, it just tells you. You then review and push manually:
   ```bash
   git push
   ```

This is the cleanest separation for the "agent might leak repo data" risk.

Would you like a small script that makes the manual `pull` + `push` steps one-liners, or any other tweaks to this flow?

---

### User

No i mean it could still leak the read-only credentials. Leaking the credentials is the issue i already brought up multiple times...

---

### Grok (grok-420-computer-use-sa)

**Yes — exactly.** That's why we ended up here.

Any credential the agent can read (even a read-only PAT or deploy key) is a leak risk, because the agent could extract it and send it to the model.

### Final clean solution (addresses all your points)

**Give the agent zero credentials at all.**

- Locked clone (sensitive files stay ciphertext)
- Runs as dedicated low-privilege `agent` user
- **No PAT, no deploy key, no SSH key, nothing**
- Agent can only work with what's already on disk locally
- You do all `git pull` and `git push` manually from your main account

This completely removes the credential-leak vector you keep coming back to.

The agent literally cannot pull new data or push anything, so it can't exfiltrate credentials or large amounts of fresh repo content.

Is there anything left in this setup that still worries you, or shall we lock this in as the final pattern?

---

**Follow-up:** 2026-09-11

### User

what was the takeaway of that?

### Grok

Give the agent zero credentials, a locked clone, and a low-privilege user. You do all remote git yourself.

The thread settled on this stack:

1. Separate locked clone — never run transcrypt there, so no password in `.git/config`. Sensitive files stay ciphertext. Ignore files are extra, not enough.
2. Dedicated macOS user (`agent`) — Zed/ACP can launch the agent process as that user; Zed itself stays as you. The agent only sees the project folder, not `~/.ssh`, `~`, etc.
3. No PAT, deploy key, or SSH key for the agent at all. Anything it can read, it can send to the model. Human-in-the-loop push approval doesn’t fix that; neither does a read-only token.

Daily flow: you `git pull` into the locked clone as yourself → agent commits locally → you review and `git push`. Agent never talks to the remote.

Worktrees, Docker, and separate machines were considered; clone + dedicated user was the practical sweet spot.

### User

the main thing is that the agent gets its own unix user, right?

### Grok

Yes — that’s the isolation mechanism they landed on (after rejecting Docker).

It only works if that user also has **nothing worth stealing**: locked clone (no transcrypt password) and **zero git credentials**. The user boundary is useless if the agent can still read a PAT or SSH key in its own home.

### User

is that a practical solution? can the agent user still use github? i guess giving it its own ssh key for github would be useless since ssh keys can't be scope. so it can't read encrypted data from repos, but if we want it to read only certain repos we would have to give it its own github user as well, correct?

### Grok

Unix user is practical for **filesystem** isolation. GitHub is the part that stays awkward.

Account SSH keys are unscoped — a key on your GitHub account can reach every repo that account can. So giving the agent your key (or a new key on your account) is useless as a boundary.

You don’t need a second GitHub user for scoping, though:

| Credential | Scope | Extra GitHub user? |
|---|---|---|
| Deploy key | One repo | No |
| Fine-grained PAT | Chosen repos + permissions | No |
| Machine user + SSH key | Whatever repos you add it to | Yes |

A machine user is only needed if you want SSH *and* several repos. For one repo, a deploy key is enough.

None of that solves the original threat. Whatever the agent user can read, it can send to the model. Scoping only limits blast radius after the leak.

So: unix user = keep it off your home/`~/.ssh`/transcrypt password. GitHub = either **you** pull/push (zero creds on the agent), or you accept a **scoped** credential and the risk it gets exfiltrated.

### User

ok but Deploy key i'd have to setup for each repo. so if i want the commits to appear as mine, then Fine-grained PAT is the way to go.

### Grok

Almost — two different identities:

- Commit author (“this commit is mine”) = `user.name` / `user.email` in the clone. Independent of how you auth. Deploy key, PAT, or machine user all work if the email matches your GitHub account.
- Who pushed = the credential. Fine-grained PAT on your account → GitHub treats the push as you. Deploy key → no user. Machine user → that bot.

So PAT is the right choice if you want **one credential, several chosen repos, pushes as you**. Deploy keys are only painful because they’re one-per-repo, not because of commit attribution.

Still the original leak: that PAT lives where the agent can read it. Scoping limits blast radius; it doesn’t stop exfil. Don’t also give it your commit-signing key if you care about “verified” — that’s worse.

### User

that's what i was saying. i discarded Deploy keys because of the per repo setup. if i give the agent its own GitHub user commit author will be that separate user. so that leaves us with a PAT. don't overcomplicate things. give it to me straight.

### Grok

Yes. Fine-grained PAT on your account, scoped to the repos you want. That’s the option.

---


