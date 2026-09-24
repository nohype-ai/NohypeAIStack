# Omarchy Stack

Personal Omarchy / Hyprland setup notes. Goal: capture each system tweak here so the machine can be reproduced later and via OmaStack.dev

## Installed Components

### Overview

Extra apps on top of the Omarchy stock install. Reproduce them with [`install-apps.sh`](install-apps.sh) (sudo for Flea and MEGA). Do not run that script until you mean to install.

| Component | Install |
| --- | --- |
| Ghostty | `omarchy install terminal ghostty` |
| Brave Origin | `omarchy install browser brave-origin` |
| Zed | `omarchy install editor zed` |
| Flea | `omarchy pkg aur add flea-bin` |
| OmaMail | `omarchy plugin add https://github.com/huacnlee/omamail.git --enable` |
| Teams | Web app: https://teams.microsoft.com/v2/ |
| Telegram | Web app: https://web.telegram.org/k/ |
| MEGA Desktop | official `megasync` Arch package (see below) |
| MEGA CMD | official `megacmd` Arch package (see below) |

### App Defaults

The Omarchy `install` commands set the terminal, browser, and editor. Flea sets the file manager with its own command.

| Role | Choice | Set with |
| --- | --- | --- |
| Terminal | Ghostty | `omarchy default terminal ghostty` |
| Browser | Brave Origin | `omarchy default browser brave-origin` |
| Editor | Zed | `omarchy default editor zed` |
| Agent | Grok | `omarchy default agent grok` |
| File manager | Flea | `flea --default` |

### Flea

Flea is the file manager. The package is `flea-bin` on the AUR: the tagged release, already built for x86_64. `omarchy update` installs a new release minutes after it ships.

```bash
omarchy pkg aur add flea-bin
flea --default
```

`flea-bin`, the repository package `flea`, and `flea-git` each install `/usr/bin/flea`. This machine uses `flea-bin` only.

Run `flea --default` in a terminal inside the session. It sets the `inode/directory` handler, Show in folder, Super+Shift+F, Super+Alt+Shift+F, and the file chooser, then restarts `xdg-desktop-portal` so file dialogs follow at once. When `~/.config/xdg-desktop-portal/hyprland-portals.conf` exists, the chooser line goes in that file, which is the one the portal reads. `flea --default off` puts the previous chooser back.

[`install-apps.sh`](install-apps.sh) runs those two commands, then `systemctl --user restart xdg-desktop-portal`. That extra restart covers a script run whose output is captured: `flea --default` restarts the portal only when its own output is a terminal.

### MEGA Apps

#### MEGA Cloud Drive

MEGA is not in Arch `extra` or the Omarchy repo, so `omarchy pkg add megasync` cannot install it. The download page calls the directory “Arch Extra”; that is MEGA’s file list at `https://mega.nz/linux/repo/Arch_Extra/x86_64/`, which is separate from Arch’s `extra`. Skip Homebrew, AUR `megasync` (slow source build, icu breakage), and `megasync-bin` (often behind). Install MEGA’s own packages so this machine matches the macOS apps.

`wget` is not installed on stock Omarchy. `curl` is. Desktop, then the CLI:

```bash
curl -fL -O https://mega.nz/linux/repo/Arch_Extra/x86_64/megasync-x86_64.pkg.tar.zst
sudo pacman -U megasync-x86_64.pkg.tar.zst
sudo sed -i '/###REPO for MEGA###/,/###END REPO for MEGA###/d' /etc/pacman.conf

curl -fL -O https://mega.nz/linux/repo/Arch_Extra/x86_64/megacmd-x86_64.pkg.tar.zst
sudo pacman -U megacmd-x86_64.pkg.tar.zst
sudo sed -i '/###REPO for MEGA###/,/###END REPO for MEGA###/d' /etc/pacman.conf
```

Each fresh `pacman -U` runs MEGA’s `post_install`, which appends this to `/etc/pacman.conf`:

```ini
###REPO for MEGA###
[DEB_Arch_Extra]
SigLevel = Required TrustedOnly
Server = https://mega.nz/linux/repo/Arch_Extra/$arch
###END REPO for MEGA###
```

