# Full Repo Encryption with git-remote-gcrypt

## Why We Moved to git-remote-gcrypt

We started by evaluating tools for encrypting files in Git repositories, with these core requirements:

- Support for **any file type** (Markdown, code, PDFs, etc.)
- **Seamless experience** for less technical collaborators (no manual `hide`/`reveal` commands)
- Ability to encrypt **entire repositories**, not just selected files
- Preference for **transparent encryption** (automatic, invisible to the user)

**Git filter tools** (`git-crypt` and `transcrypt`) were initially strong candidates because they provide true transparent encryption via Git’s clean/smudge filters. However, they have significant limitations when encrypting **most or all files** in a repository:

- History size grows dramatically (due to poor delta compression on encrypted data)
- Not officially recommended for full-repo encryption
- `git-crypt` lacks easy user revocation
- `transcrypt` is symmetric-only (weaker multi-user model)

**git-secret** was also considered but rejected because it requires a manual encryption/decryption dance before every commit, which creates friction for non-technical users and on near fully encrypted repos.

This led us to **git-remote-gcrypt**, which takes a different approach: it encrypts the **entire repository** at the remote transport level using a Git remote helper.

## What is git-remote-gcrypt?

`git-remote-gcrypt` is a Git remote helper that encrypts the full repository when pushing to a remote (using GPG). It uses special `gcrypt::` URIs (e.g. `gcrypt::git@github.com:user/repo.git`).

- The **local working directory** is always plaintext.
- Encryption/decryption happens automatically during `push` and `pull`.
- The remote (e.g. GitHub) only ever sees encrypted data.
- It works with GitHub, GitLab, and other hosts.

## Key Advantages

| Advantage                        | Description |
|----------------------------------|-----------|
| **Full-repo encryption**         | Encrypts the entire repository (content + most metadata), not just selected files |
| **Better history size**          | Significantly less history bloat compared to using filter tools for full-repo encryption |
| **Fully transparent**            | No extra commands needed after setup. Works like normal Git for users |
| **Good for sensitive/private repos** | Strong protection when storing repos on untrusted hosts (GitHub, etc.) |
| **Mature & established**         | Most well-known and battle-tested tool in the "remote helper full-repo encryption" category |
| **Works with GitHub**            | Fully compatible (though GitHub features are limited) |

## Key Trade-offs

| Trade-off                        | Description |
|----------------------------------|-----------|
| **Slower pushes and pulls**      | Noticeable overhead due to GPG encryption (especially on larger repos or frequent pushes) |
| **Breaks GitHub features**       | Pull Requests, web file browser, blame, and commit history view do **not** work properly |
| **Different collaboration style**| No Pull Requests. Collaboration happens via direct push/pull + communication (Slack, etc.) |
| **GPG key management required**  | All team members need GPG keys and must be configured as participants |
| **First push is slow**           | Initial setup takes longer as it encrypts the entire repo |
| **Less efficient data transfer** | Uploads more data than normal Git due to reduced delta compression |

## When This Approach Makes Sense

**Best fit when:**
- You have **small to medium** repositories (< 300–400 MB)
- You work mostly with **text files** (e.g. Markdown, code)
- You have a **small, trusted team** (2–6 people)
- You want **maximum encryption** with minimal daily friction
- Fast internet connection (fiber) is available
- You are okay with a simpler collaboration model (no PRs)

**Less ideal when:**
- You have large repositories
- You rely heavily on GitHub Pull Requests and code review UI
- You push very frequently
- Team members are not comfortable with GPG

## How "No PRs" Can Be a Feature for Small Trusted Teams

One of the main downsides of full repo encryption is the loss of GitHub features and aabove all the loss of PRs. However this can be a plus for small high-trust teams:
- **Faster iteration** — Changes can be shared immediately via direct push and pull, without waiting for reviews or approvals.
- **Lower process overhead** — Eliminates the bureaucracy of opening PRs, requesting reviews, addressing comments, and merging — leading to a simpler, more lightweight workflow.
- **Encourages direct communication** — Teams tend to talk more (via Slack, calls, or pair programming) instead of hiding behind asynchronous PR comments.
- **Reduced cognitive load** — Especially beneficial for less technical or busy team members who don’t want to navigate GitHub’s PR interface.
- **Higher velocity** — Small, trusted teams can move much faster when they don’t have to go through formal review processes for every change.
- **More control** — The team decides how and when code review happens, rather than being forced into GitHub’s standardized PR model.

In short: For small, competent, and well-communicating teams, removing Pull Requests often results in a **simpler, faster, and more human** collaboration style.

## Quick Setup Overview (GitHub)

1. Create a **private** empty repository on GitHub.
2. On your local machine:
   ```bash
   git remote add origin gcrypt::git@github.com:username/repo.git
   git config remote.origin.gcrypt-participants "YOUR_KEY_ID TEAM_MEMBER_KEY_ID"
   git push -u origin main
   ```
3. Team members clone using the `gcrypt::` URL and configure the same participants list.
