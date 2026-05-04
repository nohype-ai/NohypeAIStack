# Encrypted Obsidian Vaults

Dieser Ordner beschreibt Strategien um sensitive Business Obsidian Vaults via Git Repos zu teilen und dennoch hinreichend privat zu halten.

## Ziel
- Obsidian Vaults via git teilen statt via Cloud Folder
- **Grund 1:** .gitignore nutzen für user-spezifische Obsidian configs wie etwa `.obsidian/workspace.json` (allgemein: steuerbare Projekt-/Nutzer-Grenze)
- **Grund 2:** Edits von AI Agents lassen sich anders kaum überwachen. In einem reinen Cloud Folder blieben viele Änderungen unbemerkt und würden von keinem Menschen abgenommen werden.
  - Das ist eine neue aber fundamentale Anforderung. Agents sind jetzt zentraler Teil von Knowledge Work, auch jenseits vom Code selbst: Harness, Scaffolding, LLM Wiki etc.
- **Beide Gründe zielen auf effektive Nutzung von KI.** Obsidian ist die IDE für Markdown, und Markdown ist die Sprache der LLMs.

## Challenge
- GitHub ist von Natur aus eine öffentlichere Plattform als ein Cloud Folder. Datenleaks sind wahrscheinlicher. Ein Kollaborateur müsste zum Bsp. nur die Sichtbarkeit eines privaten Repos auf öffentlich umstellen und schon wäre alles öffentlich.
- Jüngste Ereignisse haben die Vertrauenswürdigkeit von GitHub weiter erodiert (GitHub down times, Microslop)
- Auf regulären git Hosting Services (wie GitHub) gelten selbst private Repos einfach nicht als hinreichend privat für sensitive Daten. Auch weil da bezüglich Privacy andere Standards angewendet werden als bei echten Business Cloud Services.

## Weitere Vorteile (wenn gelöst)
1. Generelle Vorteile von git nutzen: merging, branching, history ...
2. Alles in einem System: nur Repos statt Repos + Cloud Folders
3. Ein Repo kann mehrere Remotes haben:
	- Level der Redundanz frei wählbar
	- Unabhängigkeit von einzelnem Cloud Anbieter (Apple, MS)
	- geografischer Speicherort wählbar (etwa Host im Heimatland)
4. Lesbarkeit für Host (Apple, Microsoft) und Behörden kann ausgeschlossen werden. End-to-End Encryption wird möglich wenn nicht gar zum Default. (Privacy-Level generell selektiv einstellbar also pro Repo/Ordner/Datei)

## Strategien
1. [git filters](Strategy%201%20-%20git%20filters/README.md)
2. [git remote helper](Strategy%202%20-%20remote%20helper/README.md)
3. [self-hosting](Strategy%203%20-%20self-host%20on%20business%20cloud/README.md)
4. [business git host](Strategy%204%20-%20business%20git%20hosts/README.md)

## Strategie 2

I tended towards Strategy 2.

### Why Strategy 2 (git-remote-gcrypt)

**git-remote-gcrypt on GitHub** aligns with these principles:
- **True end-to-end encryption by default** — No configuration, no extra steps, no “we’ll add Customer Keys later.” The encryption is strong and automatic from day one.
- **Decoupling of concerns / Modularity** — You keep the hosting layer (GitHub) and the encryption layer (gcrypt) cleanly separated. You can keep using GitHub (or switch hosts anytime) without the encryption depending on the platform. This gives flexibility and resilience.
- **Maximum independence & no vendor lock-in** — You stay on free/public infrastructure (GitHub) without being pushed into expensive business tiers. You can easily use multiple hosts or migrate later.
- **Simplicity & pragmatism** — One tool, one decision (encrypt everything). No need to constantly evaluate “is this file sensitive?” or manage complex key setups. No juggling of multiple hosts necessary (GitHub continues to be important for OSS anyway)
- **No PRs as a deliberate feature** — For a small, trusted team, the simpler “just push and communicate” workflow is actually preferable to GitHub’s PR bureaucracy.

In short: It's optimizing for **independence, simplicity, and strong default security** rather than maximum features or deep platform integration.

### Counterpoints (by AI for balance)

Even though you’re leaning toward Strategy 2, here are the main trade-offs you’re accepting:

