# Login-shell setup: put Homebrew on PATH and export HOMEBREW_PREFIX.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Obsidian CLI
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
