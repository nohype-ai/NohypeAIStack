#!/usr/bin/env bash
# Extra Omarchy apps from README.md (Installed apps). Sudo for MEGA.
set -euo pipefail

# Omarchy package installs
omarchy install terminal ghostty
omarchy install browser brave-origin
omarchy install editor zed

# MEGA Desktop
if pacman -Q megasync >/dev/null 2>&1; then
  echo "megasync already installed"
else
  curl -fL -o /tmp/megasync-x86_64.pkg.tar.zst \
    https://mega.nz/linux/repo/Arch_Extra/x86_64/megasync-x86_64.pkg.tar.zst
  sudo pacman -U --noconfirm --needed /tmp/megasync-x86_64.pkg.tar.zst
  rm -f /tmp/megasync-x86_64.pkg.tar.zst
fi

# MEGA CMD
if pacman -Q megacmd >/dev/null 2>&1; then
  echo "megacmd already installed"
else
  curl -fL -o /tmp/megacmd-x86_64.pkg.tar.zst \
    https://mega.nz/linux/repo/Arch_Extra/x86_64/megacmd-x86_64.pkg.tar.zst
  sudo pacman -U --noconfirm --needed /tmp/megacmd-x86_64.pkg.tar.zst
  rm -f /tmp/megacmd-x86_64.pkg.tar.zst
fi
