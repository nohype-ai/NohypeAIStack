# GitHub (HTTPS via `gh`)

Omarchy already ships `gh`. Git on this machine uses HTTPS with the GitHub CLI as the credential helper — not SSH. GitHub account: **codeface-io**.

In a real terminal (so the browser can open):

```bash
gh auth login
```

Prompts:

| Prompt | Choice |
| --- | --- |
| Where do you use GitHub? | GitHub.com |
| Preferred protocol for Git operations | **HTTPS** |
| Authenticate Git with your GitHub credentials? | **Yes** |
| How would you like to authenticate? | Login with a web browser |

Copy the one-time code, press Enter, paste it at [github.com/login/device](https://github.com/login/device), approve. Success looks like:

```text
✓ Authentication complete.
- gh config set -h github.com git_protocol https
✓ Configured git protocol
✓ Logged in as codeface-io
```

Check later with `gh auth status`.

Existing clones that still have an SSH remote (`git@github.com:…`) must be switched or `git` will keep asking for the SSH key passphrase:

```bash
git remote set-url origin https://github.com/USER/REPO.git
git remote -v
git fetch
```

`git fetch` / `pull` / `push` against `https://github.com/…` remotes should not prompt. New clones: `gh repo clone USER/REPO` or `git clone https://github.com/USER/REPO.git`.

