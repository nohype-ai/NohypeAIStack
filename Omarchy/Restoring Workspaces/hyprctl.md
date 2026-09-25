# hyprctl for scripted layouts

`hyprctl` talks to the running Hyprland compositor. Restoration here means: **launch apps onto workspaces, then nudge focus / splits**. It does not snapshot RAM or reopen unsaved buffers. That is still hibernate, and on this machine loaded S4 is a [known issue](../README.md#desktop-frozen-after-hibernate-resume-amdgpu-ttm) — use a layout script after a normal boot, not as a substitute for resume.

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
hyprctl dispatch <command> [args]
hyprctl --batch "dispatch A; dispatch B; dispatch C"
```

If the app args start with `-`, put `--` after `exec`:

```bash
hyprctl dispatch -- exec brave-origin --new-window https://github.com
```

---

## Workspaces

| Command | Effect |
|---|---|
| `workspace N` | Show workspace N on the focused monitor |
| `workspace m+1` / `m-1` | Next/prev on this monitor |
| `movetoworkspace N` | Move focused window to N and follow |
| `movetoworkspacesilent N` | Move it, stay where you are |
| `movetoworkspacesilent N,address:0x…` | Move a specific window |

Numbers 1–5 are what Omarchy binds to Super+1…5.

---

## Launching (the core of a layout script)

```bash
hyprctl dispatch exec "[RULES] command args"
```

Rules that matter:

| Rule | Meaning |
|---|---|
| `workspace N` | Land on workspace N, also switch there |
| `workspace N silent` | Land on N, **don’t** switch |
| `float` | Start floating |
| `tile` | Start tiled |
| `fullscreen` | Start fullscreen |

Window rules on `exec` attach to the **spawned PID**. Apps that reuse a single process (Brave, Firefox) often ignore the workspace rule for window 2+. `--new-window` helps; it is not perfect.

### Folders

```bash
hyprctl dispatch exec "[workspace 1 silent] flea $HOME/Projects"
hyprctl dispatch exec "[workspace 2 silent] ghostty --working-directory=$HOME/Projects"
hyprctl dispatch exec "[workspace 3 silent] zeditor $HOME/Projects"
```

### Websites (Brave Origin)

```bash
hyprctl dispatch exec "[workspace 4 silent] brave-origin --new-window https://github.com"
hyprctl dispatch exec "[workspace 5 silent] brave-origin --new-window https://mail.google.com"
```

---

## Windows

Select by `class:`, `title:`, or `address:`.

```bash
hyprctl dispatch focuswindow class:brave-origin
hyprctl dispatch focuswindow title:GitHub
hyprctl dispatch closewindow address:0x123
hyprctl dispatch killwindow address:0x123    # harder
```

Useful dispatches:

| Command | Effect |
|---|---|
| `focuswindow <sel>` | Focus |
| `closewindow <sel>` | Ask it to quit |
| `fullscreen` | Toggle fullscreen |
| `togglefloating` | Tile ↔ float |
| `pin` | Stay visible across workspaces |
| `movewindow l\|r\|u\|d` | Move in the tile tree |
| `resizeactive 10% 0` | Resize focused (mostly float / some layouts) |
| `swapnext` | Swap with next window |

List classes actually in use:

```bash
hyprctl -j clients | jq -r '.[] | "\(.workspace.id) \(.class) \(.title)"'
```

---

## Tiling

Applies to **whatever is focused**. After `exec`, wait until the window exists, then focus it, then split.

Dwindle (Omarchy default-ish):

| Command | Effect |
|---|---|
| `layoutmsg preselect l\|r\|u\|d` | Next new window splits to that side |
| `togglesplit` | Flip current split axis |
| `splitratio 0.1` | Grow/shrink current split a bit |
| `splitratio exact 0.6` | Set ratio (0.6 = 60% for the focused side) |

Master layout (if enabled):

| Command | Effect |
|---|---|
| `layoutmsg swapwithmaster` | Swap focused with master |
| `layoutmsg cyclenext` | Cycle stack |
| `layoutmsg orientationleft` / `orientationtop` | Master side |

Pattern:

```bash
hyprctl dispatch workspace 2
hyprctl dispatch exec "ghostty --working-directory=$HOME/Projects"
sleep 0.4
hyprctl dispatch layoutmsg preselect r
hyprctl dispatch exec "ghostty --working-directory=$HOME/Projects"
sleep 0.4
hyprctl dispatch splitratio exact 0.6
```

`sleep` is required. Hyprland cannot split a window that has not mapped yet.

---

## Detect vs ignore

**Ignore (what we did):** always `exec`. Second run = duplicate windows.

**Detect:**

```bash
hyprctl -j clients | jq -e '.[] | select(.class=="Nautilus")' >/dev/null
```

**Reset first:**

```bash
hyprctl -j clients | jq -r '.[].address' | while read -r a; do
  hyprctl dispatch closewindow "address:$a"
done
sleep 0.3
```

---

## Minimal layout (the example)

```bash
#!/usr/bin/env bash
# ~/.local/bin/layout-work

hyprctl dispatch exec "[workspace 1 silent] flea $HOME/Projects"
hyprctl dispatch exec "[workspace 2 silent] ghostty --working-directory=$HOME/Projects"
hyprctl dispatch exec "[workspace 3 silent] zeditor $HOME/Projects"
hyprctl dispatch exec "[workspace 4 silent] brave-origin --new-window https://github.com"
hyprctl dispatch exec "[workspace 4 silent] brave-origin --new-window https://docs.hypr.land"
hyprctl dispatch exec "[workspace 5 silent] brave-origin --new-window https://mail.google.com"
hyprctl dispatch workspace 1
```

`silent` = place without jumping. Final `workspace 1` = take you there.

---

## Limits

- No unsaved editor state, no scroll position, no cookie-less “exactly this tab set” unless the app does that itself.
- Brave/Chromium often dump extra windows on the current workspace if a process is already running.
- Split ratios are live commands, not a saved BSP tree. Reboots start from empty workspaces.
- Batch `exec` + `sleep` is the reliable model. Tight loops without waits lose races.

For “the desk as I left it,” use hibernate. For “the desk I always want,” use this.
