# Omarchy Stack

Personal Omarchy / Hyprland setup notes. Goal: capture each system tweak here so the machine can be reproduced later.

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

## Known issues

Observe stock Omarchy first, then measure, then maybe a small fix. Do not pile display-sleep workarounds onto the machine until the failure is understood. A previous approach solved “don’t lose windows overnight” by keeping the PC fully on (lock + black frame + backlight 0%, never s2idle). That is a lot of machinery for a habit you can change (shutdown) until you know what is actually broken.

### Studio Display + AMD USB4

This Beelink SER9 (Ryzen 7 255 / Radeon 780M) talks to the **Apple Studio Display** over USB4 (`DP-5`, 5120×2880), not a dumb DisplayPort cable. Two host actions drop that tunnel; amdgpu then fails DPIA AUX and the panel stays black until a **power cycle**:

1. **DPMS off** — stock Omarchy lock blanks the output about 5s after lock.
2. **s2idle** — power-menu Suspend. This CPU has no S3; “suspend” is light sleep. Same tunnel death.

Resume logs look like:

```text
amdgpu: Skip DMUB HPD IRQ callback in suspend/resume
amdgpu: DPIA AUX failed on 0x600(1), error 7
```

A **full shutdown/reboot** re-inits the GPU. That is a different path. If the panel comes back after a clean boot, shutdown is fine. If it doesn’t, the display itself needs a power cycle even on cold start — worth knowing, and a 30-second test.

### Shutdown may not actually power off the Beelink

Same hardware family (USB4 + Studio Display + SER9), **not** the s2idle AUX failure. That bug blacks the *panel* while Linux keeps running. This one is: did ACPI S5 cut power to the mini PC?

Linux does *start* a real poweroff (`The system will power off now!`, then unmounts). The persistent journal always stops there, even on a clean shutdown, so missing a “Powering off” line proves nothing. What the logs do show:

- Tue 21:08 — poweroff started. Next boot **Wed 03:50**. That 6.5h gap is either a hang (box never went off) or a successful off plus something turning it back on.
- Thunderbolt (`NHI0` / `NHI1`) and several USB controllers are **wakeup-enabled**. The Studio Display sits on that USB4 bus; an Apple MagSafe Charging Case has also shown up through the display’s USB hub. Either can keep the box from staying off.
- Omarchy sets `HandlePowerKey=ignore`. A **short press of the Beelink power button does nothing**. Only the power menu (or a long hold = hard cut) shuts down. Easy to think “shutdown doesn’t work” if you used the button.

**One test, no extra config:** Power menu → Shutdown. Watch the **Beelink** (LED / fans), not the display, for 60 seconds. Do not touch the power button.

| What you see | Meaning |
| --- | --- |
| LED/fans die and stay dead | Shutdown works. Black panel was just the display. |
| LED/fans die, then the box comes back | S5 worked, then TB/USB woke it. Separate from “display won’t wake”. |
| LED/fans never die | Shutdown hung at ACPI. Also separate; often Thunderbolt. |

Long-hold to force off only after that minute, so the log still shows a clean poweroff attempt.

### Workspaces are not persisted

Hyprland/Omarchy do **not** restore windows after a reboot. Empty numbered workspaces come back; Ghostty/Brave/Zed do not. There are third-party session restorers, and they are their own project (relaunch apps, guess cwd, miss browser tabs). Not a one-line Omarchy setting. So “persist workspaces” is not a substitute for suspend until you’ve decided you want that product.

### What to measure, in this order

| Test | How | What you learn |
| --- | --- | --- |
| 1. Lock only | Super+Ctrl+L, wait 10s | Does stock DPMS-off already black the panel? Does a key bring it back? |
| 2. Short suspend | Power menu Suspend, wait 20s, move mouse/keyboard | Does a *short* s2idle come back? (Sometimes short resume works and overnight doesn’t.) |
| 3. Overnight suspend | Only if 2 worked | The original failure. If it wedges, you have a clean repro. |
| 4. Shutdown (Beelink) | Power menu Shutdown. Watch LED/fans 60s. Do not press the power button. | Does the mini PC actually stay off? See table above. |
| 5. Shutdown (display) | After a real power-off, power on from the button | Does a cold GPU init bring the Studio Display back without touching *its* power button? |
| 6. Logs if it wedges | After you get a picture again: `journalctl -b -1 \| grep -iE 'amdgpu\|DPIA\|suspend\|Studio\|power off'` | AUX errors vs a poweroff that never finished. |

If test 1 or 2 wedges the panel, don’t keep experimenting that night — power-cycle the display (or the mini PC). That’s the recovery, not a deeper Linux trick.

**Omarchy updates** might improve lock/idle, not this hardware bug. The DPIA AUX failure is amdgpu + USB4 + this display. A kernel/`amdgpu` update is the plausible upstream fix; an Omarchy theme/lock tweak is not.

Until then, the simple policy is: **shutdown when you’re done**, accept a fresh session in the morning, and treat Suspend as an experiment, not a habit. If you later want session restore, that’s a separate, explicit feature — not mixed into display-sleep hacks.
