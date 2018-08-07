function fzf_hg_commit

  # Create smartlog cache
  set -l SLCACHE /tmp/fzf.tmp
  hg sl --color always 2>/dev/null > $SLCACHE

  # Extract hg commit hashes and run fzf to select commit. Selecting a commit prints hash on commandline.
  # Keybindings:
  # ENTER : hg update to given commit and exit
  # CTRL-U: hg update to given commit and toggle preview to refresh
  # CTRL-G: hg graft given commit and toggle preview to refresh
  # CTRL-P: print hg hash to command line
  hg sl 2>/dev/null | sed -e 's/^[\|\ \/]*//' | egrep '(^o|^\@)' | cut -c 4-11 | \
  fzf --ansi --no-sort --tiebreak=index --reverse --preview-window right:90% \
  --preview "grep --color=always -E '{}|\$' $SLCACHE" \
  --bind "enter:execute-silent(hg up {})+abort" \
  --bind "ctrl-u:execute-silent(hg up {} && hg sl --color always 2>/dev/null > $SLCACHE)+toggle-preview+toggle-preview" \
  --bind "ctrl-g:execute-silent(hg graft {} && hg sl --color always 2>/dev/null > $SLCACHE)+toggle-preview+toggle-preview" \
  --bind "ctrl-p:accept" \
  | read -l result

  if test $result
    commandline -it -- $result
  end

end

