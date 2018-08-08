function fzf_hg_commit

  # Create smartlog cache
  set -l SLCACHE /tmp/fzf_hg_smartlog_cache.tmp
  hg sl --color always 2>/dev/null > $SLCACHE

  # Extract hg commit hashes and run fzf to select commit. Selecting a commit prints hash on commandline.
  # Keybindings:
  # ENTER : hg update to given commit and exit
  # CTRL-U: hg update to given commit and toggle preview to refresh
  # CTRL-G: hg graft given commit and toggle preview to refresh
  # CTRL-S: hg show commit
  # CTRL-Y: copy commit id to clipboard and exit
  hg sl 2>/dev/null | sed -e 's/^[\|\ \/]*//' | egrep '(^o|^\@)' | cut -c 4-11 | \
  fzf -e --ansi --no-sort --tiebreak=index --reverse --preview-window right:90% \
  --preview "grep --color=always -E '{}|\$' $SLCACHE" \
  --bind "enter:execute-silent(hg up {})+abort" \
  --bind "ctrl-u:execute-silent(hg up {} && hg sl --color always 2>/dev/null > $SLCACHE)+toggle-preview+toggle-preview" \
  --bind "ctrl-g:execute(hg graft {} && hg sl --color always 2>/dev/null > $SLCACHE)+toggle-preview+toggle-preview" \
  --bind "ctrl-s:execute(hg show --color always {} | less -R)" \
  --bind "ctrl-y:execute(printf {} | pbcopy)+abort"

end

