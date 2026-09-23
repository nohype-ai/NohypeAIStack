#!/usr/bin/env bash
# Extra Omarchy apps from README.md (Installed apps). Sudo for Flea and MEGA.
set -euo pipefail

# Omarchy package installs
omarchy install terminal ghostty
omarchy install browser brave-origin
omarchy install editor zed

# Flea
omarchy pkg aur add flea-bin
flea --default
systemctl --user restart xdg-desktop-portal

# Omarchy plugin installs
# (pattern: try update, try install when update fails)
omarchy plugin update omamail || \
  omarchy plugin add https://github.com/huacnlee/omamail.git --enable --yes

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
