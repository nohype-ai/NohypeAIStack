# Omarchy Stack

Personal Omarchy / Hyprland setup notes. Goal: capture each system tweak here so the machine can be reproduced later and via OmaStack.dev

## Installed

### Overview

Extra apps on top of the Omarchy stock install. Reproduce them with [`install-apps.sh`](install-apps.sh) (sudo for Typora, Flea, GNOME Podcasts, WeasyPrint, and MEGA). Do not run that script until you mean to install.

| Component | Install |
| --- | --- |
| Ghostty | `omarchy install terminal ghostty` |
| Brave Origin | `omarchy install browser brave-origin` |
| Zed | `omarchy install editor zed` |
| Typora | `omarchy pkg add typora` |
| GNOME Podcasts | `omarchy pkg add gnome-podcasts` |
| WeasyPrint | `omarchy pkg add python-weasyprint` |
| Flea | `omarchy pkg aur add flea-bin` ([flea.md](flea.md)) |
| OmaMail | `omarchy plugin add https://github.com/huacnlee/omamail.git --enable` |
| Teams | Web app: https://teams.microsoft.com/v2/ |
| Telegram | Web app: https://web.telegram.org/k/ |
| ePost | Web app: https://app.epost.ch/ |
| Grokipedia | Web app: https://grokipedia.com/ |
| Steam | `omarchy install gaming steam` |
| MEGA Desktop | official `megasync` Arch package ([mega.md](mega.md)) |
| MEGA CMD | official `megacmd` Arch package ([mega.md](mega.md)) |

### App Defaults

The Omarchy `install` commands set the terminal, browser, and editor. Flea sets the file manager with its own command. There is no text-editor role. `omarchy default editor` is the coding editor used by `omarchy-launch-editor` (Super+Shift+N), and Typora is not one of its choices, so that role stays Zed.

| Role | Choice | Set with |
| --- | --- | --- |
| Terminal | Ghostty | `omarchy default terminal ghostty` |
| Browser | Brave Origin | `omarchy default browser brave-origin` |
| Editor | Zed | `omarchy default editor zed` |
| Agent | Grok | `omarchy default agent grok` |
| File manager | Flea | `flea --default` |
| Markdown files | Typora | `xdg-mime default typora.desktop text/markdown text/x-markdown` |

### App Specifics

- Typora is the writing app on Super+Shift+W, and the opener for a single Markdown file (`*.md`, `*.mkd`, `*.markdown`). Those names are `text/markdown`, with alias `text/x-markdown`. Both are set to `typora.desktop` in `~/.config/mimeapps.list`. `text/plain` stays Neovim. Typora keeps its own themes, so an Omarchy theme switch does not recolor it. A license is a one-time purchase for three devices, with a 15-day trial; activate it from Help → My license…. Linux counts as its own device beside the Mac copy. OmaWrite stays installed.
- File manager Flae: [flea.md](flea.md)
- Cloud drive MEGA: [mega.md](mega.md)
- Steam is installed again. Closing its window only hides the client, which keeps `steam` and the `steamwebhelper` processes resident. `steam -shutdown` unloads them. Steam → Exit does the same. `omarchy remove gaming steam` removes the package and `~/.local/share/Steam`.

## Uninstalled

- Stock software this setup removes
- [`install-apps.sh`](install-apps.sh) does not do the uninstalls
- `omarchy pkg drop` skips a name that is already gone, then runs `sudo pacman -Rns --noconfirm`
- `omarchy reinstall pkgs` installs the stock list again

| Software | GB | Remove with |
| --- | --- | --- |
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

Super+Shift+W was OmaWrite. It is unbound, then bound to Typora:

```lua
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "Typora", { launch = "typora" })
```

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

## German umlauts

US letters stay as they are. Right Alt is AltGr. The layout is `us` with variant `de_se_fi` (keymap name `German, Swedish and Finnish (US)`), in the same `hl.config` input table in `~/.config/hypr/input.lua`:

```lua
kb_layout = "us",
kb_variant = "de_se_fi",
```

| Chord | Character |
| --- | --- |
| AltGr + A | ä |
| AltGr + Shift + A | Ä |
| AltGr + O | ö |
| AltGr + Shift + O | Ö |
| AltGr + U | ü |
| AltGr + Shift + U | Ü |
| AltGr + S | ß |
| AltGr + Shift + S | ẞ |

AltGr + E is €, AltGr + P is å, and AltGr + Q is @. Left Alt remains the shortcut Alt. Caps Lock remains the compose key from Omarchy's default `kb_options` (`compose:caps,shift:both_capslock_cancel`). Fcitx stays on `keyboard-us` and uses this keymap.

Hyprland reloads on save. Force apply with `hyprctl reload`, then check `hyprctl configerrors`. `hyprctl devices` should show variant `de_se_fi` and keymap `German, Swedish and Finnish (US)`.

## Other

- CPU Smart Fan (quiet curve): [fan.md](fan.md)
- Brightness Control: [brightness.md](brightness.md)
- Obsidian Manage vaults dialog: [obsidian.md](obsidian.md)
- git authentication via `gh`: [git-auth.md](git-auth.md)
- Known issues (hardware failures, alternative PCs, and verdict): [known-issues.md](known-issues.md)
