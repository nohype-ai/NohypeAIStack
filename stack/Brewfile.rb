# 🍺 All available Homebrew packages can be searched here: https://formulae.brew.sh
# 🍏 Mac App Store apps (and their IDs) can be searched via `mas search <search-term>`
# 🚨 Prefer casks (🍺) over MAS apps (🍏) because cask installs work more reliably!

# system management
tap "nohype-ai/tap"
brew "nohype-ai/tap/macstack"
cask "applite" # GUI app Homebrew wrapper
cask "omnidisksweeper" # simple free disk usage inspection (give it full disk access in System Settings > Privacy & Security)
cask "stats" # system health monitor, including chip temperature

# communication, browser
cask "WhatsApp"
mas "AdGuard Mini: Safari Adblock", id: 1440147259 # block ads in Safari, YT, YT-Music
mas "Noir – Dark Mode for Safari", id: 1592917505 # force dark mode on websites in Safari

# writing, diagramming, office
cask "obsidian" # "process as documentation" + "canvas as code" ...
cask "typora"
cask "texifier" # LaTeX editor
mas "Pages: Create Documents", id: 361309726
mas "Numbers: Make Spreadsheets", id: 361304891
mas "Keynote: Design Presentations", id: 361285480
cask "omnigraffle"
cask "inkscape" # vector graphics app and cli (also for eps to svg conversion)

# basic productivity tools
cask "raycast"                 # THE macOS swiss army knife for productivity
cask "cold-turkey-blocker"     # strict distraction blocker, getcoldturkey.com
cask "focus"                   # limit distractions, heyfocus.com

# basic developer tools
brew "zsh"                     # but use this script shebang: #!/usr/bin/env zssh
brew "coreutils"               # basic terminal utilities
cask "ghostty"                 # modern native macOS terminal app
brew "git"                     # just so it gets updated frequently
brew "transcrypt"              # encryt parts of git repos
cask "fork"                    # graphical git client
cask "font-fira-code"          # monospaced font with coding ligatures

# (Coding-) Agents and Lean IDEs
cask "grok-build"  # https://x.ai/cli
cask "zed"         # https://zed.dev, lean and fast IDE

# Apple development
brew "xcodes"
cask "xcodes-app"
cask "sf-symbols" # https://developer.apple.com/sf-symbols
#mas "TestFlight", id: 899247664 # mas install fails: would require sudo since it copies the receipt file in a second step
mas "Developer", id: 640199958
mas "Icon Generator", id: 1631880470 # for scaling macOS app icons

# Apple fonts: https://developer.apple.com/fonts
cask "font-sf-pro"
cask "font-sf-compact"
cask "font-sf-mono"
cask "font-new-york"

# Python
brew "uv"      # THE python eco system manager, https://github.com/astral-sh/uv
brew "rust"    # needed to compile some Python package dependencies

# Screen recording (for demos and lectures) and media
mas "Hand Mirror", id: 1502839586 # video overlay in lecture recordings
cask "keycastr" # key strokes overlay in lecture recordings
cask "obs" # screen recording that can capture system audio
cask "handbrake-app" # video transcoder for compressing screen recordings
cask "adapter" # converting video, audio and images

# CLI tools for working with content file formats (for scripts/agents)
brew "imagemagick" # working with images (scale, crop, convert format ...)
brew "ghostscript" # pdf support for imagemagick (which does not install gs)
brew "pandoc" # universal document converter (markdown, HTML, LaTeX, docx, PDF ...)
brew "weasyprint" # specialized HTML/CSS to PDF converter, preserves styling
brew "ffmpeg" # industry-standard CLI video/audio converter/compressor/processor
brew "woff2" # font conversion (e.g. .otf/.ttf -> .woff2)
brew "asciidoctor" # converts .adoc files (AsciiDoc) into other formats

# ⚠️ Required dependencies for Brewfile (do not remove)
brew "mas" # for declaring mac app store apps
