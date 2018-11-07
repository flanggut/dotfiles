function __fzf_hg

  # Create smartlog cache
  set -l SLCACHE /tmp/fzf_hg_smartlog_cache.tmp

  # Extract hg commit hashes and run fzf to select commit. Selecting a commit prints hash on commandline.
  # Keybindings:
  # ENTER : hg update to given commit and exit
  # CTRL-U: hg update to given commit and toggle preview to refresh
  # CTRL-G: hg graft given commit and toggle preview to refresh
  # CTRL-R: hg rebase -s commit -d master
  # CTRL-S: hg show commit
  # CTRL-Y: copy commit id to clipboard and exit
  hg sl --color always 2>/dev/null > $SLCACHE
  hg sl 2>/dev/null | sed -e 's/^[\|\ \/]*//' | egrep '(^o|^\@)' | cut -c 4-11 | \
  fzf -e --ansi --no-sort --tiebreak=index --reverse --preview-window right:90% \
  --preview "grep --color=always -E '{}|\$' $SLCACHE" \
  --bind "enter:execute(hg up {} && hg fsl --color always 2>/dev/null)+abort" \
  --bind "ctrl-u:execute(hg up {} && hg sl --color always 2>/dev/null > $SLCACHE)+toggle-preview+toggle-preview" \
  --bind "ctrl-g:execute(hg graft {} && hg sl --color always 2>/dev/null > $SLCACHE)+toggle-preview+toggle-preview" \
  --bind "ctrl-r:execute(hg rebase -s {} -d master)+abort" \
  --bind "ctrl-s:execute(hg show --color always {} | less -R)" \
  --bind "ctrl-y:execute(printf {} | pbcopy)+abort"

  # Reprint the command line
  commandline ""

end

