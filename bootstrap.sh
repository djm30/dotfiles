#!/bin/bash

# Dotfiles repository URL
DOTFILES_REPO="https://github.com/djm30/dotfiles.git"

# Dotfiles directory path
DOTFILES_DIR="$HOME/.dotfiles"

# Clone the dotfiles repository
clone_dotfiles() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        echo "Cloning dotfiles..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    else
        echo "Dotfiles directory already exists."
    fi
}

# Execute a script if it exists
execute_script() {
    local script=$1
    if [ -f "$script" ]; then
        echo "Running script: $script"
        bash "$script"
    else
        echo "Script not found: $script"
    fi
}

# Main execution function
main() {
    clone_dotfiles

    # Execute scripts from the scripts directory
    # execute_script "$DOTFILES_DIR/setup/symlinks.sh"
    # execute_script "$DOTFILES_DIR/setup/install.sh"
    execute_script "$DOTFILES_DIR/setup/zsh.sh"
    execute_script "$DOTFILES_DIR/setup/macos_config.sh"
    # Add more scripts as needed
}

main

