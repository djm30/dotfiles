#!/bin/bash

# Repository URL
REPO_URL="https://github.com/djm30/dotfiles.git"


# Clone the repository into the home directory
git clone "$REPO_URL" "$HOME/dotfiles"

# Change into the 'install' directory within the cloned repository
cd "$HOME_DIR/dotfiles/install"


chmod +x ./bootstrap.sh
chmod +x ./install.sh
chmod +x ./macos_config.sh

# Run the bootstrap.sh script
./bootstrap.sh

