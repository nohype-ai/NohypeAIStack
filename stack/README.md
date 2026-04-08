# The Stack

This folder defines the stack. It includes code (like scripts and JSON) as well as "infrastructure as documentation".

## Inputs

Many files here are direct inputs to the MacStack update process (`mack update` or `update`). All of them are optional. What is not defined in the stack is preserved on the targeted Mac. The complete list of supported inputs is documented in the [MacStack repo](https://github.com/nohype-ai/MacStack).

| Input | Description |
|------|-------------|
| [macstack.json](macstack.json) | Basic configuration options, including personal git configuration |
| [bin/](bin/) | `mack update` makes the contained scripts and binaries available globally on the Mac |
| [zshrc.sh](zshrc.sh) | `mack update` makes this sourced from `~./zshrc` |
| [Brewfile](Brewfile) | `mack update` updates/installs listed packages |
| [update.sh](update.sh) | `mack update` executes it |
| [git/repos-folder-template/](git/repos-folder-template/) | A template for the content of the `git.repos_folder` defined in [macstack.json](macstack.json). Each folder in the template may contain a `git-repos.txt` listing URLs of intended repos in that folder. `mack update` will attempt to clone/sync your repos based on the template, and then report which repos need manual attention. |
| [zed/](zed/) and [vscode/](vscode/) | `mack update` merges the contained json files into the current settings |
| [ai/coding/cursor/](ai/coding/cursor/) | `mack update` merges these Cursor CLI settings and rules into `~/.cursor/`. |
| [ai/coding/gemini/](ai/coding/gemini/) | `mack update` merges Gemini CLI settings file `settings.json` and `policies/` into `~/.gemini/` |
| [ai/coding/opencode/](ai/coding/opencode/) | `mack update` merges OpenCode settings file `opencode.json` into `~/.config/opencode/` |
