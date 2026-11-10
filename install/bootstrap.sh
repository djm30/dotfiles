#!/usr/bin/env bash
#
# Symlinks config files into place, driven by `links.prop` files.
#
# Each top-level folder may contain a links.prop with one link per line:
#
#   $DOTFILES/zsh/zshrc=$HOME/.zshrc
#
# Only $DOTFILES and $HOME are expanded. Blank lines and lines starting
# with # are ignored.
#
# Usage: bootstrap.sh [--dry-run] [--overwrite]
#   --dry-run    print what would happen, change nothing
#   --overwrite  delete conflicting files instead of backing them up
#
# Conflicts: an existing symlink is replaced. An existing real file or
# directory is moved to <path>.backup (or <path>.backup.<timestamp> if
# that already exists) unless --overwrite is given.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

dry_run=false
overwrite=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=true ;;
    --overwrite) overwrite=true ;;
    -h | --help)
      sed -n '3,19p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
  esac
done

info() { printf '  [ \033[00;34m..\033[0m ] %s\n' "$1"; }
success() { printf '  [ \033[00;32mOK\033[0m ] %s\n' "$1"; }
warn() { printf '  [\033[0;33mWARN\033[0m] %s\n' "$1"; }
error() { printf '  [\033[0;31mFAIL\033[0m] %s\n' "$1" >&2; }

# Run a command, or just print it in dry-run mode.
run() {
  if $dry_run; then
    printf '        would run: %s\n' "$*"
  else
    "$@"
  fi
}

failures=0

# Expand only $DOTFILES / $HOME (no eval) and drop any trailing slash.
expand_path() {
  local p=$1
  p=${p//\$DOTFILES/$DOTFILES}
  p=${p//\$HOME/$HOME}
  p=${p%/}
  printf '%s' "$p"
}

link_file() {
  local src=$1 dst=$2

  if [ ! -e "$src" ]; then
    error "source missing: $src"
    failures=$((failures + 1))
    return
  fi

  if [ -L "$dst" ]; then
    local current
    current="$(readlink "$dst")"
    if [ "${current%/}" = "$src" ]; then
      success "already linked $dst"
      return
    fi
    run rm "$dst"
    info "replaced old symlink $dst (was -> $current)"
  elif [ -e "$dst" ]; then
    if $overwrite; then
      run rm -rf "$dst"
      info "removed $dst"
    else
      local backup="$dst.backup"
      [ -e "$backup" ] && backup="$dst.backup.$(date +%Y%m%d%H%M%S)"
      run mv "$dst" "$backup"
      info "backed up $dst -> $backup"
    fi
  fi

  run mkdir -p "$(dirname "$dst")"
  run ln -s "$src" "$dst"
  success "linked $dst -> $src"
}

install_dotfiles() {
  info "linking dotfiles from $DOTFILES"
  $dry_run && warn "dry run: nothing will be changed"

  local linkfile line src dst
  while IFS= read -r -d '' linkfile; do
    while IFS= read -r line || [ -n "$line" ]; do
      # Skip blanks and comments.
      [[ -z "${line//[[:space:]]/}" || "$line" =~ ^[[:space:]]*# ]] && continue

      if [[ "$line" != *=* ]]; then
        error "bad line in $linkfile: $line"
        failures=$((failures + 1))
        continue
      fi

      src="$(expand_path "${line%%=*}")"
      dst="$(expand_path "${line#*=}")"
      link_file "$src" "$dst"
    done <"$linkfile"
  done < <(find "$DOTFILES" -mindepth 2 -maxdepth 2 -name links.prop -not -path "$DOTFILES/.git/*" -print0 | sort -z)
}

# ~/.env.sh holds machine-local, untracked settings (secrets, work config).
create_env_file() {
  local env_file="$HOME/.env.sh"
  if [ -e "$env_file" ]; then
    success "$env_file already exists, leaving it alone"
  else
    if ! $dry_run; then
      printf '%s\n' "# Machine-local shell settings. Not tracked in git; keep secrets here." >"$env_file"
    fi
    success "created $env_file"
  fi
}

install_dotfiles
create_env_file

echo
if [ "$failures" -gt 0 ]; then
  error "$failures problem(s) found, see above"
  exit 1
fi
success "All linked!"
