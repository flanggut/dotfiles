function fzf_hg_commit

  hg sl --color always 2>/dev/null > /tmp/fzf.tmp

  # Extract hg commit hashes and run fzf to select commit. Selecting a commit prints hash on commandline.
  # Additional keybindings:
  # CTRL-U: hg update for given commit and toggle preview to refresh
  # CTRL-G: hg graft for given commit and toggle preview to refresh
  hg sl 2>/dev/null | sed -e 's/^[\|\ \/]*//' | egrep '(^o|^\@)' | cut -c 4-11 | \
  fzf --ansi --no-sort --tiebreak=index --reverse --preview-window right:90% \
  --preview "grep --color=always -E '{}|\$' /tmp/fzf.tmp" \
  --bind "ctrl-u:execute(hg up {} > /dev/null && hg sl --color always 2>/dev/null > /tmp/fzf.tmp)+toggle-preview+toggle-preview" \
  --bind "ctrl-g:execute(hg graft {} > /dev/null && hg sl --color always 2>/dev/null > /tmp/fzf.tmp)+toggle-preview+toggle-preview" \
  | read -l result

  if test $result
    commandline -it -- $result
  end

end

