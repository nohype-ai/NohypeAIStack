# eFisc2025

Kanton Thurgau tax app. Vendor installer, not an Arch/Omarchy package. Java 21 Swing (Temurin 21.0.9 bundled JRE) via `jfw-launcher`. It runs as XWayland.

| Path | Role |
| --- | --- |
| `~/.local/share/efisc2025/` | app, bundled JRE, jars |
| `~/.local/share/efisc2025/efisc2025.sh` | launcher (this is what we wrap) |
| `~/.local/share/applications/efisc2025.desktop` | `Exec=…/efisc2025.sh %U`, `StartupWMClass=efisc2025` |
| `~/.Kanton TG/eFisc2025/eFisc2025.properties` | zoom, overlay font, window coords |
| `~/.local/share/efisc-ui-scale/` | HiDPI agent source + jar |

Version on this machine: `efisc2025-1.0.6`, jastine 12.2.0, jfw 8.1.3.

## What goes wrong

The panel is 5120×2880 at Hyprland scale 2. `GDK_SCALE=2` from `~/.config/hypr/monitors.lua`. Omarchy sets `xwayland.force_zero_scaling=true` in `/usr/share/omarchy/default/hypr/envs.lua`, so XWayland clients see the raw framebuffer and must scale themselves. GTK apps get `GDK_SCALE`. Swing does not.

Without a wrap, menus, toolbar, form list, and dialogs paint at ~1× and are unreadable.

## What does not work

**`-Dsun.java2d.uiScale=2` / `jfw.scale.factor`.** eFisc’s own `jfw.scale.factor` in `eFisc2025.properties` only writes `sun.java2d.uiScale`. AWT frames on this XWayland/JDK path ignore it (JDK-8375687). The UI stays 1×. Leave `jfw.scale.factor=1`.

**Compositor bitmap scale** (`xwayland.force_zero_scaling=false`). The window stays the same logical size and goes blurry. Do not do this. Keep `force_zero_scaling=true` and scale inside the app.

**Doubling every preferred/minimum/maximum size on a timer.** jfw caches toolbar painter dimensions. Multiplying those every 250 ms explodes them (`IllegalArgumentException: Dimensions … are too large`, MetalToolBarUI). Store originals once, cap, and skip toolbars / huge values / `maximumSize`.

The agent is a `-javaagent`. It is loaded only at JVM start. Changing the jar does nothing until eFisc is quit and started again.

## Fix

A small agent walks the Swing tree and doubles fonts, row heights, and icons. Dialogs and popup menus then grow to the new preferred size. Paper-form overlay fields are left at the original 10 pt so they stay proportional to the form at any form zoom.

### Launcher

`~/.local/share/efisc2025/efisc2025.sh`:

```sh
#!/bin/sh
cd /home/seb/.local/share/efisc2025
# Overlay field font must stay at the original 10pt; form zoom scales the paper.
PROP="${HOME}/.Kanton TG/eFisc2025/eFisc2025.properties"
if [ -f "$PROP" ]; then
  sed -i 's/^font.text.form=.*/font.text.form=SansSerif,10/' "$PROP"
fi
./jre/bin/java -Xmx800m -Xms800m \
  -javaagent:/home/seb/.local/share/efisc-ui-scale/efisc-ui-scale.jar=2 \
  -Dawt.appClassName=efisc2025 \
  -Djava.locale.providers=COMPAT,CLDR \
  --add-exports=java.base/sun.net.www.protocol.file=ALL-UNNAMED \
  --add-exports=java.desktop/sun.swing=ALL-UNNAMED \
  --add-exports=java.desktop/com.sun.java.swing.plaf.windows=ALL-UNNAMED \
  --add-exports=java.desktop/sun.awt.shell=ALL-UNNAMED \
  --add-exports=java.xml/com.sun.org.apache.xerces.internal.jaxp.datatype=ALL-UNNAMED \
  -jar jfw-launcher-8.1.3-obf.jar "$1"
```

The `=2` after the jar is the scale factor. The `sed` runs every start because a previous scaled run persisted `font.text.form=SansSerif,20` into the properties file.

`-Dawt.appClassName=efisc2025` is set because the agent touches AWT first; without it Hyprland sees `sun-instrument-InstrumentationImpl`. The desktop file’s `StartupWMClass=efisc2025` may still not match. Harmless for scaling.

### Agent

