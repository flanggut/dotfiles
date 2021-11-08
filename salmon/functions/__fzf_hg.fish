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

  # New version: also search for commit message
  FZF_DEFAULT_COMMAND="hg sl --color always 2>/dev/null > ~/.cache/fzf_hg_smartlog && cat ~/.cache/fzf_hg_smartlog | sed -e 's/^[\|\/\ ╷│├╯╭─╯]*//' | sed -e 's/[0-9]*:[0-9]*//' | sed -e 's/at\ *//' | sed -e 's/D[0-9]*//' | egrep -A 1 '(^(o|\@)\ )' | sed '/^--/d' | paste - - | cut -c 4- | sed -e 's/\ flanggut//'" fzf \
  --ansi --no-sort --reverse --preview-window right:60% \
  --preview "rg -N --passthru --color=always (echo {} | cut -c -9) ~/.cache/fzf_hg_smartlog" \
  --bind "enter:execute(hg up (echo {} | cut -c -9) && hg fsl --color always 2>/dev/null)+abort" \
  --bind "ctrl-e:execute-silent(hg hide (echo {} | cut -c -9))+reload($FZF_DEFAULT_COMMAND)+refresh-preview+clear-query" \
  --bind "ctrl-u:execute(hg up (echo {} | cut -c -9))+reload($FZF_DEFAULT_COMMAND)+refresh-preview+clear-query" \
  --bind "ctrl-g:execute(hg graft (echo {} | cut -c -9))+reload($FZF_DEFAULT_COMMAND)+refresh-preview+clear-query" \
  --bind "ctrl-h:execute(hg rebase -s (echo {} | cut -c -9) -d . )+reload($FZF_DEFAULT_COMMAND)+refresh-preview+clear-query" \
  --bind "ctrl-p:execute(hg pull)+reload($FZF_DEFAULT_COMMAND)+refresh-preview" \
  --bind "ctrl-r:execute(hg rebase -s (echo {} | cut -c -9) -d . )+reload($FZF_DEFAULT_COMMAND)+refresh-preview+clear-query" \
  --bind "ctrl-s:execute(hg show --color always (echo {} | cut -c -9) | less -R)" \
  --bind "ctrl-t:execute(hg rebase -s (pbpaste) -d (echo {} | cut -c -9))+reload($FZF_DEFAULT_COMMAND)+refresh-preview+clear-query" \
  --bind "ctrl-y:execute-silent(printf (echo {} | cut -c -9) | pbcopy)"

  # Reprint the command line
  commandline ""

end

