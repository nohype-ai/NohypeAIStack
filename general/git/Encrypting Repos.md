# Encrypting Repos

Dieses Dokument beschreibt unsere Strategie um Git mit E2EE zu verbinden ohne Platform Lock-in.

Ursprüngliche Motivation war es sensitive Business Obsidian Vaults via Git Repos zu teilen und dennoch hinreichend privat zu halten.

## Decision Record: How We Arrived at This Strategy

### Motivation
- Obsidian Vaults via git teilen statt via Cloud Folder
- **Grund 1:** .gitignore nutzen für user-spezifische Obsidian configs wie etwa `.obsidian/workspace.json` (allgemein: steuerbare Projekt-/Nutzer-Grenze)
- **Grund 2:** Edits von AI Agents lassen sich anders kaum überwachen. In einem reinen Cloud Folder blieben viele Änderungen unbemerkt und würden von keinem Menschen abgenommen werden.
  - Das ist eine neue aber fundamentale Anforderung. Agents sind jetzt zentraler Teil von Knowledge Work, auch jenseits vom Code selbst: Harness, Scaffolding, LLM Wiki etc.
- **Beide Gründe zielen auf effektive Nutzung von KI.** Obsidian ist die IDE für Markdown, und Markdown ist die Sprache der LLMs.

### Challenge
- GitHub ist von Natur aus eine öffentlichere Plattform als ein Cloud Folder. Datenleaks sind wahrscheinlicher. Ein Kollaborateur müsste zum Bsp. nur die Sichtbarkeit eines privaten Repos auf öffentlich umstellen und schon wäre alles öffentlich.
- Jüngste Ereignisse haben die Vertrauenswürdigkeit von GitHub weiter erodiert (GitHub down times, Microslop)
- Auf regulären git Hosting Services (wie GitHub) gelten selbst private Repos einfach nicht als hinreichend privat für sensitive Daten. Auch weil da bezüglich Privacy andere Standards angewendet werden als bei echten Business Cloud Services.

### Weitere Vorteile jeder Lösung
1. Generelle Vorteile von git nutzen: merging, branching, history ...
2. Alles in einem System: nur Repos statt Repos + Cloud Folders
3. Ein Repo kann mehrere Remotes haben:
	- Level der Redundanz frei wählbar
	- Unabhängigkeit von einzelnem Cloud Anbieter (Apple, MS)
	- geografischer Speicherort wählbar (etwa Host im Heimatland)
4. Lesbarkeit für Host (Apple, Microsoft) und Behörden kann ausgeschlossen werden. End-to-End Encryption wird möglich wenn nicht gar zum Default. (Privacy-Level generell selektiv einstellbar also pro Repo/Ordner/Datei)

### Erforschte Strategien

Vier Strategien wurden ausführlich erforscht:
1. git filters via `git-crypt` oder `transcrypt`
2. git remote helper via `git-remote-gcrypt`
3. self-hosting auf business cloud mit CMK
4. business git hosting service mit CMK (Azure DevOps, GitLab Ultimate)

### Solution: git filters via `transcrypt`

Why this strategy over the other three? Because it has this specific combination of additional advantages:
- easyiest to use, low cognitive load on the technical side
- agents can be used without them seeing sensitive data. you can simply re-activate encryption temporarily in your local working copy (i.e. deactivate the automatic decryption again).
- no platform lock-in: encrypts data in repo independent of repo hosts, requiring minimal tooling and knowledge
- completely free
- password rotation is straightforward but requires sacrificing history — see [Rotating the Encryption Password](Rotating%20the%20Encryption%20Password.md) — because `transcrypt --rekey` does not re-encrypt old history
- git-native: uses `.gitattributes` patterns and clean/smudge filters
- modern encryption (uses OpenSSL AES-256 directly)
- flexible selective encryption: only encrypts what needs encryption, allows encrypting secrets even in open-source public repos
- preserves usability without password, preserves host features like PRs
- repo remains self-describing (self-contained) as the documentation of the encryption can itself remain unencrypted
- maintained better, used more, starred more than `git-remote-gcrypt` and `git-crypt`
- simple key management: just one shared password per repo or set of repos
- decouples concerns: git, encryption, hosting ...
- simplicity of hosting: allows to continue using one and the same host (GitHub) for everything: sensitive, private and public repos
- no risk of accidentally locking people out (like with `git-remote-gcrypt`)
- pure bash script (no compilation, easy to audit, minimal lock-in to the tool itself)
- transcrypt officially supports Windows, so Windows users can fully collaborate, with only minor adjustments
- downsides have positive effects as well or are super managable:
	- what is sensitive must be made explicit → everyone's aware of what is sensitive
	- frequent changes of encrypted files grow history size → not so much when sensitive data is isolated and explicit. and old history could be abandoned as last resort, no big deal.