`~/.local/share/efisc-ui-scale/EfiscScaleAgent.java`, packed as `efisc-ui-scale.jar` (`Premain-Class: EfiscScaleAgent`).

On `premain` it:

1. Reads the scale from the agent args (default 2).
2. Listens for `WINDOW_OPENED` / `WINDOW_ACTIVATED` only. No `HIERARCHY_EVENT_MASK`: a toolkit hierarchy listener makes `Dialog.show` walk children by `descendantsCount`, and the Wertschriften editor then throws `IndexOutOfBoundsException: Index 2 out of bounds for length 2` in `Container.createHierarchyEvents`.
3. Polls the component tree for 30 s at 250 ms, then every 2 s (late dialogs, combo popups).

Per component (once, originals in client properties):

| What | How |
| --- | --- |
| Fonts | `deriveFont(orig × scale)` |
| `JTable` / `JTree` / `JList` row height | font metrics + 6, at least `18 × scale`; wrap renderers |
| Icons | wrap `Icon` in a 2× `Graphics2D.scale` painter, skip if w/h ≤ 0 or > 256 |
| Buttons | icon-text gap and margins, margins capped at 32 |
| Combos | editor, renderer, `ComboPopup` list, jfw `ch.abraxas.jfw.P.jA` height/font caches (those lock combo height to a one-shot unscaled text field) |
| Explicit `preferredSize` / `minimumSize` | buttons, labels, combos, text, menu bar, popup, option pane — orig stored once, width cap 1200, height cap 256 |
| Dialogs (`Window` that is not a `Frame`) | grow to `preferredSize + 24`, never shrink |
| `JPopupMenu` | `setPopupSize` / `pack` so menu text fits |

Skipped so the paper form stays in register with the overlay:

- anything under `ch.abraxas.jastine.K.D.A.G` (form page viewer) or `ch.abraxas.jastine.K.D.A.*`
- UI class IDs containing `JstForm`
- `JToolBar` / split pane / scroll bar preferred sizes (MetalToolBarUI crash)

### Properties

`~/.Kanton TG/eFisc2025/eFisc2025.properties` (app rewrites this on exit):

| Key | Keep | Why |
| --- | --- | --- |
| `jfw.scale.factor` | `1` | Java2D uiScale is ignored here |
| `font.text.form` | `SansSerif,10` | overlay on the paper form; launcher resets it |
| `factor.zoom.formular` | user’s zoom (1.5 here) | zooms the paper, independent of overlay font |
| `factor.zoom.dialog` | user’s zoom (2.0 here) | eFisc’s own dialog zoom; leave it |

Name/address on page 1 are overlay fields painted with `font.text.form`. If that font is 20 and the agent also doubles it, the entries are huge at every form zoom. The agent skips that subtree; the launcher pins the font at 10. Form zoom still enlarges the paper.

## Rebuild the agent

The bundled JRE has no `javac`. Compile with any JDK 21, then jar every `EfiscScaleAgent*.class` (anonymous inner classes included):

```bash
JDK=/tmp/jdk-compile/jdk-21.0.13+9   # or another JDK 21
cd ~/.local/share/efisc-ui-scale
"$JDK/bin/javac" --release 21 EfiscScaleAgent.java
"$JDK/bin/jar" cfm efisc-ui-scale.jar MANIFEST.MF EfiscScaleAgent*.class
"$JDK/bin/jar" tf efisc-ui-scale.jar
```

`MANIFEST.MF`:

```
Manifest-Version: 1.0
Premain-Class: EfiscScaleAgent
Can-Redefine-Classes: false
Can-Retransform-Classes: false
```

Missing `$2.class` (combo popup listener) throws at runtime when a combo opens.

## Apply

Quit eFisc fully, then start it from the desktop entry or:

```bash
~/.local/share/efisc2025/efisc2025.sh
```

Confirm the agent is on the process:

```bash
tr '\0' ' ' < /proc/$(pgrep -n -f jfw-launcher)/cmdline; echo
```

Expect `-javaagent:/home/seb/.local/share/efisc-ui-scale/efisc-ui-scale.jar=2`.

Check:

- Main chrome (menu bar, toolbar icons, left form list) is ~2× and sharp.
- File → a long menu item: the popup is wide enough for the text.
- A form dialog combo: closed control and dropdown list match the dialog font.
- Save / Ja–Nein dialog: both buttons fully visible.
- Page 1 name and address sit in their boxes at the current form zoom. Changing Zoom does not blow up the overlay relative to the paper.
