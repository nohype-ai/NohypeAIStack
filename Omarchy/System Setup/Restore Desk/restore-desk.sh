#!/usr/bin/env bash
# Script to layout workspaces after a boot (workspaces start empty).
# Something like this could be placed in ~/.local/bin/restore-desk

nohype_ai=/home/seb/Repos/nohype-ai/company/nohype-ai
stack=/home/seb/Repos/nohype-ai/company/NohypeAIStack

# New windows of CLASS, as "address workspace" lines. CLASS is a prefix.
windows() {
  hyprctl -j clients | jq -r --arg c "$1" '.[] | select(.class | startswith($c)) | "\(.address) \(.workspace.id)"'
}

# Focus the workspace, launch, and wait until a new window of that class is there.
# Move it if it opened elsewhere. The pause keeps a following Brave URL from
# becoming a tab in the window that just opened.
open_on() {
  local ws=$1 class=$2
  shift 2
  local before i line addr seen
  hyprctl dispatch "hl.dsp.focus({ workspace = '$ws' })"
  before=$(windows "$class")
  hyprctl dispatch "hl.dsp.exec_cmd('$*')"
  i=0
  while (( i < 50 )); do
    while read -r addr seen; do
      [[ -z $addr ]] && continue
      if [[ $before != *$addr* ]]; then
        if [[ $seen != "$ws" ]]; then
          hyprctl dispatch "hl.dsp.window.move({ workspace = '$ws', follow = false, window = 'address:$addr' })"
        fi
        sleep 1
        return 0
      fi
    done < <(windows "$class")
    sleep 0.2
    i=$((i+1))
  done
}

# workspace 1
open_on 1 md.obsidian.Obsidian obsidian

# workspace 2
open_on 2 com.mitchellh.ghostty ghostty --working-directory=$nohype_ai
open_on 2 com.thisisgm.flea flea --gui $nohype_ai

# workspace 3
open_on 3 brave brave-origin --new-window https://grok.com
open_on 3 brave brave-origin --new-window https://google.com

# workspace 4
open_on 4 brave brave-origin --new-window https://www.youtube.com/feed/subscriptions
open_on 4 brave brave-origin --new-window https://music.youtube.com
open_on 4 com.mitchellh.ghostty ghostty -e cliamp

# workspace 5
open_on 5 org.quickshell gtk-launch omamail.desktop
open_on 5 brave gtk-launch Telegram.desktop

# workspace 6
open_on 6 com.mitchellh.ghostty ghostty --working-directory=$stack
open_on 6 dev.zed.Zed zeditor --new $stack

# go to workspace 1
hyprctl dispatch "hl.dsp.focus({ workspace = '1' })"