### Limits / Open Questions

- when the repo is unlocked locally, the password locates in `.git/config` in the repo. the risk in combination with AI agents is that agents could read sensitive data and even the password into their context and send it to remote models (not because agents are evil but because this is just a likely effect of how they work.)
	- this reflects a general problem with agents. in macOS, a user's space is traditionally consdidered private to that user, but agents running in a user's space could expose that user's private data and credentials.
- locking and unlocking can take a moment on large repos with lots of sensitive data. and of course the user can forget to lock the repo before using an agent.

### Future Direction

#### We're optimizing for long-term invariants
1. **Conceptual integrity of the data** — Data that belongs together stays together. We refuse to let today's encryption/agent limitations dictate how we structure our knowledge.
2. **Future local agent reality** — Eventually, local agents (running on our own or client hardware or in controlled environments) will need access to the *full* picture, including the highly confidential parts. The system must not paint itself into a corner where that becomes painful or impossible.
3. Encryption is not just about what agents see. It is a protection layer against any form of data leak, including compromised private git repos or human error of collaborators.

Implied: we stick to partially encrypted git repos

#### The most promising remaining degrees of freedom
1. where to draw the line between encrypted and plain data
2. running agents in their own isolated environment (machine, VM ...) where encryption passwords are not available and no repo is ever unlocked.


#### Potential additional levers
1. Anonymizing data. There are 2 main approaches:
  - copy valuable information from the encrypted part into the plain part while anonymizing, for example by replacing sensitive data with placeholders or simply by summarizing.
  - extract sensitive information completely out of the repo (into a business cloud, on premise folder or password manager) in a way that does not break things or can easily be reversed when needed. for example a deployment pipeline could retrieve auth data from a secrets manager.
2. Other forms of isolation? An isolation mechanism we use must be deterministic in the sense that it's air tight by virtue of logic and principle. We should find out if any of the isolation levels listed in `stack/ai/research/Confidentiality and Integrity.md` satisfy this requirement. An example of such a controllable boundary is "degree of freedom" #2 described above. It guarantees the agent will never see any encrypted data or user credentials. In contrast, a solution that means manually fixing leaks one by one requires constant maintenance and never adds any guarantees.

#### Again: We're drawing a hard line
- **Hard boundaries** (can be used as isolation mechanisms): Things that are *deterministic and principle-based* — the agent *physically cannot* see the real data, no matter how it behaves or what prompts you give it. Examples: separate OS user / machine where the unlocked repo never exists, actual encryption the agent can't read, a git worktree that was never decrypted in that environment, etc.
- **Pseudo / flaky boundaries** (rejected): Anything that relies on the agent's behavior, prompt obedience, harness logic, or "the model will probably do the right thing." This includes on-the-fly anonymization/summarization inside the harness, tool restrictions that depend on the agent following rules, custom instructions telling the agent "don't look at this folder," etc. These require constant maintenance and give no real guarantees.

#### Local Inference will unlock everything without having to do everything
local agents will always lag remote SOTA agents, but: they can be applied to what they are good at in a targeted specialized way: they can just do the extraction, summarization, anonymization, pre-processing on the sensitive data to generate plain data that thereafter can be fed to the actual remote agents ...

## Using Encrypted Repos