- **Performance** — Pushes and pulls will be noticeably slower than normal Git (especially on the first push or larger repos).
- **GitHub features are broken** — No proper Pull Requests, limited web UI, no blame, etc.
- **Collaboration style changes** — You’re committing to a more direct, communication-heavy workflow instead of GitHub’s structured PR process.
- **All-or-nothing encryption** — You encrypt *everything*, which is simple but means even non-sensitive files get the performance penalty.

## Vergleich Strategien 1 und 2

**Final Comprehensive Comparison: Strategy 1 vs Strategy 2**

### 1. Core Approach

| Aspect                        | **Strategy 2: git-remote-gcrypt**                          | **Strategy 1: git-crypt / transcrypt**                          |
|-------------------------------|------------------------------------------------------------|-----------------------------------------------------------------|
| **Encryption model**          | Full repository encryption (all or nothing)                | Selective encryption (you choose which files/folders)           |
| **Encryption happens**        | At the remote transport level (before upload)              | Via Git filters (clean/smudge) on commit/checkout               |
| **What gets encrypted**       | Everything in the repository                               | Only files you explicitly mark in `.gitattributes`              |

### 2. Security & Encryption Quality

| Aspect                                      | **Strategy 2: git-remote-gcrypt**                                      | **Strategy 1: git-crypt / transcrypt**                                      |
|---------------------------------------------|------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| **End-to-End Encryption (E2EE)**            | Yes, by default                                                        | Yes (but requires correct setup)                                            |
| **E2EE "by default" (low effort)**          | Excellent — almost zero configuration needed                           | Good — requires maintaining `.gitattributes` and remembering to encrypt new files |
| **Risk of accidentally leaking data**       | Very low (everything is encrypted)                                     | Medium (easy to forget to encrypt a new sensitive file)                     |
| **Repo-specific encryption information**    | Stored inside the encrypted blob (protected)                           | Stored in `.gitattributes` (plaintext) + filter configuration               |
| **Key management**                          | Per-repo data key + GPG participant keys. Easy to use same GPG key per person across repos | Can be per-repo symmetric key or GPG. More complex with many repos          |

### 3. Usability & Simplicity

| Aspect                                      | **Strategy 2: git-remote-gcrypt**                          | **Strategy 1: git-crypt / transcrypt**                          |
|---------------------------------------------|------------------------------------------------------------|-----------------------------------------------------------------|
| **Simplicity / Decision fatigue**           | Excellent — just encrypt everything                        | Poor — you must decide and manage what to encrypt               |
| **Cognitive load**                          | Very low                                                   | Higher (ongoing decisions about what is sensitive)              |
| **Setup complexity**                        | Low                                                        | Medium (`.gitattributes` + filter configuration)                |
| **Ongoing maintenance**                     | Very low                                                   | Higher (must maintain encryption rules over time)               |

### 4. Technical & Practical Trade-offs

| Aspect                                      | **Strategy 2: git-remote-gcrypt**                          | **Strategy 1: git-crypt / transcrypt**                          |
|---------------------------------------------|------------------------------------------------------------|-----------------------------------------------------------------|
| **History size impact**                     | Good (no major bloat)                                      | Can be significant (especially when encrypting many files)      |
| **Push / Pull performance**                 | Noticeably slower                                          | Close to normal Git                                             |
| **GitHub features (PRs, web UI, blame)**    | Broken / severely limited                                  | Fully preserved                                                 |
| **Flexibility (partial encryption)**        | None — all or nothing                                      | Excellent — you can encrypt only specific files/folders         |
| **Future flexibility**                      | Limited (hard to switch to partial encryption later)       | High (easy to start selective and expand later)                 |
| **Collaboration style**                     | No Pull Requests (direct push + communication)             | Full GitHub workflow with PRs                                   |

### 5. Strategic & Philosophical Fit

| Aspect                                      | **Strategy 2: git-remote-gcrypt**                          | **Strategy 1: git-crypt / transcrypt**                          |
|---------------------------------------------|------------------------------------------------------------|-----------------------------------------------------------------|
| **Independence / No vendor lock-in**        | Excellent (works with any Git host, clean separation)      | Very good (also works with any host, slightly more coupled)     |
| **Modularity / Decoupling**                 | High (encryption is separate from the repo)                | Medium (encryption logic lives inside the repo)                 |
| **Alignment with "encrypt everything" mindset** | Excellent                                                  | Poor (encourages selective thinking)                            |
| **Risk over time**                          | Low                                                        | Higher (complexity grows with repo size and team)               |

### 6. Summary – Which Strategy Wins Where

