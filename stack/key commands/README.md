# Key Commands

- Key commands are an aspect of the stack that we aim to document and somewhat align across macOS and Omarchy in order to ease switching between those systems.
- The commands documented below are the spec. On macOS they are implemented by `super-keys`. which documented below also.

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

A Swift package (`SuperKeys/`) that registers the global hotkeys. It is a CLI with an AppKit run loop, not an `.app`. `launchd` keeps it running.

### Daily use

Do nothing. After login it is already running. The shortcuts in this file should just work.

If a Finder-folder shortcut asks for Automation (control Finder), allow it once.

If keys do nothing after a reboot: System Settings → General → Login Items → allow `super-keys` in the background.

Log: `~/Library/Logs/super-keys.log`

### What runs it

There is no LaunchAgent source in the Swift package. `launchd` runs whatever plist is registered for the user session.

| Piece | Where | In git? |
|--------|--------|---------|
| Program | `stack/bin/super-keys` | yes (copied there by `build.sh`) |
| Generator | `launch-agent.sh` | yes |
| Installed agent | `~/Library/LaunchAgents/ai.nohype.super-keys.plist` | no — written on this Mac |
| Identity | `ai.nohype.super-keys` (codesign + launchd label) | — |

`launch-agent.sh` signs the binary (ad-hoc, identifier `ai.nohype.super-keys`), writes that plist, then `bootout` + `bootstrap` so `launchd` picks it up.

Who registers it:

1. **You, while developing** — `build.sh` builds, copies to `bin/`, then runs `launch-agent.sh`.
2. **`mack update`** — `stack/update.sh` runs `launch-agent.sh` (reload only, no compile).
3. **`launchd`, at login** — the installed plist has `RunAtLoad` and `KeepAlive`. After that, nothing in the stack needs to start it.

### Work on it

Bindings live in `SuperKeys/Sources/SuperKeys/SuperKeys.swift`.

```bash
# from this folder: rebuild, re-sign, rewrite plist, restart the running agent
./build.sh
```

That is the update path while it is registered. `launch-agent.sh` unloads the old job, kills any other `super-keys`, loads the new job. `KeepAlive` then holds the new binary.

Reload the agent without compiling (path/sign/plist only): `./launch-agent.sh`

Stop it (until next login or next `launch-agent.sh`):

```bash
launchctl bootout gui/$(id -u)/ai.nohype.super-keys
```

Status: `launchctl print gui/$(id -u)/ai.nohype.super-keys`

Do not run a second copy from Terminal or Xcode while the agent is up — they fight over the same hotkeys. To debug in Xcode: `bootout` first, run from Xcode, `./launch-agent.sh` when done.

### Binary path

The installed plist hardcodes an absolute path to `stack/bin/super-keys` (resolved when `launch-agent.sh` runs). `launchd` does not expand `$STACK` or `PATH`. If you move this repo, re-run `./launch-agent.sh` or `mack update`.

A real `.app` avoids that by living at a stable location (`/Applications/…`) and registering a **bundle-relative** helper: macOS 13+ `BundleProgram` inside `Contents/Library/LaunchAgents/`, or `SMAppService` from ServiceManagement. The helper path is then relative to the `.app`, so moving the app does not break the agent. We skip that while SuperKeys stays a stack CLI.
