#!/usr/bin/env bash
#
# One-stop setup for a new (or existing) Mac:
#   1. clone ~/dotfiles, or fast-forward it if it already exists
#   2. install Homebrew + install/Brewfile
#   3. install the zap zsh plugin manager
#   4. symlink configs (bootstrap.sh)
#   5. optionally apply macOS settings
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/djm30/dotfiles/main/install/setup.sh | bash
#   ~/dotfiles/install/setup.sh [--no-brew] [--macos] [--dry-run]
#
#   --no-brew   skip Homebrew/Brewfile
#   --macos     apply macOS settings without asking
#   --dry-run   change nothing; show what would be linked

set -euo pipefail

REPO_URL="https://github.com/djm30/dotfiles.git"
DOTFILES="${DOTFILES:-$HOME/dotfiles}"

brew=true
macos=ask
dry_run=false
for arg in "$@"; do
  case "$arg" in
    --no-brew) brew=false ;;
    --macos) macos=yes ;;
    --dry-run) dry_run=true brew=false macos=no ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
  esac
done

step() { printf '\n\033[1;34m==>\033[0m %s\n' "$1"; }

step "Dotfiles repo"
if [ -d "$DOTFILES/.git" ] && $dry_run; then
  echo "would pull $DOTFILES"
elif [ -d "$DOTFILES/.git" ]; then
  git -C "$DOTFILES" pull --ff-only ||
    echo "Could not fast-forward $DOTFILES (local changes?); using it as-is."
else
  git clone "$REPO_URL" "$DOTFILES"
fi

if $brew; then
  step "Homebrew packages"
  "$DOTFILES/install/install.sh"
fi

step "zap (zsh plugin manager)"
if [ -r "$HOME/.local/share/zap/zap.zsh" ]; then
  echo "already installed"
elif $dry_run; then
  echo "would install zap"
else
  # --keep: don't let the zap installer edit ~/.zshrc
  zsh <(curl -fsSL https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1 --keep
fi

step "Symlinks"
if $dry_run; then
  "$DOTFILES/install/bootstrap.sh" --dry-run
else
  "$DOTFILES/install/bootstrap.sh"
fi

if [ "$macos" = ask ]; then
  # stdin may be the curl pipe, so ask on the terminal directly.
  if [ -r /dev/tty ]; then
    printf '\nApply macOS settings (key repeat, trackpad, Dock)? [y/N] '
    read -r answer </dev/tty || answer=n
    [[ "$answer" =~ ^[Yy] ]] && macos=yes || macos=no
  else
    macos=no
  fi
fi
if [ "$macos" = yes ]; then
  step "macOS settings"
  "$DOTFILES/install/macos_config.sh"
fi

step "Done. Open a new terminal to pick up the shell config."
