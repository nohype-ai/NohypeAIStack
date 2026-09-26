# Known issues

Observe stock Omarchy first, then measure, then maybe a small fix.

## Studio Display + AMD USB4

This Beelink SER9 (Ryzen 7 255 / Radeon 780M) talks to the **Apple Studio Display** over USB4 (`DP-5`, 5120×2880), not a dumb DisplayPort cable. Two host actions drop that tunnel; amdgpu then fails DPIA AUX and the panel stays black until a **power cycle**:

1. **DPMS off** — stock Omarchy lock blanks the output about 5s after lock.
2. **s2idle** — power-menu Suspend. This CPU has no S3; “suspend” is light sleep. Same tunnel death.

Resume logs look like:

```text
amdgpu: Skip DMUB HPD IRQ callback in suspend/resume
amdgpu: DPIA AUX failed on 0x600(1), error 7
```

A **full shutdown/reboot** re-inits the GPU. That is a different path. If the panel comes back after a clean boot, shutdown is fine. If it doesn’t, the display itself needs a power cycle even on cold start — worth knowing, and a 30-second test.

Do not pile display-sleep workarounds onto the machine until the failure is understood. A previous approach solved “don’t lose windows overnight” by keeping the PC fully on (lock + black frame + backlight 0%, never s2idle). That is a lot of machinery for a habit you can change (shutdown) until you know what is actually broken.

### What to measure, in this order

