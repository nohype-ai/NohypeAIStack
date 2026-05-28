#!/usr/bin/env zsh
# MacStack (`mack update`) runs this script
# This script allows you to customize/extend the update process

# Prepare
set -e  # Exit on any error
set -u  # Treat unset variables as error
stack_folder=${0:a:h} # Get the absolute path of the stack folder

# Ensure new interactive shells start without "Last login" banner
touch ~/.hushlogin

# Update symlinks to dotfiles
"$stack_folder/symlinks to dotfiles/generate.sh"

# Update Grok Build
if command -v grok >/dev/null 2>&1; then
  echo "🌌 Updating Grok Build ..."
  silent grok update --alpha
else
  echo "🌌 Installing Grok Build ..."
  silent zsh -c 'GROK_CHANNEL=alpha curl -fsSL https://x.ai/cli/install.sh | bash'
fi

# Update Python
echo "🐍 Updating Python ..."
silent uv python install --default
silent uv python upgrade

# Update LiteLLM (pinned to Python 3.13 until orjson ships 3.14 wheels)
echo "🤖 Updating LiteLLM ..."
silent uv tool install --python 3.13 --upgrade 'litellm[proxy]'

# Update markitdown
echo "📝 Updating markitdown ..."
silent uv tool install --upgrade --force 'markitdown[pptx,docx,xlsx,xls,pdf,outlook]'

# Fix Cursor CLI Issue
# echo "🩹 Fixing Cursor CLI issue ..."
# xattr -rd com.apple.quarantine /opt/homebrew/Caskroom/cursor-cli
