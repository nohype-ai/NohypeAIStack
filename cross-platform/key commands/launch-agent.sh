#!/usr/bin/env zsh
set -e
set -u

here=${0:a:h}
bin="${here:h:h}/macOS/MacStack/bin/super-keys"
label=ai.nohype.super-keys
plist="$HOME/Library/LaunchAgents/${label}.plist"
uid=$(id -u)
domain="gui/${uid}"
log="$HOME/Library/Logs/super-keys.log"

if [[ ! -x $bin ]]; then
    echo "🛑 $bin is missing or not executable"
    exit 1
fi

codesign --sign - --identifier "$label" --force "$bin"
xattr -d com.apple.quarantine "$bin" 2>/dev/null || true

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