That block is MEGA’s update channel. A later `pacman -Syu` would upgrade `megasync` and `megacmd` from the same directory, and the script locally signs MEGA’s key so those packages verify. The script does not download `DEB_Arch_Extra.db`. It cannot from there: `post_install` runs while pacman holds its database lock. MEGA’s Arch instructions never add a sync step afterwards. Until that database file exists, pacman refuses every install with `could not find database`, including the `megacmd` install and `omarchy pkg add`.

We delete the block. MEGA requires the same desktop version on every computer, and this machine should stay on the version installed on the Mac. Syncing the database would let `omarchy update` move Linux ahead of the Mac, and a bad signature on that repo would stop the whole system update. The `sed` runs after each fresh `pacman -U`, before the next pacman command. [`install-apps.sh`](install-apps.sh) does that even when the package was already installed, so a re-run clears a block left by a stopped install. `pacman -Rs megasync` does not remove the block.

#### Updating MEGA

Update when the Mac apps move, and install that same version here. The directory listing has a versioned file per build, for example `megasync-6.6.2-1-x86_64.pkg.tar.zst` and `megacmd-2.6.0-2-x86_64.pkg.tar.zst`. The names without a version are whatever MEGA is publishing today. Download the version that matches the Mac, then:

```bash
sudo pacman -U megasync-VERSION-x86_64.pkg.tar.zst
sudo pacman -U megacmd-VERSION-x86_64.pkg.tar.zst
pacman -Q megasync megacmd
grep -n DEB_Arch_Extra /etc/pacman.conf || echo "no MEGA repo"
```

An upgrade of a package that is already installed goes through `post_upgrade`. With MEGA’s key already in the keyring, that does not append the block again. If `DEB_Arch_Extra` shows up in `pacman.conf`, delete it with the same `sed` as the install. Update the desktop app and the CLI together. `omarchy update` does not upgrade these two.

Stock Omarchy’s file manager is Nautilus. This machine uses Flea and removes Nautilus (see Uninstalled). `nautilus-megasync` from the same directory stays uninstalled.

#### MEGAsync UI on the Studio Display

MEGAsync is a Qt5 X11 app. On Hyprland it prints `Avoiding wayland` and runs under XWayland — that is expected. Two separate bugs show up on this machine (Beelink SER9, Studio Display `DP-5` at 5120×2880, Hyprland scale 2).

**Login window shrinks to 1×1 and vanishes.** Force X11:

```bash
QT_QPA_PLATFORM=xcb megasync
```

**Chrome is tiny / tray popup is unusable.** Omarchy sets `xwayland:force_zero_scaling` so XWayland apps see the raw 5K framebuffer. GTK gets `GDK_SCALE=2` from `~/.config/hypr/monitors.lua`. Qt does not, so MEGAsync paints at 1×. MEGA’s own Display settings do not fix compositor scale.

Do **not** set `QT_SCALE_FACTOR` globally in Hyprland — native Qt Wayland apps would then scale twice. Wrap MEGAsync only.

**Files:**

| File | Role |
| --- | --- |
| `~/.config/autostart/megasync.desktop` | starts MEGAsync at login |
| `~/.local/share/applications/megasync.desktop` | app menu / launcher |
| `~/.config/omarchy/shell.json` | hide MEGAsync from the bar tray |
| `~/.config/hypr/hyprland.lua` | status window rules |

**Desktop `Exec` (both `.desktop` files):**

```ini
Exec=env QT_QPA_PLATFORM=xcb QT_SCALE_FACTOR=2 /usr/bin/megasync
```

MEGA may rewrite the autostart file back to bare `megasync` after an update. Put the `env …` line back if the UI goes tiny again.

A bare `megasync` in a terminal also skips the scale. Use the same `env` line, or launch from the app menu.

**Status window (not Settings).** MEGAsync is hidden in the Omarchy bar tray so the icon is not a click target. Open it from the Omarchy menu (Super+Space → MEGAsync). That shows a frameless Qt card inside an oversized XWayland surface. MEGA paints the card at the top-left of that surface. Without rules, the popup:

- shows a Hyprland tile much larger than the card MEGA actually draws
- hides as soon as it loses focus
- lands off-center if you `center` the whole oversized surface (the card is only the top-left of it)

Settings is a normal dialog (`title` is not exactly `MEGAsync`) and is left alone.

**Hide the tray icon** in `~/.config/omarchy/shell.json` (`omarchy.tray`):

