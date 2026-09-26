# hyprctl for scripted layouts

`hyprctl` talks to the running Hyprland compositor. Restoration here means: **launch apps onto workspaces, then nudge focus / splits**. It does not snapshot RAM or reopen unsaved buffers. That is still hibernate, and on this machine loaded S4 is a [known issue](../README.md#desktop-frozen-after-hibernate-resume-amdgpu-ttm) — use a layout script after a normal boot, not as a substitute for resume.

Omarchy’s Hyprland is Lua. `hyprctl dispatch` is a shorthand for `hl.dispatch(...)`, so the argument has to be a Lua dispatcher (`hl.dsp.*`), not the old `exec [workspace 1 silent] …` text.

Inspect first, then dispatch.

```bash
hyprctl -j monitors
hyprctl -j workspaces
hyprctl -j clients          # every window
hyprctl -j activewindow
hyprctl -j activeworkspace
```

JSON + `jq` is how scripts decide what exists.

---

## Dispatch

```bash
hyprctl dispatch 'hl.dsp.focus({ workspace = "1" })'
hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "1" }))'
hyprctl --batch "dispatch hl.dsp.exec_cmd('obsidian', { workspace = '1 silent' }); dispatch hl.dsp.focus({ workspace = '1' })"
```

---

## Workspaces

| Command | Effect |
|---|---|
| `hl.dsp.focus({ workspace = "N" })` | Show workspace N on the focused monitor |
| `hl.dsp.focus({ workspace = "m+1" })` / `"m-1"` | Next/prev on this monitor |
| `hl.dsp.window.move({ workspace = "N" })` | Move focused window to N and follow |
| `hl.dsp.window.move({ workspace = "N", follow = false })` | Move it, stay where you are |
| `hl.dsp.window.move({ workspace = "N", follow = false, window = "address:0x…" })` | Move a specific window |

Numbers 1–5 are what Omarchy binds to Super+1…5.

---

## Launching (the core of a layout script)

```bash
hyprctl dispatch "hl.dsp.exec_cmd('command args', { workspace = 'N silent' })"
```

Rules that matter on `exec_cmd`:

| Rule | Meaning |
|---|---|
| `workspace = "N"` | Land on workspace N, also switch there |
| `workspace = "N silent"` | Land on N, don’t switch |
| `float = true` | Start floating |
| `tile = true` | Start tiled |
| `fullscreen = true` | Start fullscreen |

Those rules attach to the spawned process. Brave, Zed, and OmaMail ignore them, because the window is created by a process that is already running. `restore-desk.sh` uses one helper for every launch: focus the workspace, launch, and wait until a new window of that class is there. A Brave URL sent before that window has settled becomes a tab.

### Folders

```bash
hyprctl dispatch "hl.dsp.exec_cmd('flea --gui $HOME/Projects', { workspace = '1 silent' })"
hyprctl dispatch "hl.dsp.exec_cmd('ghostty --working-directory=$HOME/Projects', { workspace = '2 silent' })"
hyprctl dispatch "hl.dsp.exec_cmd('zeditor $HOME/Projects', { workspace = '3 silent' })"
```

### Websites (Brave Origin)

```bash
hyprctl dispatch "hl.dsp.focus({ workspace = '4' })"
hyprctl dispatch "hl.dsp.exec_cmd('brave-origin --new-window https://github.com')"
# wait until a new brave-origin window exists, then:
hyprctl dispatch "hl.dsp.focus({ workspace = '5' })"
hyprctl dispatch "hl.dsp.exec_cmd('brave-origin --new-window https://mail.google.com')"
```

---

## Windows

Select by `class:`, `title:`, or `address:`.

```bash
hyprctl dispatch "hl.dsp.focus({ window = 'class:brave-origin' })"
hyprctl dispatch "hl.dsp.focus({ window = 'title:GitHub' })"
hyprctl dispatch "hl.dsp.window.close({ window = 'address:0x123' })"
hyprctl dispatch "hl.dsp.window.kill({ window = 'address:0x123' })"    # harder
```

Useful dispatches:

| Command | Effect |
|---|---|
| `hl.dsp.focus({ window = "<sel>" })` | Focus |
| `hl.dsp.window.close({ window = "<sel>" })` | Ask it to quit |
| `hl.dsp.window.fullscreen()` | Toggle fullscreen |
| `hl.dsp.window.float({ action = "toggle" })` | Tile ↔ float |
| `hl.dsp.window.pin()` | Stay visible across workspaces |
| `hl.dsp.window.move({ direction = "l" })` | Move in the tile tree (`l`/`r`/`u`/`d`) |
| `hl.dsp.window.resize({ x = 10, y = 0, relative = true })` | Resize focused |
| `hl.dsp.window.swap({ next = true })` | Swap with next window |

List classes actually in use:

```bash
hyprctl -j clients | jq -r '.[] | "\(.workspace.id) \(.class) \(.title)"'
```

---

## Tiling

Applies to **whatever is focused**. After `exec_cmd`, wait until the window exists, then focus it, then split.

Dwindle (Omarchy default-ish):

| Command | Effect |
|---|---|
| `hl.dsp.layout("preselect l")` (or `r`/`u`/`d`) | Next new window splits to that side |
| `hl.dsp.layout("togglesplit")` | Flip current split axis |
| `hl.dsp.layout("splitratio 0.1")` | Grow/shrink current split a bit |
| `hl.dsp.layout("splitratio exact 0.6")` | Set ratio (0.6 = 60% for the focused side) |

Master layout (if enabled):

| Command | Effect |
|---|---|
| `hl.dsp.layout("swapwithmaster")` | Swap focused with master |
| `hl.dsp.layout("cyclenext")` | Cycle stack |
| `hl.dsp.layout("orientationleft")` / `"orientationtop"` | Master side |

Pattern:

```bash
hyprctl dispatch 'hl.dsp.focus({ workspace = "2" })'
hyprctl dispatch "hl.dsp.exec_cmd('ghostty --working-directory=$HOME/Projects')"
sleep 0.4
hyprctl dispatch 'hl.dsp.layout("preselect r")'
hyprctl dispatch "hl.dsp.exec_cmd('ghostty --working-directory=$HOME/Projects')"
sleep 0.4
hyprctl dispatch 'hl.dsp.layout("splitratio exact 0.6")'
```

`sleep` is required. Hyprland cannot split a window that has not mapped yet.

---

## Detect vs ignore

**Ignore (what we did):** always `exec_cmd`. Second run = duplicate windows.

**Detect:**

```bash
hyprctl -j clients | jq -e '.[] | select(.class=="Nautilus")' >/dev/null
```

**Reset first:**

```bash
hyprctl -j clients | jq -r '.[].address' | while read -r a; do
  hyprctl dispatch "hl.dsp.window.close({ window = 'address:$a' })"
done
sleep 0.3
```

---

## Minimal layout (the example)

The checked-in script is [`restore-desk.sh`](restore-desk.sh). Workspaces are assumed empty (a new session after reboot). It launches this desk:

| Workspace | Apps |
|---|---|
| 1 | Obsidian |
| 2 | Ghostty + Flea on `.../company/nohype-ai` |
| 3 | Brave Origin: grok.com, google.com |
| 4 | Brave Origin: YouTube Music, YouTube subscriptions; Ghostty running cliamp |
| 5 | OmaMail (`gtk-launch omamail.desktop`, same as Super+Space) and the Telegram web app (`gtk-launch Telegram.desktop`) |
| 6 | Ghostty + Zed (`zeditor --new`) on `.../company/NohypeAIStack` |

Every launch is `open_on WORKSPACE CLASS COMMAND`. Final focus is workspace 1.

---

## Limits

- No unsaved editor state, no scroll position, no cookie-less “exactly this tab set” unless the app does that itself.
- Brave/Chromium often dump extra windows on the current workspace if a process is already running.
- Split ratios are live commands, not a saved BSP tree. Reboots start from empty workspaces.

For “the desk as I left it,” use hibernate. For “the desk I always want,” use this.
