#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title New kitty
# @raycast.mode silent
# @raycast.packageName Terminal

# Optional parameters:
# @raycast.icon images/kitty.png
#
# Documentation:
# @raycast.description Open new kitty window

pushd ~

#/Users/flanggut/homebrew/bin/kitty --single-instance sh -c "/Users/flanggut/homebrew/bin/fish"
/Users/flanggut/homebrew/bin/kitty --single-instance &

popd