```json
{
  "hidden": ["MEGAsync"],
  "id": "omarchy.tray",
  "pinned": []
}
```

Or right-click the tray chevron → Hide on MEGAsync. The shell hot-reloads `shell.json` on save.

**Change** in `~/.config/hypr/hyprland.lua` (after Omarchy defaults):

```lua
-- MEGAsync status is a frameless Qt card inside an oversized XWayland
-- window. MEGA paints the card at the top-left of that surface, so size
-- the window to the card and center it. Settings is a normal dialog
-- (different title) and should keep decorations.
o.window({ class = "MEGAsync", title = "^MEGAsync$" }, {
  float = true,
  stay_focused = true,
  decorate = false,
  no_shadow = true,
  no_blur = true,
  rounding = 0,
  tag = "-default-opacity",
  opacity = "1.0 override 1.0 override",
  size = {400, 600},
  center = true,
})
```

| Rule | Why |
| --- | --- |
| `stay_focused` | MEGA hides the card on focus loss; keep it until you close it |
| `decorate` / `no_shadow` / `no_blur` / opacity 1 | Hide Hyprland’s empty tile around the frameless card |
| `size = {400, 600}` | Match the card, not the oversized X11 window (1300×900) |
| `center` | Always the middle of the screen |

**Apply:** Hyprland reloads on save. Force with `hyprctl reload`, then check `hyprctl configerrors`. Quit MEGAsync from its own UI and start it again from the Omarchy menu so it picks up `QT_SCALE_FACTOR=2`. Confirm the process has the vars:

```bash
tr '\0' '\n' < /proc/$(pgrep -n megasync)/environ | grep -E 'QT_SCALE_FACTOR|QT_QPA_PLATFORM'
```

Expect `QT_SCALE_FACTOR=2` and `QT_QPA_PLATFORM=xcb`. Super+Space → MEGAsync: the status card should appear in the center of the screen and stay until you close it.

## Uninstalled

- Stock software this setup removes
- [`install-apps.sh`](install-apps.sh) does not do the uninstalls
- `omarchy pkg drop` skips a name that is already gone, then runs `sudo pacman -Rns --noconfirm`
- `omarchy reinstall pkgs` installs the stock list again

| Software | GB | Remove with |
| --- | --- | --- |
| Steam | 2.46 | `omarchy remove gaming steam` |
| NVIDIA userspace | 1.40 | `omarchy pkg drop nvidia-utils lib32-nvidia-utils` |
| Chromium | 0.41 | `omarchy pkg drop chromium` |
| Signal | 0.40 | `omarchy pkg drop signal-desktop` |
| RetroArch database | 0.33 | `omarchy pkg drop libretro-database-git` |
| Nautilus | 0.03 | `omarchy pkg drop nautilus nautilus-python` |

Drop Nautilus after `flea --default`. `nautilus-python` depends on `nautilus`, and both are explicit stock installs, so the command names both.

To free up that space on disk, you may want to delete system snapshots also, using `snapper`:
```bash
sudo snapper -c root list
sudo snapper -c root delete 1-5
```

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

Super+Shift+F and Super+Alt+Shift+F belong to Flea. `flea --default` writes them between the `flea --default` marker lines, and `flea --default off` removes that block whole. Leave the marker block alone when editing other bindings.

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

Observe stock Omarchy first, then measure, then maybe a small fix.

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

Do not pile display-sleep workarounds onto the machine until the failure is understood. A previous approach solved “don’t lose windows overnight” by keeping the PC fully on (lock + black frame + backlight 0%, never s2idle). That is a lot of machinery for a habit you can change (shutdown) until you know what is actually broken.

#### What to measure, in this order

