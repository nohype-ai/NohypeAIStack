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

## Keybindings

Personal overrides live in `~/.config/hypr/bindings.lua` (loaded after Omarchy defaults). Check current bindings with `omarchy menu keybindings --print`. If a key already has a default, `hl.unbind(...)` it before the new `o.bind(...)`.

### Super + Shift + G → Lazygit (cwd of the open terminal)

Omarchy default: **Signal**. This machine opens **Lazygit** instead, in the folder of the terminal you are in.

Do **not** use `{ tui = "lazygit" }` and do **not** depend on an `omarchy tui install` desktop launcher. That runs `omarchy-launch-tui lazygit` with no working directory. Ghostty is `gtk-single-instance`, so the new window inherits a stale cwd instead of the folder you have open.

`lazygit` is already on the Omarchy base install.

**File:** `~/.config/hypr/bindings.lua`

**Change:**

```lua
-- Lazygit TUI — replaces default Signal on this key.
-- Start in the focused terminal's cwd (same helper as Super+Return). If the
-- focused window is not a terminal, use the Ghostty window's cwd instead.
-- The inner `cd` is required: Ghostty gtk-single-instance ignores launcher cwd.
hl.unbind("SUPER + SHIFT + G")
o.bind(
  "SUPER + SHIFT + G",
  "Lazygit",
  "bash -lc "
    .. o.shell_quote([=[
cwd=$(omarchy-cmd-terminal-cwd)
class=$(hyprctl activewindow -j | jq -r '.class // empty')
case "$class" in
  com.mitchellh.ghostty|foot|Alacritty|kitty|org.codeberg.dnkl.foot|wezterm|org.omarchy.*|TUI.*) ;;
  *)
    gpid=$(hyprctl clients -j | jq -r '.[] | select(.class=="com.mitchellh.ghostty") | .pid' | head -n1)
    if [[ -n ${gpid:-} ]]; then
      for sp in $(pgrep -P "$gpid"); do
        exe=$(readlink -f "/proc/$sp/exe" 2>/dev/null) || continue
        grep -Fqsx "$exe" /etc/shells || continue
        d=$(readlink -f "/proc/$sp/cwd" 2>/dev/null)
        [[ -d $d ]] && cwd=$d && break
      done
    fi
    ;;
esac
exec omarchy-launch-tui --app-id=org.omarchy.lazygit bash -lc 'cd -- "$1" && exec lazygit' lazygit "$cwd"
]=])
)
```

What that does:

1. `omarchy-cmd-terminal-cwd` — cwd of the focused terminal (same helper Super+Return uses).
2. If the focused window is not a terminal, take the Ghostty window’s shell cwd so the shortcut still works from a browser, etc.
3. `omarchy-launch-tui` starts Lazygit in the default terminal, then `cd`s into that folder before `exec lazygit`. The inner `cd` is what Ghostty cannot ignore.

If the folder is not a git repo, Lazygit may offer recent repos — that is Lazygit, not the binding.

**Apply:** Hyprland reloads on save. Force with `hyprctl reload`, then check `hyprctl configerrors`. Confirm with:

```bash
omarchy menu keybindings --print | grep -i 'SHIFT + G'
```

Expect `SUPER SHIFT + G → Lazygit`. From Ghostty, `cd` into a git repo and press Super+Shift+G; Lazygit should open that repo. Signal is still launchable from the app menu (`omarchy launch signal`).

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

## Lock without turning the display off (Studio Display + AMD iGPU)

This machine is a mini PC on an **Apple Studio Display** (`DP-5`, 5120×2880). Cutting the display signal (`DPMS off`) wedges the AMD iGPU: the panel stays black and does not come back. Suspend (`systemctl suspend`) is fine; the failure was display-off, not sleep.

This Omarchy version does **not** use `hypridle` or `~/.config/hypr/hypridle.conf` (hypridle is not installed). Idle, screensaver, and lock are Quickshell services. The old “change the hypridle lock listener to lock only” advice maps to: **lock the session, never call DPMS off**.

### Default idle behavior (Omarchy)

| After idle | What happens |
| --- | --- |
| 150s | Screensaver (`omarchy-launch-screensaver`), unless `omarchy toggle screensaver` has turned it off |
| 300s | Lock (`omarchy-system-lock` → `omarchy-shell lock lock`) |
| 5s after lock | Packaged `omarchy.lock` runs `omarchy-brightness-display off`, which is `hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })'` — this is the wedge |

systemd-logind `IdleAction` is the default `ignore`. Inactivity does **not** suspend or hibernate. Sleep is only via the power menu / `systemctl suspend`.

`omarchy toggle idle stay-awake` (Super+Ctrl+I) disables the idle cycle entirely (no screensaver, no auto-lock). This machine is set to **allow idle**.

### Change (lock only)

Do not edit `/usr/share/omarchy/` (package-owned). Clone the lock plugin and skip the blank/DPMS timer:

```bash
omarchy plugin clone omarchy.lock
```

That copies the plugin to `~/.config/omarchy/plugins/seb.lock`, enables it, and disables `omarchy.lock`. Then in `~/.config/omarchy/plugins/seb.lock/Service.qml` make the blank timer a no-op:

```qml
function armBlankTimer() {
  // Lock-only: skip DPMS/blank. This AMD iGPU + Apple Studio Display
  // wedges after `omarchy-brightness-display off` (hl.dsp.dpms disable).
}

function runWake() {
  if (!wakeProcess.running) wakeProcess.running = true
}

function runBlank() {
  logEvent("blank-skipped: lock-only")
}
```

`keepLoaded` lock code only loads on a shell restart:

```bash
omarchy restart shell
```

Lock still happens (idle at 5 minutes, or Super+Ctrl+L / `omarchy system lock`). The panel stays lit behind the lock screen.

### Practical setup on this machine

| Behavior | Setting |
| --- | --- |
| Screensaver | On (150s) |
| Auto-lock | On (300s) |
| DPMS / display off | Off (cloned lock skips it) |
| Suspend | OK — use Sleep / `systemctl suspend` |
| Hibernate | Ignore |

### Apply / confirm

```bash
omarchy plugin list --json | jq '.[] | select(.id | test("lock")) | {id,enabled,clonedFrom}'
omarchy-shell idle status | jq '{enabled,stayAwake,screensaver,lock}'
omarchy-shell lock status | jq '{locked,passwordPam,lastEvent}'
hyprctl monitors -j | jq '.[] | {name,make,model,dpmsStatus}'
```

Expect `seb.lock` enabled, `omarchy.lock` disabled, idle `enabled: true`, `stayAwake: false`, screensaver 150, lock 300, `dpmsStatus: true`.

Do **not** test with `omarchy brightness display off` or `hyprctl dispatch dpms off` — that is the command that bricks this display.

To confirm lock-only by hand: Super+Ctrl+L, wait at least 6 seconds. The lock screen should stay visible (panel still lit). `hyprctl monitors -j` should still show `"dpmsStatus": true`. Unlock as usual.

Omarchy updates do **not** overwrite the clone, but the clone can go stale if upstream lock-screen code changes. If lock breaks after an update: `omarchy plugin remove seb.lock --yes`, clone again, re-apply the `armBlankTimer` no-op, `omarchy restart shell`.
