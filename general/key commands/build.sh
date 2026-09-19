#!/usr/bin/env zsh
set -e
set -u

here=${0:a:h}
stack_folder=${here:h}

swift build -c release --package-path "$here/SuperKeys"
bin_dir=$(swift build -c release --package-path "$here/SuperKeys" --show-bin-path)
cp -f "$bin_dir/super-keys" "$stack_folder/bin/super-keys"
"$here/launch-agent.sh"
