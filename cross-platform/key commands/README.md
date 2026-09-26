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

On macOS the shortcuts above are registered by [`super-keys`](https://github.com/nohype-ai/SuperKeys). It is a CLI with an AppKit run loop, not an `.app`. The tool registers its own login agent. This stack does not.

MacStack's Homebrew formula depends on `super-keys`, so installing MacStack installs the command.

### Daily use

Do nothing. After login it is already running. The shortcuts in this file should just work.

If a Finder-folder shortcut asks for Automation (control Finder), allow it once.

If keys do nothing after a reboot: System Settings → General → Login Items → allow `super-keys` in the background. A newly installed binary also needs Input Monitoring.

Log: `~/Library/Logs/super-keys.log`

`mack update` upgrades Homebrew first, then runs `super-keys`. That refreshes the agent onto the current binary. Running `super-keys` yourself does the same thing.

```bash
super-keys stop
```

Status: `launchctl print gui/$(id -u)/ai.nohype.super-keys`

Bindings are read from `~/.config/super-keys/bindings.toml`. This stack keeps a copy at [macOS/MacStack/super-keys/bindings.toml](../../macOS/MacStack/super-keys/bindings.toml). Restoring that copy is not wired up yet. Edit `~/.config/super-keys/bindings.toml`, then run `super-keys` again.
