# Dotfiles

My macOS config. Each app has its own folder with a `links.prop` that says where its files get symlinked.

## Install

New machine (or re-run on an existing one):

```bash
curl -fsSL https://raw.githubusercontent.com/djm30/dotfiles/main/install/setup.sh | bash
```

`install/setup.sh` clones or updates `~/dotfiles`, installs Homebrew and the `Brewfile`, installs the zap zsh plugin manager, links everything, then asks whether to apply the macOS settings.

Options: `--no-brew`, `--macos` (apply macOS settings without asking), `--dry-run` (change nothing).

### Individual scripts

| Script | What it does |
| --- | --- |
| `install/setup.sh` | Runs everything below |
| `install/install.sh` | Installs Homebrew and `install/Brewfile` |
| `install/bootstrap.sh` | Creates the symlinks from every `links.prop` (`--dry-run`, `--overwrite`) |
| `install/macos_config.sh` | Key repeat, trackpad and Dock settings |

## links.prop

One link per line, `source=destination`. Only `$DOTFILES` and `$HOME` are expanded; `#` starts a comment.

```
$DOTFILES/zsh/zshrc=$HOME/.zshrc
```

If the destination already exists as a real file it is moved to `<name>.backup` (or deleted with `--overwrite`). Existing symlinks are replaced.

## What's tracked

| Folder | Links to |
| --- | --- |
| `zsh` | `~/.zshrc`, `~/.zprofile`, `~/.p10k.zsh` |
| `nvim`, `kitty`, `lf`, `amethyst`, `karabiner` | `~/.config/<name>` |
| `wezterm` | `~/.wezterm.lua`, `~/.config/wezterm/colors` |
| `git` | `~/.gitconfig`, `~/.gitignore_global` |
| `gh` | `~/.config/gh/config.yml` |
| `pi` | Pi agent settings, permissions, prompt, extension, skill in `~/.pi/agent` |
| `agents` | `~/.agents/skills` (shared agent skills) |
| `opencode` | `~/.config/opencode/opencode.json`, a skill |

## Not tracked (machine-local)

This repo is public. Secrets and work config live in untracked files:

- `~/.env.sh`: sourced by `.zshrc`; env vars, tokens, proxy certs
- `~/.gitconfig.local`: included by `.gitconfig`; email, CA path
- Pi `auth.json`, `mcp.json`, sessions; gh `hosts.yml`; opencode work agents/skills
