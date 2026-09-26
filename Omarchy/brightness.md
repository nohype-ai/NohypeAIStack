# Brightness Control

The brightness keys, the on-screen indicator, and the monitor-panel slider all call `omarchy-brightness-display`. On an external monitor that runs `omarchy-brightness-display-ddc`, which calls `ddcutil` with `--skip-ddc-checks`. On the LG UltraGear+ that write returns success and leaves VCP `0x10` unchanged. Plain `ddcutil setvcp 10 <value>` changes the panel. The I2C bus number comes from `ddcutil detect` and is not pinned in these files.

`ddcutil` is an Omarchy package. The packaged helper is replaced by `omarchy update`, so the flag is removed by a `ddcutil` earlier on `PATH`. Dynamic sleep also lengthens every later write (measured 0.59s, then 0.70s, 0.86s, 1.16s, 1.25s). The config below holds a write at about 0.32s.

Leave the brightness keys out of `~/.config/hypr/bindings.lua`. The Omarchy defaults already bind them:

| Keys | Command |
| --- | --- |
| Brightness up / down | `omarchy-brightness-display +5%` / `5%-` |
| Alt + brightness up / down | `omarchy-brightness-display +1%` / `1%-` |
| Shift + brightness up / down | `omarchy-brightness-display 100%` / `1%` |

**1. Confirm the panel answers**

```bash
ddcutil detect
ddcutil getvcp 10
ddcutil setvcp 10 30
ddcutil getvcp 10
```

`getvcp` after the set shows current value `30`. If `ddcutil` cannot open the I2C device, log in again so the seat ACL from `60-ddcutil-i2c.rules` applies. Install with `omarchy pkg add ddcutil` when the command is missing.

**2. Pin the wait** — `~/.config/ddcutil/ddcutilrc`

```
[ddcutil]
options: --disable-dynamic-sleep --sleep-multiplier 0.02
```

**3. Drop `--skip-ddc-checks`** — `~/.local/lib/ddcutil-shim/ddcutil`

```bash
mkdir -p ~/.local/lib/ddcutil-shim
cat > ~/.local/lib/ddcutil-shim/ddcutil << 'EOF'
#!/bin/bash
# Omarchy's brightness helper always passes --skip-ddc-checks. On the LG
# UltraGear+ that write returns success and leaves VCP 0x10 unchanged.
args=()
for arg in "$@"; do
  [[ $arg == --skip-ddc-checks ]] && continue
  args+=("$arg")
done
exec /usr/bin/ddcutil "${args[@]}"
EOF
chmod +x ~/.local/lib/ddcutil-shim/ddcutil
```

**4. Put the shim first on PATH** — end of `~/.config/hypr/hyprland.lua`, after `require("default.hypr.omarchy")` and `require("default.hypr.toggles")`. An earlier `hl.env("PATH", ...)` is replaced by Omarchy's default.

```lua
local ddcutil_shim = (os.getenv("HOME") or "") .. "/.local/lib/ddcutil-shim"
local omarchy_bin = (os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/bin"
local path_parts = { ddcutil_shim, omarchy_bin }
local path_seen = { [ddcutil_shim] = true, [omarchy_bin] = true }
for entry in string.gmatch(os.getenv("PATH") or "/usr/local/bin:/usr/bin", "[^:]+") do
  if not path_seen[entry] then
    path_seen[entry] = true
    table.insert(path_parts, entry)
  end
end
hl.env("PATH", table.concat(path_parts, ":"))
```

**Apply**

```bash
hyprctl reload
hyprctl configerrors
omarchy restart shell
```

**Confirm**

```bash
PATH="$HOME/.local/lib/ddcutil-shim:$PATH" omarchy-brightness-display 90%
ddcutil getvcp 10
PATH="$HOME/.local/lib/ddcutil-shim:$PATH" omarchy-brightness-display 100%
```

`getvcp` shows the same level the command just set, and the on-screen indicator appears. The brightness keys and the monitor-panel slider use that same command. A terminal's own `PATH` does not include the shim; the `PATH=` prefix above is only for this check.