| Your Priority / Concern                     | Winner          | Reason |
|---------------------------------------------|-----------------|--------|
| **Simplicity & low cognitive load**         | **Strategy 2**  | No need to decide what to encrypt |
| **True E2EE with minimal effort**           | **Strategy 2**  | Works out of the box |
| **Independence & future flexibility**       | **Strategy 2** (slight edge) | Cleaner separation from hosting |
| **Avoiding risk of human error**            | **Strategy 2**  | Everything is encrypted by default |
| **Performance & full GitHub features**      | **Strategy 1**  | Faster and keeps PRs/web UI |
| **Ability to do partial encryption**        | **Strategy 1**  | Only real strength of this approach |
| **Long-term pragmatism & low maintenance**  | **Strategy 2**  | Less complexity as the project grows |
| **History size concerns**                   | **Strategy 2**  | Avoids the bloat problem entirely |

---

### Final Recommendation

Given everything you’ve shared — especially your strong preference for **simplicity**, **low cognitive load**, **independence**, and avoiding the mental overhead of deciding what is sensitive — **Strategy 2 (git-remote-gcrypt)** is the better fit for you.

The main advantage of Strategy 1 (flexibility for partial encryption) comes at the cost of exactly the complexity and decision fatigue you want to avoid.

---

## Discovered Problem with Strategy 2: Key Management

### 1. Practical Issues Discovered with `git-remote-gcrypt`

| Issue | What Actually Happens | Severity |
|-------|------------------------|----------|
| **Key distribution (multi-user)** | Everyone must have everyone else's public keys. Missing one = risk of locking people out | High |
| **Key rotation** | Easy for the owner, but breaks easy historical access for everyone | High |
| **Historical access after rotation** | Cannot reliably `git checkout` pre-rotation commits in fresh clones. Old objects become hard to access | High |
| **User revocation** | Removing a user breaks historical access for remaining users | Very High |
| **Full history access** | No simple way to get "full history" after rotation/revocation | High |
| **Debugging across changes** | Requires keeping old keys or pre-change clones | High |
| **Operational complexity** | High coordination needed for teams | Medium-High |

These issues stem from the fundamental design: the manifest (which holds all the symmetric keys) is replaced on every push that changes participants. Old manifests are gone.

---

### 2. Comparison: `git-remote-gcrypt` vs `git-crypt` vs `transcrypt`

| Aspect                              | **git-remote-gcrypt**                          | **git-crypt**                                      | **transcrypt**                                      | Winner for Small Teams |
|-------------------------------------|------------------------------------------------|----------------------------------------------------|-----------------------------------------------------|------------------------|
| **Encryption Scope**                | Entire repository (full history)              | Selected files only (via `.gitattributes`)        | Selected files only (via `.gitattributes`)         | git-remote-gcrypt     |
| **Encryption Method**               | GPG (public-key or shared key)                | OpenSSL (symmetric or GPG)                        | OpenSSL (symmetric only)                           | Depends on preference |
| **Multi-user Key Management**       | Complex (per-person or per-repo)              | Simple (one symmetric key or GPG)                 | Very simple (one password)                         | transcrypt            |
| **Risk of Accidental Lockouts**     | High (especially per-person model)            | Low                                                | Very Low                                           | transcrypt            |
| **Key Rotation Difficulty**         | Medium (but breaks history access)            | Easy                                               | Very Easy                                          | transcrypt            |
| **Historical Access After Rotation**| Poor (hard to access pre-rotation history)    | Good                                               | Good                                               | git-crypt / transcrypt|
| **User Revocation**                 | Poor (affects everyone’s history access)      | Easy (just stop sharing the key)                  | Easy (just change password)                        | transcrypt            |
| **Full History Encryption**         | Yes                                           | No (only selected files)                          | No (only selected files)                           | git-remote-gcrypt     |
| **Dependency on GPG**               | Required                                      | Optional (can use symmetric mode)                 | No                                                 | transcrypt            |
| **Operational Simplicity (Small Team)** | Medium (with per-repo key model)            | Good                                               | Excellent                                          | transcrypt            |
| **Best Use Case**                   | Full-repo encryption on untrusted remote      | Encrypting secrets in mostly-public repos         | Simple symmetric encryption of selected files      | —                     |

### Final Verdict

- **`git-remote-gcrypt`** excels at **encrypting the entire repository** (including history), but has significant operational drawbacks around key rotation, revocation, and historical access — exactly as you discovered.
- **`git-crypt`** and especially **`transcrypt`** are much simpler and more practical for most small teams, but they only encrypt **selected files**, not the full repository.

