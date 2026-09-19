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

Extra apps on top of the Omarchy stock install. Reproduce them with [`install-apps.sh`](install-apps.sh) (sudo for MEGA). Do not run that script until you mean to install.

| App | Install |
| --- | --- |
| Ghostty | `omarchy install terminal ghostty` |
| Brave Origin | `omarchy install browser brave-origin` |
| Zed | `omarchy install editor zed` |
| MEGA Desktop | official `megasync` Arch package (see below) |
| MEGA CMD | official `megacmd` Arch package (see below) |

The three Omarchy `install` commands also set those apps as the terminal / browser / editor defaults.

### MEGA Cloud Drive

MEGA is **not** in Arch `extra` or the Omarchy repo, so `omarchy pkg add megasync` fails. The MEGA download page label “Arch Extra” is **their** third-party repo (`[DEB_Arch_Extra]`), not Arch’s `extra`. Do not use Homebrew. Skip AUR `megasync` (slow source build, icu breakage) and `megasync-bin` (often behind). MEGA wants the **same desktop-app version on every machine**, so use their packages to match macOS.

Desktop app:

```bash
wget https://mega.nz/linux/repo/Arch_Extra/x86_64/megasync-x86_64.pkg.tar.zst
sudo pacman -U "$PWD/megasync-x86_64.pkg.tar.zst"
```

CLI (same tool as macOS MEGA CMD):

```bash
wget https://mega.nz/linux/repo/Arch_Extra/x86_64/megacmd-x86_64.pkg.tar.zst
sudo pacman -U "$PWD/megacmd-x86_64.pkg.tar.zst"
```

MEGA writes `wget`; [`install-apps.sh`](install-apps.sh) uses `curl` (already on Omarchy) for the same fetch, then `pacman -U`.

The first `pacman -U` of either package appends MEGA’s repo to `/etc/pacman.conf` and locally-signs their key. After that, `omarchy update` / `pacman -Syu` can upgrade them.

Omarchy’s file manager is Nautilus. Optional integration from the same repo: `nautilus-megasync`. Not part of `install-apps.sh`.

### MEGAsync UI on the Studio Display

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