| Test | How | What you learn |
| --- | --- | --- |
| 1. Lock only | Super+Ctrl+L, wait 10s | Does stock DPMS-off already black the panel? Does a key bring it back? |
| 2. Short suspend | Power menu Suspend, wait 20s, move mouse/keyboard | Does a *short* s2idle come back? (Sometimes short resume works and overnight doesn’t.) |
| 3. Overnight suspend | Only if 2 worked | The original failure. If it wedges, you have a clean repro. |
| 4. Shutdown (Beelink) | Power menu Shutdown. Watch LED/fans 60s. Do not press the power button. | Does the mini PC actually stay off? See [Shutdown may not actually power off the Beelink](#shutdown-may-not-actually-power-off-the-beelink). |
| 5. Shutdown (display) | After a real power-off, power on from the button | Does a cold GPU init bring the Studio Display back without touching *its* power button? |
| 6. Logs if it wedges | After you get a picture again: `journalctl -b -1 \| grep -iE 'amdgpu\|DPIA\|suspend\|Studio\|power off'` | AUX errors vs a poweroff that never finished. |

If test 1 or 2 wedges the panel, don’t keep experimenting that night — power-cycle the display (or the mini PC). That’s the recovery, not a deeper Linux trick.

The DPIA AUX failure is amdgpu + USB4 + this display. A kernel/`amdgpu` update is the real fix. Omarchy can still **avoid** the path (don’t DPMS-off this panel on lock). Theme/lock chrome will not. See [Who can fix these](#who-can-fix-these-and-what-omarchy-could-do).

Until then, the simple policy is: **shutdown when you’re done**, accept a fresh session in the morning, and treat Suspend as an experiment, not a habit. Forced power-offs while the box is wedged are how the AX200 Wi-Fi/Bluetooth failures below have shown up. Session restore is a separate issue — not mixed into display-sleep hacks.

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

### Intel AX200 Wi-Fi gone until CMOS reset

Same Beelink SER9, same Intel AX200 (`02:00.0`, PCI `8086:2723`) as the Bluetooth issue below. This one is **the PCI Wi-Fi function hung**, not a missing `iwlwifi` package and not the USB Bluetooth firmware timeout.

**Symptom:** no Wi-Fi interface (`wlp2s0` gone). NetworkManager has nothing to connect. `lspci` still shows the AX200. Reboots do not bring it back.

**Log line that proves it:**

```text
iwlwifi 0000:02:00.0: CSR_RESET = 0x10
iwlwifi 0000:02:00.0: probe with driver iwlwifi failed with error -110
```

`-110` is `ETIMEDOUT` again. `CSR_RESET = 0x10` means the chip is sitting in reset; the driver dumps “Host monitor” registers and gives up. The PCI device is enumerated, so this is not “the card fell off the bus.” It is a wedged radio that Linux cannot talk to.

**Why this happens (generally):** unclean power cut to the AX200. On this machine that lines up with the Studio Display mess above: lock/suspend blacks the panel, shutdown may not actually cut Beelink power, and the recovery is often a **long-hold** of the power button. That hard cut can leave the Wi-Fi MCU in a state a normal reboot does not clear. Beelink’s own SER9 notes for “Wi-Fi not detected” are CMOS clear, not a driver reinstall.

If Wi-Fi still works and only Bluetooth is missing, that is the [Bluetooth subsection](#intel-ax200-bluetooth-no-default-controller) (`reload-btusb.sh`). Do not CMOS-reset for that.

**What does not fix it:** reboot, `modprobe -r iwlwifi && modprobe iwlwifi`, NetworkManager restart. Tried across four boots on this occurrence; every one logged the same `-110`.

**Recovery that worked:** CMOS reset of the Beelink. Front-panel **CLR CMOS** pinhole (paperclip). Beelink’s procedure:

1. Power off. Unplug the DC barrel (and the display cable if you are following their text).
2. Press CLR CMOS for about **10 seconds**.
3. Wait several minutes (they say ~10).
4. Plug back in, power on. First boot after a CMOS clear can take a minute.

That restores BIOS defaults. Re-check anything you had changed in firmware setup.

**This occurrence (2026-09-16):** Afternoon after the Studio Display / shutdown experiments. Boot 14:43: `probe with driver iwlwifi failed with error -110`, `CSR_RESET = 0x10`. Same failure at 15:29 (retry on that boot), then 15:39, 15:44, 15:59. Next boot **15:59:17** loaded `iwlwifi` firmware `77.aa2dd297.0` and renamed `wlan0` → `wlp2s0` — after the CMOS reset.

### Intel AX200 Bluetooth: no default controller

Same Beelink SER9, same AX200 card as the Wi-Fi issue above. **Not** the Studio Display USB4 bug, and **not** a CMOS-level hang: here Wi-Fi still works. Bluetooth is a USB function on that card (`8087:0029` on `usb 1-5`), not a dongle.

**Symptom:** Omarchy Bluetooth panel empty. `bluetoothctl list` / `show` print `No default controller available`. Wi-Fi still works. `bluetooth.service` is running. `rfkill` shows `hci0` unblocked. `/sys/class/bluetooth/hci0` exists. The USB device is still enumerated.

That means the kernel has a zombie `hci0` and BlueZ has nothing to power on. It is not “Bluetooth was switched off.”

**Log line that proves it** (this boot, 2026-09-19 12:59:41, ~2s after bluetoothd started):

```text
Bluetooth: hci0: Reading Intel version command failed (-110)
```

`-110` is `ETIMEDOUT`. After a real power-off the AX200 BT MCU is in bootloader and Linux must upload `intel/ibt-20-1-3.sfi`. The first Intel version command timed out, so firmware never loaded. The USB device then autosuspended (`power/control: auto`, 2s delay). First time this `-110` appears in the persistent journal. The previous boot (02:10 the same day) loaded firmware normally.

Healthy cold-boot sequence looks like:

```text
Bluetooth: hci0: Found device firmware: intel/ibt-20-1-3.sfi
Bluetooth: hci0: Firmware loaded in … usecs
Bluetooth: hci0: Device booted in … usecs
```

Some reboots skip the download and log `Firmware already loaded` — the MCU stayed powered across the reboot. That is a different path from a full shutdown.

**Why this happens (generally):** USB timing / autosuspend racing firmware download on AMD xHCI, or a hung BT MCU after power cut. Once the version command times out, userspace cannot talk the chip back to life.

**What does not fix it:** `omarchy restart bluetooth`. That helper only `rfkill unblock bluetooth`. Tried twice on this occurrence; no-op, as expected. Do not reboot first either: this occurrence *was* already a cold start after overnight shutdown, and it still timed out. A soft reboot sometimes leaves the MCU powered (`Firmware already loaded`) and can recover *or* leave it wedged.

**Recovery, in this order — no extra config until one of these is measured:**

```bash
# 1. Confirm the timeout and that the USB function is still there
journalctl -b | grep -F 'Reading Intel version command failed'
lsusb | grep 8087
bluetoothctl list

# 2. Reload btusb (re-runs firmware init, keeps the session)
./reload-btusb.sh
```

[`reload-btusb.sh`](reload-btusb.sh) is the same `rmmod` / `modprobe btusb` plus before/after logs. Run it from this directory; it needs sudo.

| Result after reload | Meaning | Next |
| --- | --- | --- |
| Firmware loaded / device booted, `bluetoothctl list` shows a controller | Transient firmware timeout. Done. | Leave autosuspend alone until it repeats. |
| Same `-110` again, or still no controller | MCU still wedged, or USB did not actually reset. | USB reset of `1-5` (below). |
| Reload fails / still dead after USB reset | Needs a real power cut to the card. | Full **power-off** (watch the Beelink LED), then power on. Soft reboot is the weaker option. |

USB reset if step 2 is not enough:

```bash
echo 0 | sudo tee /sys/bus/usb/devices/1-5/authorized
echo 1 | sudo tee /sys/bus/usb/devices/1-5/authorized
sleep 3
bluetoothctl list
```

Do **not** disable USB autosuspend or add a kernel quirk yet. One timeout is a race, not a policy. After a successful reload the USB function went back to `runtime_status: suspended` and the controller stayed up — so autosuspend after firmware load is fine; the race is only during the bootloader handshake.

**This occurrence (2026-09-19):** Cold boot 12:59 after shutdown at 02:30. `-110` at 12:59:41. Wi-Fi on `FRIZZ`. `omarchy restart bluetooth` ×2 did nothing.

`sudo rmmod btusb && sudo modprobe btusb` recovered it without a reboot. Firmware loaded in ~1.4s, same sequence as a healthy cold boot (`ibt-20-1-3.sfi`, revision 0.3 build 193 week 33 2024). BlueZ then had `Controller A8:59:5F:9C:59:04 beelink [default]`, `Powered: yes`. USB reset and power-off were not needed.

### Modern standby never reaches its deepest idle

Suspend on this SER9 is already modern standby. The firmware advertises S0, S4, and S5, and no S3. The kernel logs `Low-power S0 idle used by default for system suspend`, and `/sys/power/mem_sleep` is `[s2idle]`. Power-menu Suspend runs `systemctl suspend`. No `suspend-off` flag is set, so the item is in the menu.

The machine wakes back to the desktop, and the idle it reached is shallower than the one the firmware claims. Eight s2idles from Sun 2026-09-20 21:33 through Thu 2026-09-24 02:34, and another at 13:07 that same morning, all logged:

```text
amd_pmc AMDI0009:00: Last suspend didn't reach deepest state
```

Every wake also aborted the embedded-controller method the firmware runs on the way out of sleep:

```text
ACPI Error: Region EmbeddedControl (ID=3) has no handler
ACPI Error: Aborting method \_SB.PCI0.SBRG.EC0.UPHK due to previous error (AE_NOT_EXIST)
ACPI Error: Aborting method \_SB.PEP._DSM due to previous error (AE_NOT_EXIST)
```

The session came back each time, including on the HDMI Sony TV, and Wi-Fi reassociated after the 13:08 wake. A hibernate half a minute later still entered S4, so this shallow wake does not by itself reproduce the hibernate panic below.

**Dead end.** Nothing on this box can make that idle deep. Suspend is already s2idle. `amd_pmc` workarounds are already on (`disable_workarounds=N`, SMU 76.87.0). No Omarchy setting and no kernel parameter installs the missing EC handler. Beelink ships the board without S3, and AMI `SER9L106` has no option that adds it. Only a BIOS that repairs `EC0.UPHK` / `\_SB.PEP._DSM` would. Until then, Suspend is a light sleep that returns the desktop.

#### Where a BIOS update would show up

This board is AZW SER9, Ryzen 7 255. The running firmware is AMI `SER9L106`, dated 2026-07-10 (`/sys/class/dmi/id/bios_version` and `bios_date`).

Public files for this CPU live in one folder:

[https://dr.bee-link.cn/?dir=uploads%2FSER%2FSER9-H255%2FBIOS](https://dr.bee-link.cn/?dir=uploads%2FSER%2FSER9-H255%2FBIOS)

Only the subfolders whose names say **Only-SER9L10X-can-flash** match this board. As of 2026-09-24 the newest of those is `SER9L106` (uploaded 2026-07-13), which is what is already installed. The `SER9T50X` folders in that same directory are a different firmware. The HX 370 packages (`T2xx`, `T4xx`, `V2xx`) and SER9 MAX are other machines. Flashing one of those has bricked SER9s; a CMOS clear does not always bring the board back. Beelink’s quarterly posts, such as [BIOS Update Summary For Q1 2026](https://www.bee-link.com/blogs/all/bios-update-summary-for-q1-2026), mix all of those models in one list. Use them as a changelog, then confirm the file is an `SER9L10X` build newer than `SER9L106`. Forum support often asks for a photo of the BIOS main page and sends a zip by private message. Check the version prefix on that zip yourself. They have sent the wrong image before.

When a newer `SER9L10X` folder appears, it contains a zip and a PDF named like `Use-USB-to-flash-BIOS`. Follow that PDF. Beelink’s method is their USB stick procedure, not a flash from inside Omarchy. Secure Boot on this machine is already off, which those tutorials require. Do not cut power while it flashes.

### Hibernate panicked once, then resumed

Thu 2026-09-24 02:57:29, power menu, HDMI Sony TV. The journal ends on:

```text
PM: hibernation: hibernation entry
```

Hard power-off. The 12:02 boot logged `PM: Image not found (code -22)` and had no `HibernateLocation`. The signature was never written. The fresh desktop is [Workspaces are not persisted](#workspaces-are-not-persisted). That session had been up since Sun 20 Sep: Flea, Zed, Brave Origin, Ghostty, and the shell with Omamail. `kdenlive` pid 495202 was still running from 13:52 the previous afternoon after its window was closed; the kernel never names it. Swap was already configured (`resume=/dev/mapper/root resume_offset=1950296`). Not the empty `resume_offset` bug.

Same day, still platform mode, with `loglevel=7 no_console_suspend`: a 12:59 hibernate on a 9-minute Ghostty-only boot woke from S4 at 13:00, same session. After the shallow s2idle above, a 13:08 hibernate woke from S4 at 13:09, same session. Both resumes logged `iwlwifi CSR_RESET = 0x10` and the interface associated again within seconds. One short suspend does not reproduce the panic. The test command line (`loglevel=7 no_console_suspend`) was put back to `quiet splash`. The stock file remains `omarchy-defaults.conf.before-hibernate-test`.

### Workspaces are not persisted

Hyprland/Omarchy do **not** restore windows after a reboot. Empty numbered workspaces come back; Ghostty/Brave/Zed do not. There are third-party session restorers, and they are their own project (relaunch apps, guess cwd, miss browser tabs). Not a one-line Omarchy setting. Session restore is not a substitute for the Studio Display suspend investigation above.

### Who can fix these (and what Omarchy could do)

There isn’t one cursed pairing. This box stacks three combos. Beelink’s unique part is AMI BIOS / ACPI / power sequencing, not a mystery extra chip.

| Piece | What it is |
| --- | --- |
| APU | AMD **Ryzen 7 255** (Hawk Point / Phoenix) + **Radeon 780M** (`HawkPoint1`, `1002:1900`) |
| USB4 | AMD **Pink Sardine** Thunderbolt/USB4 NHI (`1022:1668` / `1669`) |
| Wi-Fi / BT | Intel **AX200NGW** — PCIe Wi-Fi + a **USB** Bluetooth function (`8087:0029` on `usb 1-5`) |
| Ethernet | Realtek **RTL8125** (soldered) |
| Board firmware | AMI **SER9L106** (AZW/SER9) |
| Display | Apple **Studio Display** on USB4 (`DP-5`), not a dumb DP cable |

This machine boots **`linux-omarchy` 7.2.5-3** (Limine `BOOT_ORDER` prefers it). Firmware is still stock Arch `linux-firmware` / `linux-firmware-amdgpu`. Owning a kernel means Omarchy can carry quirks, backports, and module options. It does **not** mean they write Beelink’s DSDT or `amdgpu`.

A real **fix** is almost never this machine’s Hyprland config. Local work stays in `~/.config/` and this directory — not `/usr/share/omarchy/` (`omarchy update` overwrites that).

| Issue | Actual fix | What Omarchy could do | What this machine can do locally | Cannot |
| --- | --- | --- | --- | --- |
| Studio Display black on lock/suspend (`DPIA AUX failed`) | **AMD `amdgpu`** (+ DMUB). Apple’s USB4 sink will not change for Linux. | Don’t DPMS-off USB4/Studio Display on lock; don’t sell s2idle as Suspend on no-S3 APUs. Carry an `amdgpu` USB4/DPIA backport **if** one lands upstream. | Idle/lock policy in `~/.config` (avoid the path). | Beelink. Theme/lock chrome. |
| Shutdown doesn’t stay off / long-hold | **Beelink AMI BIOS** (ACPI S5, `NHI0`/`NHI1` wakeup). | Turn off USB4 wakeup as a SER9 quirk; hide Suspend; `HandlePowerKey` UX. | Disable specific wakeup sources if you choose to. | Omarchy cannot make S5 cut the DC rail. |
| Modern standby never deepest; EC handler missing on wake | **Beelink AMI BIOS only** (`EC0.UPHK` / `\_SB.PEP._DSM`). | Don’t describe menu Suspend as deep sleep on SER9. | Dead end. Already s2idle; `amd_pmc` workarounds already on. | A local quirk, a menu change, or a BIOS toggle that adds S3. |
| Hibernate panicked once; two later S4 cycles resumed | Unknown. The 02:57 oops was not saved. Platform S4 woke the same session at 13:00 and again at 13:09, the second time after one shallow s2idle. | Don’t treat that single panic as proof SER9 cannot hibernate. | Shutdown mode is untested. Quiet splash is restored. | The empty `resume_offset` bug. |
| Wi-Fi gone, `CSR_RESET`, CMOS | **Beelink BIOS / board power** (no rail-reset on reboot; D3cold). Same class as soldered RTL8125 vanishing until CLR CMOS on Windows. | Detect probe `-110` and tell the user to CLR CMOS / unplug DC. | CMOS pinhole. Unplug DC. Don’t hard-cut. | `iwlwifi` cannot talk to a chip in reset. |
| Bluetooth `-110`, Wi-Fi still up | **Kernel `btusb`/`btintel`** (USB autosuspend vs firmware load on AMD xHCI). | `omarchy restart bluetooth` reloads `btusb` when there is no controller; udev `8087:0029` `power/control=on`; kernel `btusb.enable_autosuspend=0` or a device quirk. | [`reload-btusb.sh`](reload-btusb.sh). Optional udev if it repeats. | CMOS is the wrong hammer. |
| Power button does nothing | **Omarchy** (`HandlePowerKey=ignore` in `/etc/systemd/logind.conf.d/10-ignore-power-button.conf`) | Short press → poweroff or power menu. | User logind drop-in. | Not a hardware bug. |
| Workspaces empty after boot | **Hyprland/Omarchy product** | Session restore as an explicit feature. | Third-party restorer, if you want that product. | Not mixed into display-sleep. |

**Omarchy already has the display hook and does not use it for `off`.** Brightness up/down special-cases Apple panels (`omarchy-brightness-display-apple`). Lock waits 5s, then `omarchy-brightness-display off`, which is always:

```text
hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })'
```

That is the DPMS-off that kills the USB4 tunnel. Skipping connector DPMS on this output (dim to 0, or a black lock surface) is the highest-payoff mitigation they fully own. It avoids the bug; it does not teach Pink Sardine to survive DPMS.

**If Omarchy cares, ranked by payoff**

| They ship | Effect |
| --- | --- |
| Don’t DPMS-off Apple USB4 on lock | Stops the common way the panel dies |
| Treat s2idle as unsafe on USB4-only / no-S3 | Stops the other way |
| `omarchy restart bluetooth` reloads `btusb` + udev autosuspend | Fixes the BT case already hit here |
| Newer `amdgpu`/DMUB in `linux-omarchy` **when upstream has a DPIA fix** | Only path to a real display fix |
| Power button → shutdown | Convenience only |
| SER9 DSDT overlay / “fix” CMOS Wi-Fi in the kernel | Theatre; BIOS still owns rail-reset |

Do not pile the local equivalents (idle hacks, wakeup masks, autosuspend-off) onto this machine until one of those is chosen on purpose. The display-sleep pile is exactly what the Studio Display section refuses to build.

## Potential Alternative PCs

A different chip would not clear the list above. The Ryzen 7 255 is a current Hawk Point laptop processor. What is cheap on this box is Beelink’s firmware. What is awkward for Linux is the Studio Display on USB4. A newer or more expensive PC often keeps both.

**Beelink does publish BIOS files**, on [dr.bee-link.cn](https://dr.bee-link.cn/?dir=uploads%2FSER%2FSER9-H255%2FBIOS). This machine’s folder tops out at `SER9L106`, which is already installed, and that file did not repair the embedded controller. The notes are one line (“optimize Wi-Fi”, “solve login network”). The more expensive, newer SER9 with the Ryzen AI 9 HX 370 is in the same catalog and has the same “no S3, suspend never really sleeps” behavior. A download site is not a firmware team.

**GMKtec is the same kind of company.** Boards are often a third-party design (Sixunited and similar), BIOS files are split across support posts, and Linux users end up toggling ACPI wake bits by hand. An EVO-X2 is a faster chip in that same firmware situation.

Mini PCs whose vendors ship a BIOS for one known model, with notes, and then update it:

| Machine | What you actually get |
| --- | --- |
| **System76 Meerkat** | The small one. System76 writes the firmware (coreboot on the open-firmware models), publishes a changelog, and delivers updates through their own tool. The notes include real ACPI and resume fixes. |
| **Framework Desktop** | A small desktop, not a 13 cm cube. Ryzen AI Max. BIOS is on their download page with a version history, and Linux updates go through `fwupd`. They do fix power bugs. They also shipped a laptop BIOS that left some boards unable to boot, so a public update process is not a promise that a flash cannot fail. |
| **Lenovo ThinkCentre Tiny, Dell OptiPlex Micro, HP Elite Mini, ASUS NUC** | Business machines. Look up the exact model or service tag and get a BIOS with a changelog from that vendor’s support site. Sleep is still modern standby, and it is usually less broken than a Beelink AMI image. These are not Linux companies. |

None of those make a Studio Display on USB4 safe. That bug is the AMD or Intel USB4 tunnel plus that display, and it shows up on expensive machines too. What the extra money buys is a vendor that will still be patching the embedded controller next year, and a model name that maps to one firmware instead of eight.
