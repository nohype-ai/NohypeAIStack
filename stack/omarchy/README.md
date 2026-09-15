# my-system

Personal Omarchy / Hyprland setup notes. Goal: capture each desktop tweak here so the machine can be reproduced later.

## Natural scroll

Omarchy defaults to traditional scrolling (`natural_scroll = false`). This machine uses macOS-style natural scroll: content follows the fingers / mouse wheel.

**File:** `~/.config/hypr/input.lua` (not `looknfeel.lua` — that file is appearance only)

**Change:**

```lua
hl.config({
  input = {
    -- Natural (inverse) scrolling for mouse wheel and touchpad.
    natural_scroll = true,
    touchpad = {
      natural_scroll = true,
    },
  },
})
```

| Setting | Device |
| --- | --- |
| `input.natural_scroll` | Mouse wheel |
| `input.touchpad.natural_scroll` | Touchpad |

**Apply:** Hyprland reloads on save. Force with `hyprctl reload`, then check `hyprctl configerrors`. Confirm with:

```bash
hyprctl getoption input:natural_scroll
hyprctl getoption input:touchpad:natural_scroll
```

Both should report `bool: true`.

## Installed apps

Extra apps on top of the Omarchy stock install:

| App | Install |
| --- | --- |
| Ghostty | `omarchy install terminal ghostty` |
| Brave Origin | `omarchy install browser brave-origin` |
| Zed | `omarchy install editor zed` |

## Defaults

These are the Omarchy defaults on this machine (terminal, browser, editor, and coding agent):

| Role | Choice | Set with |
| --- | --- | --- |
| Terminal | Ghostty | `omarchy default terminal ghostty` |
| Browser | Brave Origin | `omarchy default browser brave-origin` |
| Editor | Zed | `omarchy default editor zed` |
| Agent | Grok | `omarchy default agent grok` |

The three apps above also get set as defaults when installed with the `omarchy install` commands. Grok is chosen separately:

```bash
omarchy default agent grok
```

That writes `grok` to `~/.config/omarchy/defaults/agent` and launches it. Super + agent / `omarchy agent` then open Grok.

Check current values:

```bash
omarchy default terminal
omarchy default browser
omarchy default editor
omarchy default agent
```

## GitHub (HTTPS via `gh`)

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
