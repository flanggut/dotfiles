function __fzf_hg

  # Extract hg commit hashes and run fzf to select commit. Selecting a commit prints hash on commandline.
  # Keybindings:
  # ENTER : hg update to given commit and exit
  # CTRL-U: hg update to given commit and toggle preview to refresh
  # CTRL-G: hg graft given commit and toggle preview to refresh
  # CTRL-R: hg rebase -s commit -d master
  # CTRL-H: hg rebase -s commit -d .
  # CTRL-S: hg show commit
  # CTRL-Y: copy commit id to clipboard and exit
  hg sl --color always 2>/dev/null > ~/.cache/fzf_hg_smartlog

  # Old version: only search of commit hash
  # hg sl 2>/dev/null | sed -e 's/^[\|\ \/]*//' | egrep '(^o|^\@)' | cut -c 4-11 | \
  # fzf -e --ansi --no-sort --tiebreak=index --reverse --preview-window right:80% \
  # --preview "grep --color=always -E '{}|\$' ~/.cache/fzf_hg_smartlog" \

  # New version: also search for commit message
  hg sl --color always 2>/dev/null | sed -e 's/^[\|\/\ ╷│├╯╭─╯]*//' | egrep -A 1 '(^(o|\@))' | sed '/^--$/d' | paste - - | cut -c 4- | \
  fzf --ansi --no-sort --reverse --preview-window right:80% \
  --preview 'rg -N --passthru --color=always (echo {} | cut -c -9) ~/.cache/fzf_hg_smartlog' \
  --bind 'enter:execute(hg up (echo {} | cut -c -9) && hg fsl --color always 2>/dev/null)+abort' \
  --bind 'ctrl-u:execute(hg up (echo {} | cut -c -9) && hg sl --color always 2>/dev/null > ~/.cache/fzf_hg_smartlog)+toggle-preview+toggle-preview' \
  --bind 'ctrl-g:execute(hg graft (echo {} | cut -c -9) && hg sl --color always 2>/dev/null > ~/.cache/fzf_hg_smartlog)+toggle-preview+toggle-preview' \
  --bind 'ctrl-r:execute(hg rebase -s (echo {} | cut -c -9) -d master )+abort' \
  --bind 'ctrl-h:execute(hg rebase -s (echo {} | cut -c -9) -d . )+abort' \
  --bind 'ctrl-s:execute(hg show --color always (echo {} | cut -c -9) | less -R)' \
  --bind 'ctrl-y:execute(printf (echo {} | cut -c -9) | pbcopy)+abort'

  # Reprint the command line
  commandline ""

end