The following sections provide documentation for collaborators on how to work with repos that use the above described strategy.  We assume the user has the `lock` and `unlock` commands available. The easiest way to get them is to install [MacStack](https://macstack.dev). 

### General

✅ You can use the repo like any other repo, without setting up any decryption. Just make sure not to change any encrypted (obfuscated) files, because that would destroy their encrypted content.

🔒 Files are encrypted if they match any of the related patterns defined in `.gitattributes`. And file content also makes that obvious, since encrypted content looks like random garbage. Note that only file contents get encrypted and not the names of files and folders.

### `.gitattributes`

The `.gitattributes` file in a repo defines patterns that determine which files in that repo are supposed to get encrypted.

This documentation assumes that the patterns in the repo's `.gitattributes` file look something like this:

```gitattributes
**/*CONFIDENTIAL*/** filter=crypt diff=crypt merge=crypt
*CONFIDENTIAL*/** filter=crypt diff=crypt merge=crypt
**/*CONFIDENTIAL* filter=crypt diff=crypt merge=crypt
*CONFIDENTIAL* filter=crypt diff=crypt merge=crypt

**/*🔒*/** filter=crypt diff=crypt merge=crypt
*🔒*/** filter=crypt diff=crypt merge=crypt
**/*🔒* filter=crypt diff=crypt merge=crypt
*🔒* filter=crypt diff=crypt merge=crypt
```

For example, this will mark all files as encrypted that have a "🔒" anywhere in their file path (including in the file name).

### Set Up Decryption

If you want to read or write the encrypted files:
  - Ensure you have the `lock` and `unlock` commands available. The easiest way to get them is to install [MacStack](https://macstack.dev).
  - get the repo password from the repo owner
  - in the repo folder run `unlock`. it will ask for the password.
  - from now on, everything works for you as if nothing was encrypted.

### 🚨 Encrypt Sensitive Data

  - 🚨 encrypt each sensitive item (file/folder) by using certain terms or emojis in that item's path, as defined by the patterns in the repo's `.gitattributes` file.
    - this could simply mean putting a sensitive item into a folder that already has such a term or emoji in its path.
    - a file path includes the file name, so individual files can of course also be marked as sensitive.
    - file- and folder names themselves do not get encrypted, so do not put sensitive data into them.
  - 🚨 Ensure the appropriate item path **BEFORE** you even stage a sensitive item! Because the patterns in `.gitattributes` are already evaluated when staging – not when committing or pushing!
  - 🔓 Adding sensitive files of course only works while the repo is **unlocked**.
  - ❗ Try to limit encryption to only sensitive data. Do not mix sensitive and regular data in the same file.
    - This keeps it explicit what is actually sensitive
    - But most of all: This keeps the history size minimal by avoiding unnecessary changes of encrypted files, mitigating the big downside of this whole approach.

### 🚨 Hide Sensitive Data from Agents

An unsolved issue with this repo-level partial encryption strategy is this: In an unlocked repo, agents might read sensitive data into their context and send it to remote models. This includes not only the sensitive data itself (that is supposed to be protected by encryption) but also the encryption password in `.git/config`.

Just locking and unlocking the repo all the time is no solution since that can take time on a large repo and also can easily be forgotten.

So the strongly implied practice is this:
- **Keep your local repo locked.** Never unlock your main local working copy that you work on with agents.
- Instead, when you need to read or edit encrypted files, create a separate checkout locally that you never work on with agents and that is not integrated into the normal setup and workflow but is only used for manual reading and editing of sensitive data. This working copy could stay unlocked if you ensure that no agent can ever access it.
- To really enforce the separation, one could run agents in a dedicated "agent-operator" macOS user that simply has no access to the unlocked repo owned by your personal macOS user.

To lock a repo, run `lock` in its root folder. This will switch it back to encrypted files (same garbage you see on GitHub) and remove the locally stored password.

### Keep History Encrypted

Surface level password changes or encrypting previously unencrypted files would not effect the git history. But git history must remain as private as the current state or commit.

That means we cannot simply use `transcrypt --rekey` to change the password or `git add --renormalize .` to suddenly encrypt existing files. When such needs arise we re-encrypt the whole repo with a new password and sacrifice the repo history. That is a trade-off we can make because we use git for collaboration with people and agents - not for archeology. How we rotate a password is documented in [Rotating the Encryption Password](Rotating%20the%20Encryption%20Password.md).
