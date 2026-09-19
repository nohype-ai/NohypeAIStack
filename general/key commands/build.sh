#!/usr/bin/env zsh
set -e
set -u

here=${0:a:h}
repo_root=${here:h:h}
dest="$repo_root/macOS/MacStack/bin/super-keys"

swift build -c release --package-path "$here/SuperKeys"
bin_dir=$(swift build -c release --package-path "$here/SuperKeys" --show-bin-path)
cp -f "$bin_dir/super-keys" "$dest"
"$here/launch-agent.sh"
