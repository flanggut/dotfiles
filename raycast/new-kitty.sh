#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title New kitty
# @raycast.mode compact
# @raycast.packageName Terminal

# Optional parameters:
# @raycast.icon images/kitty.png
#
# Documentation:
# @raycast.description Open new kitty window

kitty --single-instance
