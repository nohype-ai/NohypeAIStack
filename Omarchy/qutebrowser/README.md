# Qutebrowser

`omarchy pkg add qutebrowser` installs Arch extra `qutebrowser` (3.7.0-1 on this machine). Brave Origin stays the default browser.

It is on this machine for three reasons that suit a tiling desktop:

- Key commands. Pages are driven from the keyboard.
- Minimal UI chrome. The tab bar and the status bar are the browser UI.
- Squishability. The window can be narrowed into a column for a small page preview. Brave and Zen keep a wide minimum, so the same preview fights the tile.

`python-adblock`, `python-pygments`, and `pdfjs-legacy` stay uninstalled. `:adblock-update` still fills the hosts blocker and rewrites `~/.local/share/qutebrowser/blocked-hosts` from the default StevenBlack list, one host per line. That file is the list in use.

## Ctrl+Super+F

Ctrl+Super+F is Omarchy's tiled fullscreen (default binding Super+Ctrl+F, label "Tiled full screen"). The window stays in its tile, and Hyprland marks the client fullscreen. Brave hides its toolbar from that flag. Copy [`qutebrowser/config.py`](qutebrowser/config.py) to `~/.config/qutebrowser/config.py`. While the flag is on, that window's tab bar is hidden. The status bar is hidden in normal mode and shown in command, hint, insert, and the other key modes, so `:` and hints still have a line to draw on. A window that is not in tiled fullscreen keeps both bars. Press Ctrl+Super+F again and the bars come back with the tile.

`tabs.show` and `statusbar.show` are process-wide. A `config.bind` cycle of those two settings would change every qutebrowser window at once, so the config follows each window's fullscreen flag instead.

Apply a running instance with `:config-source`. A new process reads the file at startup.

## Memory

### The Test

Qutebrowser generally uses more memory than Brave Origin. On 2026-10-04 both windows had the same three tabs open (`grok.com`, `www.apple.com`, `search.brave.com/ask`). With each shared page counted once, qutebrowser held about 960 MiB and Brave Origin about 800 MiB. qutebrowser was 3.7.0 on Qt WebEngine 6.11.2 (Chromium 140). Brave Origin was 154.1.96.59. The per-process resident column sums the other way, about 1.6 GiB for qutebrowser and 2.2 GiB for Brave, because Brave's libraries sit in more processes and get added once per process.

### The General Reasons

- Program overhead. Qt WebEngine is Chromium, so a page costs about the same in both. The extra is CPython and PyQt, with the GPU and the network stack inside that same process. That cost is there from the first tab, and the Python process grows with the session.
- Closed tabs. Qutebrowser holds the memory of tabs already closed. The Python process keeps what it grew, and a restart is what returns it.
- Inactive tabs. Brave reduces the memory of tabs that are still open and only inactive.
- Blocking. Brave's built-in ad and content blocking is stronger. This machine's qutebrowser uses the hosts list, and `python-adblock` is not installed. On the three tabs above the page processes were within about 30 MiB, so blocking did not produce that result. It does on ordinary ad-heavy pages. `python-pygments` and `pdfjs-legacy` play no part.
