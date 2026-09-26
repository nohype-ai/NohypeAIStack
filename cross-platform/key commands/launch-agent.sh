#!/usr/bin/env zsh
set -e
set -u

label=ai.nohype.super-keys
plist="$HOME/Library/LaunchAgents/${label}.plist"
uid=$(id -u)
domain="gui/${uid}"
log="$HOME/Library/Logs/super-keys.log"

# Installed by Homebrew because the MacStack formula depends on super-keys.
# opt/ is a stable symlink to the current keg, so the plist survives upgrades.
if ! command -v brew >/dev/null 2>&1; then
    echo "🛑 Homebrew is required. super-keys is installed with MacStack."
    exit 1
fi

prefix="$(brew --prefix super-keys 2>/dev/null || true)"
bin="${prefix}/bin/super-keys"
if [[ ! -x $bin ]]; then
    echo "🛑 super-keys is not installed. It comes with MacStack: brew install nohype-ai/tap/macstack"
    exit 1
fi

mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"

cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>${label}</string>
	<key>ProgramArguments</key>
	<array>
		<string>${bin}</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>KeepAlive</key>
	<true/>
	<key>ProcessType</key>
	<string>Interactive</string>
	<key>LimitLoadToSessionType</key>
	<string>Aqua</string>
	<key>StandardOutPath</key>
	<string>${log}</string>
	<key>StandardErrorPath</key>
	<string>${log}</string>
</dict>
</plist>
EOF

launchctl bootout "$domain/$label" 2>/dev/null || true
pkill -x super-keys 2>/dev/null || true
launchctl bootstrap "$domain" "$plist"
launchctl enable "$domain/$label"
echo "🔑 super-keys LaunchAgent loaded ($domain/$label)"
