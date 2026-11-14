#!/usr/bin/env bash
# Extra Omarchy apps from README.md (Installed apps). Sudo for Typora, Qutebrowser, GNOME Podcasts, WeasyPrint, and MEGA.
set -euo pipefail

# Omarchy package installs
omarchy install terminal ghostty
omarchy install browser brave-origin

# Qutebrowser
omarchy pkg add qutebrowser

omarchy install editor zed

# GNOME Podcasts
omarchy pkg add gnome-podcasts

# WeasyPrint
omarchy pkg add python-weasyprint

# Typora
omarchy pkg add typora
xdg-mime default typora.desktop text/markdown text/x-markdown

# Files (folio). The binary is installed from the local checkout, not here.
xdg-mime default folio.desktop inode/directory
mkdir -p "$HOME/.local/share/dbus-1/services"
cat > "$HOME/.local/share/dbus-1/services/org.freedesktop.FileManager1.service" <<'EOF'
[D-BUS Service]
Name=org.freedesktop.FileManager1
Exec=/usr/bin/folio
EOF
mkdir -p "$HOME/.config/xdg-desktop-portal"
if [[ -f "$HOME/.config/xdg-desktop-portal/portals.conf" ]]; then
  sed -i 's/^org.freedesktop.impl.portal.FileChooser=.*/org.freedesktop.impl.portal.FileChooser=gtk/' \
    "$HOME/.config/xdg-desktop-portal/portals.conf"
else
  printf '%s\n' '[preferred]' 'org.freedesktop.impl.portal.FileChooser=gtk' \
    > "$HOME/.config/xdg-desktop-portal/portals.conf"
fi
systemctl --user restart xdg-desktop-portal

# Omarchy plugin installs
# (pattern: try update, try install when update fails)
omarchy plugin update omamail || \
  omarchy plugin add https://github.com/huacnlee/omamail.git --enable --yes

# Workspace Layout
omarchy plugin update bjarneo.workspace-layout || \
  omarchy plugin add https://github.com/bjarneo/omarchy-workspace-layout --enable --yes

# MEGA Desktop
if pacman -Q megasync >/dev/null 2>&1; then
  echo "megasync already installed"
else
  curl -fL -o /tmp/megasync-x86_64.pkg.tar.zst \
    https://mega.nz/linux/repo/Arch_Extra/x86_64/megasync-x86_64.pkg.tar.zst
  sudo pacman -U --noconfirm --needed /tmp/megasync-x86_64.pkg.tar.zst
  rm -f /tmp/megasync-x86_64.pkg.tar.zst
fi
# post_install appends [DEB_Arch_Extra] with no database. Remove it before the next pacman command. See README.md.
sudo sed -i '/###REPO for MEGA###/,/###END REPO for MEGA###/d' /etc/pacman.conf

# MEGA CMD
if pacman -Q megacmd >/dev/null 2>&1; then
  echo "megacmd already installed"
else
  curl -fL -o /tmp/megacmd-x86_64.pkg.tar.zst \
    https://mega.nz/linux/repo/Arch_Extra/x86_64/megacmd-x86_64.pkg.tar.zst
  sudo pacman -U --noconfirm --needed /tmp/megacmd-x86_64.pkg.tar.zst
  rm -f /tmp/megacmd-x86_64.pkg.tar.zst
fi
sudo sed -i '/###REPO for MEGA###/,/###END REPO for MEGA###/d' /etc/pacman.conf
