#!/usr/bin/env bash
# Restore loud kernel logs for the next hibernate panic (photos + journal).
# See README.md (Known issues — Hibernate). Needs sudo. Rebuilds the UKI;
# reboot once after this so the command line is live. omarchy update copies
# quiet splash back onto omarchy-defaults.conf; run this again after that.
set -euo pipefail

CONF=/etc/limine-entry-tool.d/omarchy-defaults.conf
BAK=/etc/limine-entry-tool.d/omarchy-defaults.conf.before-hibernate-test
QUIET='KERNEL_CMDLINE[default]+=" quiet splash loglevel=0 systemd.show_status=false rd.udev.log_level=0 vt.global_cursor_default=0"'
LOUD='KERNEL_CMDLINE[default]+=" loglevel=7 no_console_suspend"'

if [[ $EUID -ne 0 ]]; then
  echo "run as root: sudo $0" >&2
  exit 1
fi

if [[ ! -f $BAK ]]; then
  cp -a "$CONF" "$BAK"
  echo "saved stock copy to $BAK"
fi

if grep -Fqx "$LOUD" "$CONF" && ! grep -F 'quiet splash' "$CONF"; then
  echo "UKI drop-in already loud"
else
  if ! grep -Fqx "$QUIET" "$CONF" && ! grep -F 'quiet splash' "$CONF"; then
    echo "unexpected KERNEL_CMDLINE in $CONF; not editing" >&2
    grep KERNEL_CMDLINE "$CONF" >&2 || true
    exit 1
  fi
  python3 - "$CONF" "$QUIET" "$LOUD" <<'PY'
import pathlib, sys
path, quiet, loud = pathlib.Path(sys.argv[1]), sys.argv[2], sys.argv[3]
text = path.read_text()
if quiet in text:
    text = text.replace(quiet, loud, 1)
else:
    # already missing the stock quiet line; still drop leftover quiet tokens
    lines = []
    replaced = False
    for line in text.splitlines(True):
        if (not replaced) and "KERNEL_CMDLINE[default]+=" in line and "quiet" in line:
            lines.append(loud + "\n")
            replaced = True
        else:
            lines.append(line)
    text = "".join(lines)
path.write_text(text)
PY
  echo "wrote loud KERNEL_CMDLINE in $CONF"
fi

# This session: next hibernate can print before a reboot. quiet on the
# already-running command line still hides early boot; these raise live printk.
printf '7 4 1 7\n' >/proc/sys/kernel/printk
echo N >/sys/module/printk/parameters/console_suspend
echo "live printk=$(tr ' ' / </proc/sys/kernel/printk | head -c 20) console_suspend=$(cat /sys/module/printk/parameters/console_suspend)"

echo "rebuilding UKI (limine-mkinitcpio)…"
limine-mkinitcpio
echo "assembled cmdline:"
limine-entry-tool --get-cmdline || cat /proc/cmdline
echo "RESULT: reboot once so the UKI command line is live. LUKS prompt will be plaintext."
