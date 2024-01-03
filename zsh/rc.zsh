source_if_exists () {
    if test -r "$1"; then
        source "$1"
    fi
}

# Source the environment-specific configurations
source_if_exists $HOME/.env.sh

source_if_exists "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# Oh-My-Zsh
export ZSH="$HOME/.oh-my-zsh"
source_if_exists $ZSH/oh-my-zsh.sh

source_if_exists $DOTFILES/zsh/aliases.zsh
source_if_exists $DOTFILES/zsh/commands.zsh

source_if_exists ~/.fzf.zsh
source_if_exists /opt/homebrew/etc/profile.d/z.sh

source_if_exists ~/.p10k.zsh

export PATH="$PATH:/usr/local/sbin:$DOTFILES/bin:$HOME/.local/bin"
export VISUAL=nvim
export EDITOR=nvim
export TERM=wezterm

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme
ZSH_THEME="powerlevel10k/powerlevel10k"
# plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
