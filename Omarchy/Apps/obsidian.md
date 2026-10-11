# Obsidian

Package `obsidian` 1.13.7-2, Electron 43.6.0 (`/usr/bin/obsidian` → `electron43`). The running app is one process. Vault windows are resizable. **Manage vaults** is a separate window, 800×650, `resizable: false`, loading `starter.html`. Hyprland reports that window at about 820×670 once the frame is included. It is centered.

## What goes wrong

The LG on DP-1 is 5120×2880 at Hyprland scale 2. `omarchy display text size` is 20 px, which sets GNOME `text-scaling-factor` to 1.6364 (the 11 pt interface font quantized to 18 pt).

Electron on Wayland multiplies that factor into the device scale. A scratch window the same size as Manage vaults, launched with Obsidian's flags (`-disable-gpu --enable-wayland-ime`), reports:

| Launch | `devicePixelRatio` | Open button |
| --- | --- | --- |
| same flags as Obsidian | 3.28125 | clipped past the bottom-right |
| `--force-device-scale-factor=1` | 2 | inside the frame |
| `GSETTINGS_BACKEND=memory` | 2 | inside the frame |
| `--disable-features=WaylandUiScale` | 3.28125 | still clipped |

3.28125 / 2 = 1.640625, the text scale on top of the monitor scale. The window stays 800×650. The page is drawn at the inflated scale, so only the top-left of the layout is inside the frame. On the real dialog that cuts off the right-hand column (`Create new vault`, `Open folder as vault`) and the **Open** control. The window appears at the right size first; the scale is applied to the surface immediately after it is shown.

`--force-device-scale-factor=2` makes this worse (`devicePixelRatio` 4). `GDK_SCALE` is already 2 from `~/.config/hypr/monitors.lua` and is not the extra factor.

Per-vault zoom is a separate setting, stored in `~/.config/obsidian/<id>.json` (`zoom` 0.5, -0.5, and 1.5 on the three vaults here). It is reapplied to vault windows. It is not what sizes the Manage vaults window.

## Fix

`/usr/bin/obsidian` appends every non-comment line of `~/.config/obsidian/user-flags.conf` on every launch (the keybinding, the desktop entry, and `restore-desk.sh`). Add:

```
--force-device-scale-factor=1
```

`GSETTINGS_BACKEND=memory` also drops the text scale, and it drops every other gsettings value for the process. The flag only overrides the device scale. Obsidian then follows the monitor scale. Its own zoom commands (Ctrl+0, Ctrl+=, Ctrl+-) still change the vault windows. The desktop text size no longer scales Obsidian.

The stock copy is `/usr/share/omarchy/config/obsidian/user-flags.conf`. `omarchy update` does not replace the file under `~/.config/obsidian/`.

## Apply

Quit Obsidian so the old process does not keep the previous scale, then start it the usual way:

```bash
kill -TERM $(pidof -s electron43)
uwsm-app -- obsidian
```

Confirm the flag is on the process:

```bash
tr '\0' ' ' < /proc/$(pidof -s electron43)/cmdline; echo
```

The command line includes `--force-device-scale-factor=1`.

Open the dialog with the running app (the CLI does not have to be enabled):

```bash
obsidian "obsidian://choose-vault"
```

The vault list and the right-hand column are both inside the frame, including **Create**, **Open**, and **Sign in**. Vault windows still fill the workspace; the flag does not shrink them. It only stops the extra text scale.
