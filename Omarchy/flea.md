# Flea

Flea is the file manager. The package is `flea-bin` on the AUR: the tagged release, already built for x86_64. `omarchy update` installs a new release minutes after it ships.

```bash
omarchy pkg aur add flea-bin
flea --default
```

`flea-bin`, the repository package `flea`, and `flea-git` each install `/usr/bin/flea`. This machine uses `flea-bin` only.

Run `flea --default` in a terminal inside the session. It sets the `inode/directory` handler, Show in folder, Super+Shift+F, Super+Alt+Shift+F, and the file chooser, then restarts `xdg-desktop-portal` so file dialogs follow at once. When `~/.config/xdg-desktop-portal/hyprland-portals.conf` exists, the chooser line goes in that file, which is the one the portal reads. `flea --default off` puts the previous chooser back.

[`install-apps.sh`](install-apps.sh) runs those two commands, then `systemctl --user restart xdg-desktop-portal`. That extra restart covers a script run whose output is captured: `flea --default` restarts the portal only when its own output is a terminal.

