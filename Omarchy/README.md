# Omarchy Stack

Personal Omarchy / Hyprland setup notes. Goal: capture each system tweak here so the machine can be reproduced later and via OmaStack.dev

## Installed

### Overview

Extra apps on top of the Omarchy stock install. Reproduce them with [`install-apps.sh`](install-apps.sh) (sudo for Flea and MEGA). Do not run that script until you mean to install.

| Component | Install |
| --- | --- |
| Ghostty | `omarchy install terminal ghostty` |
| Brave Origin | `omarchy install browser brave-origin` |
| Zed | `omarchy install editor zed` |
| Flea | `omarchy pkg aur add flea-bin` ([flea.md](flea.md)) |
| OmaMail | `omarchy plugin add https://github.com/huacnlee/omamail.git --enable` |
| Teams | Web app: https://teams.microsoft.com/v2/ |
| Telegram | Web app: https://web.telegram.org/k/ |
| MEGA Desktop | official `megasync` Arch package ([mega.md](mega.md)) |
| MEGA CMD | official `megacmd` Arch package ([mega.md](mega.md)) |

### App Defaults

The Omarchy `install` commands set the terminal, browser, and editor. Flea sets the file manager with its own command.

| Role | Choice | Set with |
| --- | --- | --- |
| Terminal | Ghostty | `omarchy default terminal ghostty` |
| Browser | Brave Origin | `omarchy default browser brave-origin` |
| Editor | Zed | `omarchy default editor zed` |
| Agent | Grok | `omarchy default agent grok` |
| File manager | Flea | `flea --default` |

### App Specifics

- File manager Flae: [flea.md](flea.md)
- Cloud drive MEGA: [mega.md](mega.md)

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

## Keybindings

Personal overrides live in `~/.config/hypr/bindings.lua` (loaded after Omarchy defaults). Check current bindings with `omarchy menu keybindings --print`. If a key already has a default, `hl.unbind(...)` it before the new `o.bind(...)`.

Super+Shift+F and Super+Alt+Shift+F belong to Flea ([flea.md](flea.md)). `flea --default` writes them between the `flea --default` marker lines, and `flea --default off` removes that block whole. Leave the marker block alone when editing other bindings.

Super + Shift + G → Lazygit (cwd of the open terminal): [lazygit.md](lazygit.md)

## Natural scroll

Omarchy defaults to traditional scrolling. For natural scrolling set `input.natural_scroll` and `input.touchpad.natural_scroll` in `~/.config/hypr/input.lua`:
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

Hyprland reloads on save. Force apply with `hyprctl reload`, then check `hyprctl configerrors`.

## Other

- CPU Smart Fan (quiet curve): [fan.md](fan.md)
- Brightness Control: [brightness.md](brightness.md)
- git authentication via `gh`: [git-auth.md](git-auth.md)
- Known issues (hardware failures, alternative PCs, and verdict): [known-issues.md](known-issues.md)
