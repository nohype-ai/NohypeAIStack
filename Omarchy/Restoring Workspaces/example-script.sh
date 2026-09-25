#!/usr/bin/env bash
# Example script to layout workspaces
# Something like this could be placed in ~/.local/bin/layout-work

hyprctl dispatch exec "[workspace 1 silent] flea $HOME/Projects"
hyprctl dispatch exec "[workspace 2 silent] ghostty --working-directory=$HOME/Projects"
hyprctl dispatch exec "[workspace 3 silent] zeditor $HOME/Projects"
hyprctl dispatch exec "[workspace 4 silent] brave-origin --new-window https://github.com"
hyprctl dispatch exec "[workspace 4 silent] brave-origin --new-window https://docs.hypr.land"
hyprctl dispatch exec "[workspace 5 silent] brave-origin --new-window https://mail.google.com"

# switches you to workspace 1
hyprctl dispatch workspace 1
