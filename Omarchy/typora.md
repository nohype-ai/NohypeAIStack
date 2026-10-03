# Typora

Package `typora` 1.14.9-1, Electron 42.2.0 (`/usr/bin/typora` execs `/usr/share/typora/Typora`). The running app is one process. Document windows are resizable. **License Info** is a separate floating window, centered. Hyprland reports it at 495×379 on this screen. It loads the activate page.

## What goes wrong

The LG on DP-1 is 5120×2880 at Hyprland scale 2. `omarchy display text size` is 20 px, which sets GNOME `text-scaling-factor` to 1.6364. `GDK_SCALE` is already 2 from `~/.config/hypr/monitors.lua`. This is the same text scale that clips Obsidian's Manage vaults window ([obsidian.md](obsidian.md)).

Electron on Wayland multiplies that factor into the device scale. The license window stays 495×379. The page is drawn at the inflated scale, so only the top-left of the layout is inside the frame: part of the logo, and the top of **Activate Typora**. **Enter License**, the email fields, and **License Code** sit past the right and bottom edges.

Typora's own zoom is a separate setting, stored in `~/.config/Typora/profile.data` (`zoomLevel` -1, `zoomFactor` about 0.833 here). It is the editor zoom. It is not what sizes the license window.

## Fix

`/usr/bin/typora` appends every non-comment line of `$XDG_CONFIG_HOME/typora-flags.conf` (`~/.config/typora-flags.conf`) on every launch (the keybinding and the desktop entry). The wrapper deletes from `#` to the end of each line, then joins the lines. Add:

```
--force-device-scale-factor=1
```

That file is the flags file. The profile directory `~/.config/Typora` is a different path, and the wrapper does not read it for flags.

The flag only overrides the device scale. Typora then follows the monitor scale. Its own zoom commands still change the editor. The desktop text size no longer scales Typora.

The Arch package owns `/usr/bin/typora`. A package upgrade replaces that wrapper and leaves `~/.config/typora-flags.conf` in place. There is no copy under `/usr/share/omarchy`.

## Apply

Quit Typora so the old process does not keep the previous scale, then start it the usual way (Super+Shift+W, or `typora`).

Confirm the flag is on the main process. Helper processes are also named `Typora` and include `--type=`; skip those:

```bash
ps -eo args | awk '/^\/usr\/share\/typora\/Typora / && !/--type=/'
```

The command line includes `--force-device-scale-factor=1`.

Open the dialog from the running app: Help → My License…

The window stays 495×379 and centered. The first page shows the logo, **Activate Typora**, **Buy License**, **Not Now**, and **Enter License**, all inside the frame. **Enter License** opens the form in that same window: **Email Address**, **Re-enter Email**, **License Code**, and **Activate**. Document windows still fill the workspace. The flag stops the extra text scale.
