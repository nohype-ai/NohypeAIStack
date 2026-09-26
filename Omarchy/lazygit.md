# Super + Shift + G → Lazygit (cwd of the open terminal)

Omarchy default: **Signal**. This machine opens **Lazygit** instead, in the folder of the terminal you are in.

Do **not** use `{ tui = "lazygit" }` and do **not** depend on an `omarchy tui install` desktop launcher. That runs `omarchy-launch-tui lazygit` with no working directory. Ghostty is `gtk-single-instance`, so the new window inherits a stale cwd instead of the folder you have open.

`lazygit` is already on the Omarchy base install.

**File:** `~/.config/hypr/bindings.lua`

**Change:**

```lua
-- Lazygit TUI — replaces default Signal on this key.
-- Start in the focused terminal's cwd (same helper as Super+Return). If the
-- focused window is not a terminal, use the Ghostty window's cwd instead.
-- The inner `cd` is required: Ghostty gtk-single-instance ignores launcher cwd.
hl.unbind("SUPER + SHIFT + G")
o.bind(
  "SUPER + SHIFT + G",
  "Lazygit",
  "bash -lc "
    .. o.shell_quote([=[
cwd=$(omarchy-cmd-terminal-cwd)
class=$(hyprctl activewindow -j | jq -r '.class // empty')
case "$class" in
  com.mitchellh.ghostty|foot|Alacritty|kitty|org.codeberg.dnkl.foot|wezterm|org.omarchy.*|TUI.*) ;;
  *)
    gpid=$(hyprctl clients -j | jq -r '.[] | select(.class=="com.mitchellh.ghostty") | .pid' | head -n1)
    if [[ -n ${gpid:-} ]]; then
      for sp in $(pgrep -P "$gpid"); do
        exe=$(readlink -f "/proc/$sp/exe" 2>/dev/null) || continue
        grep -Fqsx "$exe" /etc/shells || continue
        d=$(readlink -f "/proc/$sp/cwd" 2>/dev/null)
        [[ -d $d ]] && cwd=$d && break
      done
    fi
    ;;
esac
exec omarchy-launch-tui --app-id=org.omarchy.lazygit bash -lc 'cd -- "$1" && exec lazygit' lazygit "$cwd"
]=])
)
```

What that does:

1. `omarchy-cmd-terminal-cwd` — cwd of the focused terminal (same helper Super+Return uses).
2. If the focused window is not a terminal, take the Ghostty window’s shell cwd so the shortcut still works from a browser, etc.
3. `omarchy-launch-tui` starts Lazygit in the default terminal, then `cd`s into that folder before `exec lazygit`. The inner `cd` is what Ghostty cannot ignore.

If the folder is not a git repo, Lazygit may offer recent repos — that is Lazygit, not the binding.

**Apply:** Hyprland reloads on save. Force with `hyprctl reload`, then check `hyprctl configerrors`. Confirm with:

```bash
omarchy menu keybindings --print | grep -i 'SHIFT + G'
```

Expect `SUPER SHIFT + G → Lazygit`. From Ghostty, `cd` into a git repo and press Super+Shift+G; Lazygit should open that repo. Signal is still launchable from the app menu (`omarchy launch signal`).

