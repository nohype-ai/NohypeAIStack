# Qutebrowser

`omarchy pkg add qutebrowser` installs Arch extra `qutebrowser` (3.7.0-1 on this machine). Brave Origin stays the default browser.

It is on this machine for four reasons that suit a tiling desktop:

- Key commands. Pages are driven from the keyboard.
- Memory footprint. A window stays lighter than Brave or Zen.
- Minimal UI chrome. The tab bar and the status bar are the browser UI.
- Squishability. The window can be narrowed into a column for a small page preview. Brave and Zen keep a wide minimum, so the same preview fights the tile.

`python-adblock`, `python-pygments`, and `pdfjs-legacy` stay uninstalled. `:adblock-update` still fills the hosts blocker and rewrites `~/.local/share/qutebrowser/blocked-hosts` from the default StevenBlack list, one host per line. That file is the list in use.

Ctrl+Super+F is Omarchy's tiled fullscreen (default binding Super+Ctrl+F, label "Tiled full screen"). The window stays in its tile, and Hyprland marks the client fullscreen. Brave hides its toolbar from that flag. Copy [`qutebrowser/config.py`](qutebrowser/config.py) to `~/.config/qutebrowser/config.py`. While the flag is on, that window's tab bar is hidden. The status bar is hidden in normal mode and shown in command, hint, insert, and the other key modes, so `:` and hints still have a line to draw on. A window that is not in tiled fullscreen keeps both bars. Press Ctrl+Super+F again and the bars come back with the tile.

`tabs.show` and `statusbar.show` are process-wide. A `config.bind` cycle of those two settings would change every qutebrowser window at once, so the config follows each window's fullscreen flag instead.

Apply a running instance with `:config-source`. A new process reads the file at startup.
