# Key Commands

- Key commands are an aspect of the stack that we aim to document and somewhat align across macOS and Omarchy in order to ease switching between those systems.
- The commands documented below are the spec. On macOS they are implemented by `super-keys` which documented below also.

## Launch Commands

### macOS + Omarchy (Omarchy Default)

| Destination / Intent | Shortcut | macOS App / Website |
|--------|---------|-----|
| Terminal | ⌘⏎ | Ghostty |
| Internet Browser | ⌘⇧⏎ | Brave |
| AI Assistant | ⌘⇧A | grok.com |
| Email | ⌘⇧E | Mail |
| Find(er) / File Manager | ⌘⇧F | Finder |
| Organize / Obsidian | ⌘⇧O | Obsidian |
| Music | ⌘⇧M | Music |
| Music - Secondary| ⌘⇧⌥M | music.youtube.com |
| Password Manager | ⌘⇧/ | Passwords |
| Write | ⌘⇧W | Typora |
| YouTube | ⌘⇧Y | YouTube Subscriptions URL |

### macOS + Omarchy (Omarchy Customized)

| Destination / Intent | Shortcut | macOS App / Website |
|--------|---------|-----|
| Develop | ⌘⇧D | Zed |
| Git Client | ⌘⇧G | Fork |
| Talk | ⌘⇧T | Telegram Web App URL |

### macOS Only

| Destination / Intent | Shortcut | macOS App / Website |
|--------|---------|-----|
| Develop - Secondary | ⌘⇧⌥D | Selected Xcode (`xcode-select -p`) |
| System Settings | ⌘⇧S | System Settings |
| Talk - Secondary | ⌘⇧⌥T | WhatsApp |
| Trash | ⌘⇧⌫ | Open Trash |

## Do Stuff In Active File Manager Folder (only macOS Finder so far)

| Destination / Intent | Shortcut | macOS Action |
|--------|---------|-----|
| Terminal in folder | ⌘⌃⏎ | Open folder in Terminal |
| Develop in folder | ⌘⇧⌃D | Open folder in Zed |
| Create new file in folder | ⌘⇧⌃F | Create `_new.md` and select it in Finder |
| Write in folder | ⌘⇧⌃W | Open folder in Typora |

## System Control Commands

### macOS + Omarchy (Omarchy Default)

| Destination / Intent | Shortcut | macOS Action |
|--------|---------|-----|
| Control Audio | ⌃⌘A | Toggle SoundSource app (configure directly in SoundSource) |

### macOS Only

| Destination / Intent | Shortcut | macOS Action |
|--------|---------|-----|
| Switch Dark/Day Mode | ⌃⌘D | Toggle System Appearance |
| Put System to Sleep | ⌃⌘S | System -> Sleep |
| Empty the Trash | ⌃⌘⌫ | Empty Trash |

## super-keys

On macOS the shortcuts above are registered by [`super-keys`](https://github.com/nohype-ai/SuperKeys). It is a CLI with an AppKit run loop, not an `.app`. `launchd` keeps it running.

MacStack's Homebrew formula depends on `super-keys`, so installing MacStack installs the command. This stack does not build or store the binary.

### Daily use

Do nothing. After login it is already running. The shortcuts in this file should just work.

If a Finder-folder shortcut asks for Automation (control Finder), allow it once.

If keys do nothing after a reboot: System Settings → General → Login Items → allow `super-keys` in the background. A newly installed binary also needs Input Monitoring.

Log: `~/Library/Logs/super-keys.log`

### What runs it

| Piece | Where | In git? |
|--------|--------|---------|
| Program | `$(brew --prefix super-keys)/bin/super-keys` | no — Homebrew |
| Generator | `launch-agent.sh` | yes |
| Installed agent | `~/Library/LaunchAgents/ai.nohype.super-keys.plist` | no — written on this Mac |
| launchd label | `ai.nohype.super-keys` | — |

`launch-agent.sh` writes that plist with the Homebrew binary, then `bootout` + `bootstrap`. It does not sign the binary. Homebrew owns the install.

Who registers it:

1. **`mack update`** — Homebrew upgrades packages first (including `super-keys`, via the MacStack formula). Then `macOS/MacStack/update.sh` runs `launch-agent.sh`.
2. **`launchd`, at login** — the installed plist has `RunAtLoad` and `KeepAlive`.

The plist uses Homebrew's `opt/super-keys` symlink, so the path stays valid across upgrades. `mack update` still restarts the agent so the process is the new binary.

Bindings are compiled into the SuperKeys repo (`Sources/SuperKeys/SuperKeys.swift`). Change them there, release, then `mack update`.

Reload the agent without a Homebrew upgrade: `./launch-agent.sh`

Stop it (until next login or next `launch-agent.sh`):

```bash
launchctl bootout gui/$(id -u)/ai.nohype.super-keys
```

Status: `launchctl print gui/$(id -u)/ai.nohype.super-keys`

Do not run a second copy from Terminal while the agent is up — they fight over the same hotkeys.
