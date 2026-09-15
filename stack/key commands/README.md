# Key Commands

- Key commands are an aspect of the stack that we aim to document and somewhat align across macOS and Omarchy in order to ease switching between those systems.
- The global key commands on macOS are implemented by our own tool `super-keys`.
- the script `build.sh` builds `super-keys` and adds it to the stack's `bin` folder so it's available globally.
- `super-keys` must of course be running in order to process the key commands.

## Launch Stuff

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
| Terminal in folder | ⌘⌃⏎ | 🚧 Open folder in Terminal |
| Develop in folder | ⌘⇧⌃D | 🚧 Open folder in Zed |
| Create new file in folder | ⌘⇧⌃F | Create `_new.md` and select it in Finder |
| Write in folder | ⌘⇧⌃W | 🚧 Open folder in Typora |

## System Controls

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
