# Encrypting Repos

Dieses Dokument beschreibt unsere Strategie um Git mit E2EE zu verbinden ohne Platform Lock-in.

Ursprüngliche Motivation war es sensitive Business Obsidian Vaults via Git Repos zu teilen und dennoch hinreichend privat zu halten.

## Motivation
- Obsidian Vaults via git teilen statt via Cloud Folder
- **Grund 1:** .gitignore nutzen für user-spezifische Obsidian configs wie etwa `.obsidian/workspace.json` (allgemein: steuerbare Projekt-/Nutzer-Grenze)
- **Grund 2:** Edits von AI Agents lassen sich anders kaum überwachen. In einem reinen Cloud Folder blieben viele Änderungen unbemerkt und würden von keinem Menschen abgenommen werden.
  - Das ist eine neue aber fundamentale Anforderung. Agents sind jetzt zentraler Teil von Knowledge Work, auch jenseits vom Code selbst: Harness, Scaffolding, LLM Wiki etc.
- **Beide Gründe zielen auf effektive Nutzung von KI.** Obsidian ist die IDE für Markdown, und Markdown ist die Sprache der LLMs.

## Challenge
- GitHub ist von Natur aus eine öffentlichere Plattform als ein Cloud Folder. Datenleaks sind wahrscheinlicher. Ein Kollaborateur müsste zum Bsp. nur die Sichtbarkeit eines privaten Repos auf öffentlich umstellen und schon wäre alles öffentlich.
- Jüngste Ereignisse haben die Vertrauenswürdigkeit von GitHub weiter erodiert (GitHub down times, Microslop)
- Auf regulären git Hosting Services (wie GitHub) gelten selbst private Repos einfach nicht als hinreichend privat für sensitive Daten. Auch weil da bezüglich Privacy andere Standards angewendet werden als bei echten Business Cloud Services.

## Weitere Vorteile jeder Lösung
1. Generelle Vorteile von git nutzen: merging, branching, history ...
2. Alles in einem System: nur Repos statt Repos + Cloud Folders
3. Ein Repo kann mehrere Remotes haben:
	- Level der Redundanz frei wählbar
	- Unabhängigkeit von einzelnem Cloud Anbieter (Apple, MS)
	- geografischer Speicherort wählbar (etwa Host im Heimatland)
4. Lesbarkeit für Host (Apple, Microsoft) und Behörden kann ausgeschlossen werden. End-to-End Encryption wird möglich wenn nicht gar zum Default. (Privacy-Level generell selektiv einstellbar also pro Repo/Ordner/Datei)

## Erforschte Strategien

Vier Strategien wurden ausführlich erforscht:
1. git filters via `git-crypt` oder `transcrypt`
2. git remote helper via `git-remote-gcrypt`
3. self-hosting auf business cloud mit CMK
4. business git hosting service mit CMK (Azure DevOps, GitLab Ultimate)

## Solution: git filters via `transcrypt`

Why this strategy over the other three? Because it has this specific combination of additional advantages:
- easyiest to use, low cognitive load on the technical side
- agents can be used without them seeing sensitive data. you can simply re-activate encryption temporarily in your local working copy (i.e. deactivate the automatic decryption again).
- no platform lock-in: encrypts data in repo independent of repo hosts, requiring minimal tooling and knowledge
- completely free
- easy credential rotation / user revocation: just change the password, no history breakage
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

## How To

The patterns in the `.gitattributes` file could look like this:

```gitattributes
# Encrypt files/folders containing these terms (case-insensitive)
**/*[Vv]ertraulich** filter=crypt diff=crypt merge=crypt
**/*[Cc]onfidential** filter=crypt diff=crypt merge=crypt
**/*[Gg]eheim** filter=crypt diff=crypt merge=crypt
**/*[Ss]ecret** filter=crypt diff=crypt merge=crypt
**/*[Pp]rivat** filter=crypt diff=crypt merge=crypt
**/*🔒** filter=crypt diff=crypt merge=crypt
**/*🔐** filter=crypt diff=crypt merge=crypt
**/*🔑** filter=crypt diff=crypt merge=crypt
```

The following sections could all be provided as documentation in a Repo. They assume something like the above `.gitattributes` file and employ the `lock` and `unlock` commands that come with [MacStack](https://macstack.dev).

### General

✅ You can use this repo like any other repo, without setting up any decryption. Just make sure not to change any encrypted (obfuscated) files, because that would destroy their encrypted content.

🔒 Files are encrypted if they match any of the related patterns defined in [.gitattributes](.gitattributes). For example a file that has a "🔒" anywhere in its name or path gets encrypted. File content also makes it obvious, since encrypted content looks like random garbage. Note that file- and folder names never get encrypted.

### Set Up Decryption

If you want to read or write the encrypted files:
  - Ensure you have the `lock` and `unlock` commands available. The easiest way to get them is to install [MacStack](https://macstack.dev).
  - get the repo password from the repo owner
  - in the repo folder run `unlock`. it will ask for the password.
  - from now on, everything works for you as if nothing was encrypted.

### 🚨 Encrypt Sensitive Data

  - 🚨 encrypt each sensitive item (file/folder) by using certain terms or emojis in that item's path, as defined by the patterns in [.gitattributes](.gitattributes).
    - this could simply mean putting a sensitive item into a folder that already has such a term or emoji in its path.
    - a file path includes the file name, so individual files can of course also be marked as sensitive.
    - file- and folder names themselves do not get encrypted, so do not put sensitive data into them.
  - 🚨 Ensure the appropriate item path **BEFORE** you even stage a sensitive item! Because the patterns in [.gitattributes](.gitattributes) are already evaluated when staging – not when committing or pushing!
  - ❗ Try to limit encryption to only sensitive data. Do not mix sensitive and regular data in the same file.
    - This keeps it explicit what is actually sensitive
    - But most of all: This keeps the history size minimal by avoiding unnecessary changes of encrypted files, mitigating the big downside of this whole approach.

### Hide Sensitive Data from Agents

Switch local working copy to encrypted files: `lock`
- Removes the locally stored password/credentials
- Forces Git to **re-encrypt** all files in your working directory
- Your local files will now show the encrypted content (the same garbage you see on GitHub)

This is perfect for letting agents work on the repo without them ever seeing plaintext sensitive data.

To switch back to normal (decrypted) mode, run `unlock` again.

### Change Repo Password

This only works when the local credentials (password + cipher) are active — which means the repo must be in the **unlocked** state:
1. Make sure you're **unlocked** (working directory shows plaintext files):
   ```bash
   unlock    # and enter current password
   ```
2. Then run rekey:
   ```bash
   transcrypt --rekey
   ```
3. Enter the **new** password when prompted.
4. Commit and push the changes.
5. Share new password with team (store it in shared password manager).