If full-repo encryption is a hard requirement, `git-remote-gcrypt` (with the per-repo key model) is still one of the few tools that does it. But if you're willing to encrypt only sensitive files, `transcrypt` is generally the better choice for small teams.

### Is Cutting Off History "That Bad"? (to Keep Repo Size in Check)

**That approach is actually quite reasonable and practical. It's not bad if you do it intentionally** at natural breakpoints (major releases, stable milestones, big refactors, etc.).

Many teams and projects do exactly what you described:
- Finish a major version or milestone
- Create a fresh repo (or heavily squash/filter history)
- Continue development in the new repo
- Keep the old repo around for reference (or archive it)
- Eventually delete or make the old one read-only

This is a **valid and common strategy**, especially when repo size or complexity becomes an issue.

### Pros of Your Proposed Workflow

| Benefit                        | Explanation |
|--------------------------------|-----------|
| Clean, manageable size         | New repo starts fresh |
| Simpler mental model           | "v2.0 = new repo" |
| Avoids complex key rotation    | No need to deal with historical access issues |
| Psychological fresh start      | Often improves maintainability |
| Easy to archive old version    | Keep `project-v1` as read-only reference |

### Cons (Be Honest With Yourself)

- You lose seamless `git log` / `git blame` / `git bisect` across the cutoff.
- All existing clones, links, and bookmarks to old commits break.
- Some loss of development context (though you can keep the old repo).
- Requires team coordination to switch.

### Recommendation

Your idea works well **if**:
- You do it at natural milestones (not randomly).
- You keep the old repo accessible for at least 6–12 months.
- Your team is okay with the trade-off of losing deep history access.

This approach is often **simpler and cleaner** than trying to fight repo bloat or key rotation issues indefinitely.

---

## Strategy 1 Afterall but with `transcrypt`?

**Here’s a clean summary of the main advantages of `transcrypt`:**

### Advantages of `transcrypt` over `git-remote-gcrypt`

| # | Advantage | Explanation |
|---|-----------|-------------|
| 1 | **Much easier to use** | Simpler commands, no GPG complexity, easier onboarding |
| 2 | **Easier credential rotation** | Simple `--rekey` command + easier debugging across changes |
| 3 | **More modern encryption** | Uses OpenSSL AES-256 directly (cleaner than GPG) |
| 4 | **Selective encryption** | Only encrypt what you need — unencrypted files work without any password |
| 5 | **Better for PRs & collaboration** | Reviewers don’t need the password to review non-sensitive code |
| 6 | **Better maintained** | More recent development activity (as of 2026) |
| 7 | **Simpler key management** | Just one shared password (vs GPG keys + participants list) |
| 8 | **Lower risk of mistakes** | Much harder to accidentally lock people out |
| 9 | **Easier user revocation** | Just change the password (no history breakage) |
| 10 | **Lower cognitive load** | Less to think about and configure |

### Bonus Practical Wins

- Works great with the **“isolate sensitive data in dedicated files”** strategy
- History cutting (if ever needed) is simpler to manage
- No dependency on GPG at all

### Git-Native but Modern & Usable

`transcrypt` is **as Git-native as `git-crypt`** (same `.gitattributes` mechanism, same transparent clean/smudge filters), but implemented in a more modern and convenient way:

- Pure Bash script (no compilation, easy to audit)
- Simpler commands (`--rekey`, `--add`, etc.)
- Better defaults and UX
- Actively maintained

It's essentially the refined, user-friendly evolution of the same core idea.

---

**Bottom line:**  
For a small trusted team, `transcrypt` wins on **simplicity, maintainability, and day-to-day usability**, while still providing strong encryption for the files that actually need it.

---

## The Killer Argument: Hiding Sensitive Data from Agents

Strategy 1 offers the ability to work normally on a repo with just the sensitive data (temporarily) encrypted. **This allows hiding that data from agents.**

That also nicely amplifies the incentive to keep sensitive data cleanly isolated in dedicated files, because this also keeps the history size problem in check: It minimizes the frequency of changes in encrypted files which can fully remove one of the 2 major downsides of strategy 1 which is the exploding history size.

the other downside can also turn into a feature: clearly marking and isolating sensitive data makes the team conscious of what data is actually sensitive in the whole repo. this requires more cognitive effort in the beginning but pays off:
1. data protection awareness beyond just the repo itself
2. encryption applied only where really needed