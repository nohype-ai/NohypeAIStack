# Files

Files (`folio`) is the file manager. The window title is Files; the binary and desktop id are `folio`.

On this 4.5 RC machine Folio is not in the RC repo. It is built from `/home/seb/Work/folio` (see that tree’s `pkgbuild/PKGBUILD`) and installed with `pacman -U`. `omarchy pkg add folio` fails until the package is on RC.

```bash
xdg-mime default folio.desktop inode/directory
```

That sets folders and “open this directory” to Files. Super+Shift+F and Super+Alt+Shift+F are bound in `~/.config/hypr/bindings.lua` (replacing Flea). Show in folder uses a user D-Bus service that starts `/usr/bin/folio`. Open/Save dialogs use the GTK portal; Folio has no file-chooser portal.

[`install-apps.sh`](install-apps.sh) sets the MIME default, the FileManager1 service, and the GTK chooser, then restarts `xdg-desktop-portal`. It does not build Folio.

Flea stays installed and is not the default.
