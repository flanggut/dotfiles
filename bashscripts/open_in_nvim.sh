#!/bin/bash

function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }
url=$(urldecode "$1")
filepath=$(sed 's,.*path=,'"$HOME"'/fbsource/,' <<< "$url")
filepath=$(urldecode "$filepath")
line=$(sed 's,.*&line=,,' <<< "$filepath")
filepath=$(sed 's,&line=.*,,' <<< "$filepath")

socket="/tmp/nvimsocket"

/Users/flanggut/homebrew/bin/nvim --server "$socket" --remote-send ':e +'"$line"' '"$filepath"'<CR>'
