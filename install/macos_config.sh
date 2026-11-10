#!/usr/bin/env bash
# Applies my preferred macOS settings. Safe to re-run.
# Key repeat and trackpad changes need a log out / log in to take effect.
set -euo pipefail

echo "Applying macOS settings..."

# Trackpad: three-finger drag (built-in and Bluetooth trackpads)
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Keyboard: very fast key repeat
defaults write -g InitialKeyRepeat -int 10 # UI minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 1         # UI minimum is 2 (30 ms)

# Dock: no auto-hide animation delay
defaults write com.apple.dock autohide-time-modifier -int 0

# Restart affected apps last, once all settings are written.
killall Dock >/dev/null 2>&1 || true

echo "Done. Log out and back in for keyboard/trackpad changes."
