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
