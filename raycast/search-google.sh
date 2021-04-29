#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Google
# @raycast.mode silent
# @raycast.packageName Custom Search
#
# Optional parameters:
# @raycast.icon images/google.png
# @raycast.argument1 { "type": "text", "placeholder": "query", "percentEncoded": true}
#
# Documentation:
# @raycast.description Simple Google Search

open "https://www.google.com/search?q=$1"
