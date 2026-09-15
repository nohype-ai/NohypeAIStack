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

## GitHub SSH

Default key for this machine is `~/.ssh/id_ed25519`. OpenSSH picks that filename on its own — no `~/.ssh/config` needed. GitHub account: **codeface-io**.

```bash
ssh-keygen -t ed25519 -C "sebastian@codeface.io" -f ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

Use a passphrase. Then add the public key at [github.com/settings/keys](https://github.com/settings/keys) as an **Authentication** key (title e.g. the hostname). Test:

```bash
ssh -T git@github.com
```

First use: type `yes` to trust GitHub’s host key (writes `~/.ssh/known_hosts`). Then enter the key passphrase.

Success:

```text
Hi codeface-io! You've successfully authenticated, but GitHub does not provide shell access.
```

Clone / remotes use SSH:

```bash
git clone git@github.com:USER/REPO.git
git remote set-url origin git@github.com:USER/REPO.git
```
