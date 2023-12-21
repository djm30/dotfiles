#!/bin/bash

# Install Homebrew if it's not already installed
if ! command -v brew >/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Updating Homebrew..."
brew update

# Homebrew taps
taps=(
    homebrew/cask-fonts
)

# Fonts to install
fonts=(
    font-meslo-lg-nerd-font
    font-jetbrains-mono-nerd-font
)

# Tools to install
tools=(
    fzf
    lf
    neovim
    lazygit
    ripgrep
    bat
)

# Applications to install with brew cask
applications=(
    1password
    ticktick
    obsidian
    arc
    scroll-reverser
    rectangle
    flux
    hiddenbar
    raycast
    selfcontrol
    visual-studio-code
    discord
    betterdisplay
    wezterm
)

# Add taps
for tap in "${taps[@]}"; do
    brew tap "$tap"
done

# Function to install a Homebrew package if not already installed
install_brew_package() {
    local package=$1
    if brew list "$package" &>/dev/null; then
        echo "$package is already installed."
    else
        brew install "$package"
    fi
}

# Function to install a Homebrew Cask package if not already installed
install_brew_cask_package() {
    local package=$1
    local app_name=$(echo "$package" | sed -e 's/font-//' -e 's/-/ /g')

    if brew list --cask "$package" &>/dev/null || [ -d "/Applications/$app_name.app" ]; then
        echo "$package is already installed."
    else
        brew install --cask "$package"
    fi
}

# Install fonts
for font in "${fonts[@]}"; do
    install_brew_cask_package "$font"
done

# Install tools
for tool in "${tools[@]}"; do
    install_brew_package "$tool"
done

# Install applications
for app in "${applications[@]}"; do
    install_brew_cask_package "$app"
done

echo "Installation complete!"