| Test | How | What you learn |
| --- | --- | --- |
| 1. Lock only | Super+Ctrl+L, wait 10s | Does stock DPMS-off already black the panel? Does a key bring it back? |
| 2. Short suspend | Power menu Suspend, wait 20s, move mouse/keyboard | Does a *short* s2idle come back? (Sometimes short resume works and overnight doesn’t.) |
| 3. Overnight suspend | Only if 2 worked | The original failure. If it wedges, you have a clean repro. |
| 4. Shutdown (Beelink) | Power menu Shutdown. Watch LED/fans 60s. Do not press the power button. | Does the mini PC actually stay off? See [Shutdown may not actually power off the Beelink](#shutdown-may-not-actually-power-off-the-beelink). |
| 5. Shutdown (display) | After a real power-off, power on from the button | Does a cold GPU init bring the Studio Display back without touching *its* power button? |
| 6. Logs if it wedges | After you get a picture again: `journalctl -b -1 \| grep -iE 'amdgpu\|DPIA\|suspend\|Studio\|power off'` | AUX errors vs a poweroff that never finished. |

If test 1 or 2 wedges the panel, don’t keep experimenting that night — power-cycle the display (or the mini PC). That’s the recovery, not a deeper Linux trick.

The DPIA AUX failure is amdgpu + USB4 + this display. A kernel/`amdgpu` update is the real fix. Omarchy can still **avoid** the path (don’t DPMS-off this panel on lock). Theme/lock chrome will not. See [Who can fix these](#who-can-fix-these-and-what-omarchy-could-do).

Until then, the simple policy is: **shutdown when you’re done**, accept a fresh session in the morning, and treat Suspend as an experiment, not a habit. Forced power-offs while the box is wedged are how the AX200 Wi-Fi/Bluetooth failures below have shown up. Session restore is a separate issue — not mixed into display-sleep hacks.

## Shutdown may not actually power off the Beelink

Same hardware family (USB4 + Studio Display + SER9), **not** the s2idle AUX failure. That bug blacks the *panel* while Linux keeps running. This one is: did ACPI S5 cut power to the mini PC?

Linux does *start* a real poweroff (`The system will power off now!`, then unmounts). The persistent journal always stops there, even on a clean shutdown, so missing a “Powering off” line proves nothing. What the logs do show:

- Tue 21:08 — poweroff started. Next boot **Wed 03:50**. That 6.5h gap is either a hang (box never went off) or a successful off plus something turning it back on.
- Thunderbolt (`NHI0` / `NHI1`) and several USB controllers are **wakeup-enabled**. The Studio Display sits on that USB4 bus; an Apple MagSafe Charging Case has also shown up through the display’s USB hub. Either can keep the box from staying off.
- Omarchy sets `HandlePowerKey=ignore`. A **short press of the Beelink power button does nothing**. Only the power menu (or a long hold = hard cut) shuts down. Easy to think “shutdown doesn’t work” if you used the button.

**One test, no extra config:** Power menu → Shutdown. Watch the **Beelink** (LED / fans), not the display, for 60 seconds. Do not touch the power button.

| What you see | Meaning |
| --- | --- |
| LED/fans die and stay dead | Shutdown works. Black panel was just the display. |
| LED/fans die, then the box comes back | S5 worked, then TB/USB woke it. Separate from “display won’t wake”. |
| LED/fans never die | Shutdown hung at ACPI. Also separate; often Thunderbolt. |

Long-hold to force off only after that minute, so the log still shows a clean poweroff attempt.

## Intel AX200 Wi-Fi gone until CMOS reset

Same Beelink SER9, same Intel AX200 (`02:00.0`, PCI `8086:2723`) as the Bluetooth issue below. This one is **the PCI Wi-Fi function hung**, not a missing `iwlwifi` package and not the USB Bluetooth firmware timeout.

**Symptom:** no Wi-Fi interface (`wlp2s0` gone). NetworkManager has nothing to connect. `lspci` still shows the AX200. Reboots do not bring it back.

**Log line that proves it:**

```text
iwlwifi 0000:02:00.0: CSR_RESET = 0x10
iwlwifi 0000:02:00.0: probe with driver iwlwifi failed with error -110
```

`-110` is `ETIMEDOUT` again. `CSR_RESET = 0x10` means the chip is sitting in reset; the driver dumps “Host monitor” registers and gives up. The PCI device is enumerated, so this is not “the card fell off the bus.” It is a wedged radio that Linux cannot talk to.

**Why this happens (generally):** unclean power cut to the AX200. On this machine that lines up with the Studio Display mess above: lock/suspend blacks the panel, shutdown may not actually cut Beelink power, and the recovery is often a **long-hold** of the power button. That hard cut can leave the Wi-Fi MCU in a state a normal reboot does not clear. Beelink’s own SER9 notes for “Wi-Fi not detected” are CMOS clear, not a driver reinstall.

If Wi-Fi still works and only Bluetooth is missing, that is the [Bluetooth subsection](#intel-ax200-bluetooth-no-default-controller) (`reload-btusb.sh`). Do not CMOS-reset for that.

**What does not fix it:** reboot, `modprobe -r iwlwifi && modprobe iwlwifi`, NetworkManager restart. Tried across four boots on this occurrence; every one logged the same `-110`.

**Recovery that worked:** CMOS reset of the Beelink. Front-panel **CLR CMOS** pinhole (paperclip). Beelink’s procedure:

1. Power off. Unplug the DC barrel (and the display cable if you are following their text).
2. Press CLR CMOS for about **10 seconds**.
3. Wait several minutes (they say ~10).
4. Plug back in, power on. First boot after a CMOS clear can take a minute.

That restores BIOS defaults, including the [quiet fan curve](fan.md#cpu-smart-fan-quiet-curve). Enter those values again after a clear.

**This occurrence (2026-09-16):** Afternoon after the Studio Display / shutdown experiments. Boot 14:43: `probe with driver iwlwifi failed with error -110`, `CSR_RESET = 0x10`. Same failure at 15:29 (retry on that boot), then 15:39, 15:44, 15:59. Next boot **15:59:17** loaded `iwlwifi` firmware `77.aa2dd297.0` and renamed `wlan0` → `wlp2s0` — after the CMOS reset.

## Intel AX200 Bluetooth: no default controller

Same Beelink SER9, same AX200 card as the Wi-Fi issue above. **Not** the Studio Display USB4 bug, and **not** a CMOS-level hang: here Wi-Fi still works. Bluetooth is a USB function on that card (`8087:0029` on `usb 1-5`), not a dongle.

**Symptom:** Omarchy Bluetooth panel empty. `bluetoothctl list` / `show` print `No default controller available`. Wi-Fi still works. `bluetooth.service` is running. `rfkill` shows `hci0` unblocked. `/sys/class/bluetooth/hci0` exists. The USB device is still enumerated.

That means the kernel has a zombie `hci0` and BlueZ has nothing to power on. It is not “Bluetooth was switched off.”

**Log line that proves it** (this boot, 2026-09-19 12:59:41, ~2s after bluetoothd started):

```text
Bluetooth: hci0: Reading Intel version command failed (-110)
```

`-110` is `ETIMEDOUT`. After a real power-off the AX200 BT MCU is in bootloader and Linux must upload `intel/ibt-20-1-3.sfi`. The first Intel version command timed out, so firmware never loaded. The USB device then autosuspended (`power/control: auto`, 2s delay). First time this `-110` appears in the persistent journal. The previous boot (02:10 the same day) loaded firmware normally.

Healthy cold-boot sequence looks like:

```text
Bluetooth: hci0: Found device firmware: intel/ibt-20-1-3.sfi
Bluetooth: hci0: Firmware loaded in … usecs
Bluetooth: hci0: Device booted in … usecs
```

Some reboots skip the download and log `Firmware already loaded` — the MCU stayed powered across the reboot. That is a different path from a full shutdown.

**Why this happens (generally):** USB timing / autosuspend racing firmware download on AMD xHCI, or a hung BT MCU after power cut. Once the version command times out, userspace cannot talk the chip back to life.

**What does not fix it:** `omarchy restart bluetooth`. That helper only `rfkill unblock bluetooth`. Tried twice on this occurrence; no-op, as expected. Do not reboot first either: this occurrence *was* already a cold start after overnight shutdown, and it still timed out. A soft reboot sometimes leaves the MCU powered (`Firmware already loaded`) and can recover *or* leave it wedged.

**Recovery, in this order — no extra config until one of these is measured:**

```bash
# 1. Confirm the timeout and that the USB function is still there
journalctl -b | grep -F 'Reading Intel version command failed'
lsusb | grep 8087
bluetoothctl list

# 2. Reload btusb (re-runs firmware init, keeps the session)
./reload-btusb.sh
```

[`reload-btusb.sh`](reload-btusb.sh) is the same `rmmod` / `modprobe btusb` plus before/after logs. Run it from this directory; it needs sudo.

| Result after reload | Meaning | Next |
| --- | --- | --- |
| Firmware loaded / device booted, `bluetoothctl list` shows a controller | Transient firmware timeout. Done. | Leave autosuspend alone until it repeats. |
| Same `-110` again, or still no controller | MCU still wedged, or USB did not actually reset. | USB reset of `1-5` (below). |
| Reload fails / still dead after USB reset | Needs a real power cut to the card. | Full **power-off** (watch the Beelink LED), then power on. Soft reboot is the weaker option. |

USB reset if step 2 is not enough:

```bash
echo 0 | sudo tee /sys/bus/usb/devices/1-5/authorized
echo 1 | sudo tee /sys/bus/usb/devices/1-5/authorized
sleep 3
bluetoothctl list
```

Do **not** disable USB autosuspend or add a kernel quirk yet. One timeout is a race, not a policy. After a successful reload the USB function went back to `runtime_status: suspended` and the controller stayed up — so autosuspend after firmware load is fine; the race is only during the bootloader handshake.

**This occurrence (2026-09-19):** Cold boot 12:59 after shutdown at 02:30. `-110` at 12:59:41. Wi-Fi on `FRIZZ`. `omarchy restart bluetooth` ×2 did nothing.

`sudo rmmod btusb && sudo modprobe btusb` recovered it without a reboot. Firmware loaded in ~1.4s, same sequence as a healthy cold boot (`ibt-20-1-3.sfi`, revision 0.3 build 193 week 33 2024). BlueZ then had `Controller A8:59:5F:9C:59:04 beelink [default]`, `Powered: yes`. USB reset and power-off were not needed.

## Modern standby never reaches its deepest idle

Suspend on this SER9 is already modern standby. The firmware advertises S0, S4, and S5, and no S3. The kernel logs `Low-power S0 idle used by default for system suspend`, and `/sys/power/mem_sleep` is `[s2idle]`. Power-menu Suspend runs `systemctl suspend`. No `suspend-off` flag is set, so the item is in the menu.

The machine wakes back to the desktop, and the idle it reached is shallower than the one the firmware claims. Eight s2idles from Sun 2026-09-20 21:33 through Thu 2026-09-24 02:34, and another at 13:07 that same morning, all logged:

```text
amd_pmc AMDI0009:00: Last suspend didn't reach deepest state
```

Every wake also aborted the embedded-controller method the firmware runs on the way out of sleep:

```text
ACPI Error: Region EmbeddedControl (ID=3) has no handler
ACPI Error: Aborting method \_SB.PCI0.SBRG.EC0.UPHK due to previous error (AE_NOT_EXIST)
ACPI Error: Aborting method \_SB.PEP._DSM due to previous error (AE_NOT_EXIST)
```

The session came back each time, including on the HDMI Sony TV, and Wi-Fi reassociated after the 13:08 wake. A hibernate half a minute later still entered S4, so this shallow wake does not by itself reproduce the hibernate panic below.

**Dead end.** Nothing on this box can make that idle deep. Suspend is already s2idle. `amd_pmc` workarounds are already on (`disable_workarounds=N`, SMU 76.87.0). No Omarchy setting and no kernel parameter installs the missing EC handler. Beelink ships the board without S3, and AMI `SER9L106` has no option that adds it. Only a BIOS that repairs `EC0.UPHK` / `\_SB.PEP._DSM` would. Until then, Suspend is a light sleep that returns the desktop.

### Where a BIOS update would show up

This board is AZW SER9, Ryzen 7 255. The running firmware is AMI `SER9L106`, dated 2026-07-10 (`/sys/class/dmi/id/bios_version` and `bios_date`).

Public files for this CPU live in one folder:

[https://dr.bee-link.cn/?dir=uploads%2FSER%2FSER9-H255%2FBIOS](https://dr.bee-link.cn/?dir=uploads%2FSER%2FSER9-H255%2FBIOS)

Only the subfolders whose names say **Only-SER9L10X-can-flash** match this board. As of 2026-09-24 the newest of those is `SER9L106` (uploaded 2026-07-13), which is what is already installed. The `SER9T50X` folders in that same directory are a different firmware. The HX 370 packages (`T2xx`, `T4xx`, `V2xx`) and SER9 MAX are other machines. Flashing one of those has bricked SER9s; a CMOS clear does not always bring the board back. Beelink’s quarterly posts, such as [BIOS Update Summary For Q1 2026](https://www.bee-link.com/blogs/all/bios-update-summary-for-q1-2026), mix all of those models in one list. Use them as a changelog, then confirm the file is an `SER9L10X` build newer than `SER9L106`. Forum support often asks for a photo of the BIOS main page and sends a zip by private message. Check the version prefix on that zip yourself. They have sent the wrong image before.

When a newer `SER9L10X` folder appears, it contains a zip and a PDF named like `Use-USB-to-flash-BIOS`. Follow that PDF. Beelink’s method is their USB stick procedure, not a flash from inside Omarchy. Secure Boot on this machine is already off, which those tutorials require. Do not cut power while it flashes.

## Hibernate panicked twice; two short S4 cycles resumed

Overnight panics Thu 2026-09-24 02:57 and Fri 2026-09-25 02:42, HDMI Sony TV, power menu. Both journals end on:

```text
PM: hibernation: hibernation entry
```

Photos of both blue screens exist. They show Omarchy’s drm-panic overlay:

```text
KERNEL PANIC! Please reboot your computer.
Fatal exception in interrupt
```

The QR is CPU arch + Omarchy version, not the oops. No RIP or Call Trace was on those frames. Die reason is a fatal exception in interrupt (IRQ context, after userspace is frozen): a driver/firmware path (ACPI / `amdgpu` / radio). Hypothesis: extra GPU clients put that path into a bad state. Ghostty + MEGAsync S4 worked. After the loud UKI reboot, two short S4s also completed: Brave+Zed+OmaWrite+Ghostty+MEGAsync (~12:13), then the same plus Flea+OmaMail (~12:21). S4 returning is a different failure from [desktop frozen after hibernate resume](#desktop-frozen-after-hibernate-resume-amdgpu-ttm). Swap is already `resume=/dev/mapper/root resume_offset=1950296`. Not the empty `resume_offset` bug.

The 02:57 session had been up since Sun 20 Sep (Flea, Zed, Brave Origin, Ghostty, Omamail; leftover `kdenlive`). The 02:42 panic was the same boot as the successful afternoon S4s, with Brave Origin, Zed, OmaWrite, Ghostty, MEGAsync, Omamail. A manual shell restart at 02:29 logged amdgpu `VM memory stats … non-zero when fini` for quickshell. After 02:42 the TV-off framebuffer still showed the panic; reboot + LUKS panicked again; BIOS then the 11:19 boot logged `PM: Image not found (code -22)` and no `HibernateLocation` (same as the 12:02 boot after 02:57). Fresh desktop is [Workspaces are not persisted](#workspaces-are-not-persisted).

Same afternoon 24 Sep, platform mode: 12:59 Ghostty-only S4 woke 13:00; 13:08 after one s2idle woke 13:09. Both `iwlwifi CSR_RESET = 0x10` then reassociated. Loud cmdline is restored (`loglevel=7 no_console_suspend`, no `quiet splash`; stock copy `omarchy-defaults.conf.before-hibernate-test`). `omarchy update` puts quiet back; rerun [`hibernate-loud-cmdline.sh`](hibernate-loud-cmdline.sh). LUKS prompt is visible among kernel logs.

## Desktop frozen after hibernate resume (amdgpu TTM)

Hibernate wrote RAM to disk and came back. The **GPU’s memory bookkeeping did not**. A few minutes later, moving windows asked the GPU to shuffle buffers, those lists were already garbage, and the compositor locked up on the last frame.

This is an **AMD `amdgpu` / TTM bug in Linux** (TTM = the kernel GPU buffer allocator). The code lives in `linux-omarchy` because that is this machine’s kernel; AMD writes it, not Omarchy and not this repo. Hyprland config cannot repair the allocator. Omarchy’s only kernel move is to **carry an upstream TTM/S4 patch if one lands**. Until then, nobody here ships a fix.

Distinct from [hibernate entry panic](#hibernate-panicked-twice-two-short-s4-cycles-resumed) (kernel died *entering* S4; no image) and from [Studio Display DPIA](#studio-display--amd-usb4) (panel black). Here S4 returned, then the desktop died.

Fri 2026-09-25, loud cmdline (`loglevel=7 no_console_suspend`). Two loaded S4 cycles returned (12:13 Brave+Zed+OmaWrite+Ghostty+MEGAsync; 12:21 the same plus Flea+OmaMail). About 80s after the second resume, a new Ghostty surface opened (12:24:23) and window layout froze the desktop: last frame stayed on screen, no input. Force power-off.

Journal, boot `12373b577ac54da7935b6510a2bff714`:

```text
12:25:30  list_add corruption. prev->next should be next ...
          WARNING: lib/list_debug.c:32 at __list_add_valid_or_report
          CPU: brave:cs0   ttm_bo_populate → amdgpu_cs_ioctl
12:25:30  list_del corruption ... ttm_resource_fini / amdgpu_bo_move
12:25:39  BUG: kernel NULL pointer dereference
          Oops: 0002 [#1]  Comm: QSGRenderThread
          RIP: ttm_lru_bulk_move_tail+0x13c/0x1e0 [ttm]
12:26:05  watchdog: BUG: soft lockup
          kworker commit_work  amdgpu_dm_atomic_commit_tail
          also stuck: brave, zed-editor, quickshell:cs0
```

Brave’s GPU thread hit corrupt TTM lists first. Qt’s `QSGRenderThread` then Oopsed. Hyprland’s next atomic commit (`amdgpu_dm_atomic_commit_tail` / plane unpin) deadlocked. The Ghostty TUI in that new window is not in the stack.

**Avoid**

- Shutdown when Brave, Zed, Flea, OmaWrite, or the shell have been using the GPU.
- If a loaded hibernate does come back, reboot before doing more work. Do not rearrange windows in that session.
- Ghostty + MEGAsync only has completed S4 without this hang; that mix is the safer hibernate.

App isolation is done. There is no `~/.config` workaround.

## Workspaces are not persisted

Hyprland/Omarchy do **not** restore windows after a reboot. Empty numbered workspaces come back; Ghostty/Brave/Zed do not. A layout script can relaunch apps onto numbered workspaces; notes and an example live in [`Restoring Workspaces/hyprctl.md`](Restoring%20Workspaces/hyprctl.md). That relaunches, guesses cwd, and misses unsaved buffers — it is not hibernate. Not a substitute for the Studio Display or TTM issues above.

## Who can fix these (and what Omarchy could do)

There isn’t one cursed pairing. This box stacks three combos. Beelink’s unique part is AMI BIOS / ACPI / power sequencing, not a mystery extra chip.

| Piece | What it is |
| --- | --- |
| APU | AMD **Ryzen 7 255** (Hawk Point / Phoenix) + **Radeon 780M** (`HawkPoint1`, `1002:1900`) |
| USB4 | AMD **Pink Sardine** Thunderbolt/USB4 NHI (`1022:1668` / `1669`) |
| Wi-Fi / BT | Intel **AX200NGW** — PCIe Wi-Fi + a **USB** Bluetooth function (`8087:0029` on `usb 1-5`) |
| Ethernet | Realtek **RTL8125** (soldered) |
| Board firmware | AMI **SER9L106** (AZW/SER9) |
| Display | Apple **Studio Display** on USB4 (`DP-5`), not a dumb DP cable |

This machine boots **`linux-omarchy` 7.2.5-3** (Limine `BOOT_ORDER` prefers it). Firmware is still stock Arch `linux-firmware` / `linux-firmware-amdgpu`. Owning a kernel means Omarchy can carry quirks, backports, and module options. It does **not** mean they write Beelink’s DSDT or `amdgpu`.

A real **fix** is almost never this machine’s Hyprland config. Local work stays in `~/.config/` and this directory — not `/usr/share/omarchy/` (`omarchy update` overwrites that).

| Issue | Actual fix | What Omarchy could do | What this machine can do locally | Cannot |
| --- | --- | --- | --- | --- |
| Studio Display black on lock/suspend (`DPIA AUX failed`) | **AMD `amdgpu`** (+ DMUB). Apple’s USB4 sink will not change for Linux. | Don’t DPMS-off USB4/Studio Display on lock; don’t sell s2idle as Suspend on no-S3 APUs. Carry an `amdgpu` USB4/DPIA backport **if** one lands upstream. | Idle/lock policy in `~/.config` (avoid the path). | Beelink. Theme/lock chrome. |
| Shutdown doesn’t stay off / long-hold | **Beelink AMI BIOS** (ACPI S5, `NHI0`/`NHI1` wakeup). | Turn off USB4 wakeup as a SER9 quirk; hide Suspend; `HandlePowerKey` UX. | Disable specific wakeup sources if you choose to. | Omarchy cannot make S5 cut the DC rail. |
| Modern standby never deepest; EC handler missing on wake | **Beelink AMI BIOS only** (`EC0.UPHK` / `\_SB.PEP._DSM`). | Don’t describe menu Suspend as deep sleep on SER9. | Dead end. Already s2idle; `amd_pmc` workarounds already on. | A local quirk, a menu change, or a BIOS toggle that adds S3. |
| Hibernate panicked twice; two short S4s resumed | Unknown IRQ `Fatal exception in interrupt` at hibernation entry. Photos have no RIP. Ghostty+MEGAsync and later loaded S4s *did* return. | Don’t treat SER9 as unable to S4. | Loud cmdline ([`hibernate-loud-cmdline.sh`](hibernate-loud-cmdline.sh)). | The empty `resume_offset` bug. The TTM freeze below. |
| Desktop frozen after hibernate resume (TTM) | **AMD `amdgpu` / TTM in Linux** (buffer lists corrupt after loaded S4). This machine and Omarchy do not author that driver. | Carry a TTM/S4 backport **if** one lands upstream. That is a pickup, not a rewrite. | Shutdown instead of loaded hibernate. Reboot if a loaded S4 returns. Ghostty+MEGAsync only is the safer mix. | Hyprland/`~/.config`. Writing `amdgpu`. The entry panic above. |
| Wi-Fi gone, `CSR_RESET`, CMOS | **Beelink BIOS / board power** (no rail-reset on reboot; D3cold). Same class as soldered RTL8125 vanishing until CLR CMOS on Windows. | Detect probe `-110` and tell the user to CLR CMOS / unplug DC. | CMOS pinhole. Unplug DC. Don’t hard-cut. | `iwlwifi` cannot talk to a chip in reset. |
| Bluetooth `-110`, Wi-Fi still up | **Kernel `btusb`/`btintel`** (USB autosuspend vs firmware load on AMD xHCI). | `omarchy restart bluetooth` reloads `btusb` when there is no controller; udev `8087:0029` `power/control=on`; kernel `btusb.enable_autosuspend=0` or a device quirk. | [`reload-btusb.sh`](reload-btusb.sh). Optional udev if it repeats. | CMOS is the wrong hammer. |
| Power button does nothing | **Omarchy** (`HandlePowerKey=ignore` in `/etc/systemd/logind.conf.d/10-ignore-power-button.conf`) | Short press → poweroff or power menu. | User logind drop-in. | Not a hardware bug. |
| Workspaces empty after boot | **Hyprland/Omarchy product** | Session restore as an explicit feature. | Layout script: [`Restoring Workspaces/hyprctl.md`](Restoring%20Workspaces/hyprctl.md). | Not mixed into display-sleep or hibernate. |

**Omarchy already has the display hook and does not use it for `off`.** Brightness up/down special-cases Apple panels (`omarchy-brightness-display-apple`). Lock waits 5s, then `omarchy-brightness-display off`, which is always:

```text
hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })'
```

That is the DPMS-off that kills the USB4 tunnel. Skipping connector DPMS on this output (dim to 0, or a black lock surface) is the highest-payoff mitigation they fully own. It avoids the bug; it does not teach Pink Sardine to survive DPMS.

**If Omarchy cares, ranked by payoff**

| They ship | Effect |
| --- | --- |
| Don’t DPMS-off Apple USB4 on lock | Stops the common way the panel dies |
| Treat s2idle as unsafe on USB4-only / no-S3 | Stops the other way |
| `omarchy restart bluetooth` reloads `btusb` + udev autosuspend | Fixes the BT case already hit here |
| Newer `amdgpu`/DMUB in `linux-omarchy` **when upstream has a DPIA fix** | Only path to a real display fix |
| Power button → shutdown | Convenience only |
| SER9 DSDT overlay / “fix” CMOS Wi-Fi in the kernel | Theatre; BIOS still owns rail-reset |

Do not pile the local equivalents (idle hacks, wakeup masks, autosuspend-off) onto this machine until one of those is chosen on purpose. The display-sleep pile is exactly what the Studio Display section refuses to build.

## Potential Alternative PCs

A different chip would not clear the list above. The Ryzen 7 255 is a current Hawk Point laptop processor. What is cheap on this box is Beelink’s firmware. What is awkward for Linux is the Studio Display on USB4. A newer or more expensive PC often keeps both.

**Beelink does publish BIOS files**, on [dr.bee-link.cn](https://dr.bee-link.cn/?dir=uploads%2FSER%2FSER9-H255%2FBIOS). This machine’s folder tops out at `SER9L106`, which is already installed, and that file did not repair the embedded controller. The notes are one line (“optimize Wi-Fi”, “solve login network”). The more expensive, newer SER9 with the Ryzen AI 9 HX 370 is in the same catalog and has the same “no S3, suspend never really sleeps” behavior. A download site is not a firmware team.

**GMKtec is the same kind of company.** Boards are often a third-party design (Sixunited and similar), BIOS files are split across support posts, and Linux users end up toggling ACPI wake bits by hand. An EVO-X2 is a faster chip in that same firmware situation.

Mini PCs whose vendors ship a BIOS for one known model, with notes, and then update it:

| Machine | What you actually get |
| --- | --- |
| **System76 Meerkat** | The small one. System76 writes the firmware (coreboot on the open-firmware models), publishes a changelog, and delivers updates through their own tool. The notes include real ACPI and resume fixes. |
| **Framework Desktop** | A small desktop, not a 13 cm cube. Ryzen AI Max. BIOS is on their download page with a version history, and Linux updates go through `fwupd`. They do fix power bugs. They also shipped a laptop BIOS that left some boards unable to boot, so a public update process is not a promise that a flash cannot fail. |
| **Lenovo ThinkCentre Tiny, Dell OptiPlex Micro, HP Elite Mini, ASUS NUC** | Business machines. Look up the exact model or service tag and get a BIOS with a changelog from that vendor’s support site. Sleep is still modern standby, and it is usually less broken than a Beelink AMI image. These are not Linux companies. |

None of those make a Studio Display on USB4 safe. That bug is the AMD or Intel USB4 tunnel plus that display, and it shows up on expensive machines too. What the extra money buys is a vendor that will still be patching the embedded controller next year, and a model name that maps to one firmware instead of eight.

## Verdict

> what are MY true practical options? switch to a intel machine? is this really the state of linux? this system seems extremely fragile to the point were i am losing trust and it's not fun to use anymore.

The fragility is this **box’s sleep stack**, not Linux as a daily OS. Work (Ghostty, Brave, Zed) on a machine you **turn off** is a different product from “hibernate a GPU-heavy Wayland session on a Beelink SER9.” You have been using the second one. That path is thin, under-tested, and on this board it is stacked on unfinished AMI ACPI plus AMD’s TTM.

**Intel does not buy you a trustworthy sleep button.** It drops *this* `amdgpu` TTM bug. Intel’s `i915`/`Xe` has its own resume bugs. A Beelink Intel mini is the same AMI firmware process. Apple Studio Display over USB4/Thunderbolt stays a vendor joint on Intel Linux too. A newer/pricier SER9 also keeps the no-S3 EC mess.

**True options**

1. **Keep this machine. Stop sleeping it.** End of day: shutdown. No hibernate, no Suspend. If a loaded S4 ever comes back, reboot before you touch windows. Ghostty+MEGAsync only if you insist on hibernate. That is the option that restores trust *this week*. The CPU, disk, and apps are fine; the power states are not.

2. **Want “leave it and come back” as a product.** Replace the **mini PC vendor**, not the CPU brand. Framework Desktop, System76 Meerkat, ThinkCentre Tiny / OptiPlex Micro / Elite Mini / ASUS NUC — a model with a real BIOS changelog and `fwupd`. Sleep there is still modern standby, and it is usually less broken than this AMI image. AMD or Intel is secondary.

3. **Want hibernate with Brave/Zed open.** That is AMD TTM + a full GPU session. Neither you nor Omarchy can patch it. A different Linux box can still hit it on Hawk Point/Strix. Shutdown stays the reliable close.

4. **Do not buy another Beelink/GMKtec** to fix this. Same firmware shop.

Linux on a maintained laptop or business Tiny, powered off or using that vendor’s suspend, is ordinary and boring. Linux hibernate through `amdgpu` TTM with Chromium, Vulkan, and Qt after S4 is a known sharp edge. This SER9 adds a BIOS that never finished sleep. That combination is why it stopped being fun — you have been living in the sharp edge.

Use **(1)** until you decide whether **(2)** is worth money. The alternative-PC table above is already that shopping list.

> sorry but the issues from a user perspective is that the whole power cycle is fucked: shutdown, suspend/standby, hibernate. plus the system can freeze suddenly. plus all the other issues. and yes, some form of actual fan powerdown that restores window states is essential for using the system.
