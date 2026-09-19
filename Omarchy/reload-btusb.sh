#!/usr/bin/env bash
# Recover Intel AX200 Bluetooth after "No default controller available".
# See README.md (Known issues — Intel AX200 Bluetooth). Needs sudo.
# Reloads btusb so firmware init runs again. Does not reboot.
set -euo pipefail

echo "=== before ==="
bluetoothctl list || true
rfkill list bluetooth || true
lsusb | grep -E '8087|Bluetooth' || true
ls -l /sys/class/bluetooth || true
echo -n "usb 1-5 runtime: "
cat /sys/bus/usb/devices/1-5/power/runtime_status 2>/dev/null || echo missing
journalctl -k -b --no-pager -o short-iso | grep -iE 'hci0|btusb|Intel version' | tail -15 || true

echo
echo "=== reload btusb ==="
sudo rmmod btusb || sudo modprobe -r btusb
sleep 1
sudo modprobe btusb
echo "btusb loaded; waiting 5s for firmware"
sleep 5

echo
echo "=== after ==="
journalctl -k --since "1 minute ago" --no-pager -o short-iso | grep -iE 'hci0|btusb|firmware|Intel' || true
bluetoothctl list || true
bluetoothctl show || true
echo -n "usb 1-5 runtime: "
cat /sys/bus/usb/devices/1-5/power/runtime_status 2>/dev/null || echo missing

if bluetoothctl list 2>/dev/null | grep -q '^Controller '; then
  echo "RESULT: controller is back"
  exit 0
fi

if journalctl -k --since "1 minute ago" --no-pager | grep -F 'Reading Intel version command failed'; then
  echo "RESULT: still -110 after reload" >&2
  exit 1
fi

echo "RESULT: no controller yet (firmware may still be loading, or BlueZ did not pick it up)" >&2
exit 1
