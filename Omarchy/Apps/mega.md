# MEGA Apps

## MEGA Cloud Drive

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

## Updating MEGA

Update when the Mac apps move, and install that same version here. The directory listing has a versioned file per build, for example `megasync-6.6.2-1-x86_64.pkg.tar.zst` and `megacmd-2.6.0-2-x86_64.pkg.tar.zst`. The names without a version are whatever MEGA is publishing today. Download the version that matches the Mac, then:

```bash
sudo pacman -U megasync-VERSION-x86_64.pkg.tar.zst
sudo pacman -U megacmd-VERSION-x86_64.pkg.tar.zst
pacman -Q megasync megacmd
grep -n DEB_Arch_Extra /etc/pacman.conf || echo "no MEGA repo"
```

An upgrade of a package that is already installed goes through `post_upgrade`. With MEGA’s key already in the keyring, that does not append the block again. If `DEB_Arch_Extra` shows up in `pacman.conf`, delete it with the same `sed` as the install. Update the desktop app and the CLI together. `omarchy update` does not upgrade these two.

Stock Omarchy’s file manager is Nautilus. This machine uses Flea and removes Nautilus (see [Uninstalled](README.md#uninstalled)). `nautilus-megasync` from the same directory stays uninstalled.

## MEGAsync UI on the Studio Display

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

