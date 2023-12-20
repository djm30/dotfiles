# setup mac os setting
#
# like hide dock
# key repeat
# accessiblity settings like 3 finger drag maybe if possible


# Trackpad 3 Finger Drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# Remove dock animation
defaults write com.apple.dock autohide-time-modifier -int 0
killall Dock

# Change key repeat settings
defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)

