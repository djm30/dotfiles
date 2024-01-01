source_if_exists () {
    if test -r "$1"; then
        source "$1"
    fi
}

# Source the environment-specific configurations
source_if_exists $HOME/.env.sh

# Powerlevel10k instant prompt initialization
source_if_exists "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# Oh-My-Zsh and theme
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source_if_exists $ZSH/oh-my-zsh.sh

# Custom configurations from DOTFILES
source_if_exists $DOTFILES/zsh/aliases.zsh

# Additional configurations
source_if_exists ~/.fzf.zsh
source_if_exists /opt/homebrew/etc/profile.d/z.sh

# Powerlevel10k configuration
source_if_exists ~/.p10k.zsh

# Conditional sourcing based on environment variables
if [ -n "$ZSH_HIGHLIGHT_DIR" ]; then
    source_if_exists $ZSH_HIGHLIGHT_DIR/zsh-syntax-highlighting.zsh
fi

# Environment-specific PATH configurations
export PATH="$PATH:/usr/local/sbin:$DOTFILES/bin:$HOME/.local/bin:$DOTFILES/scripts/"
export VISUAL=nvim
export EDITOR=nvim
export TERM=wezterm

