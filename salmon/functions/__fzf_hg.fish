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
    #
    set FZF_HG "hg sl --color always 2>/dev/null > ~/.cache/fzf_hg_smartlog && cat ~/.cache/fzf_hg_smartlog | sed -e 's/^[\|\/\ ╷│├╯╭─╯]*//' | sed -e 's/[0-9]*:[0-9]*//' | sed -e 's/at\ *//' | sed -e 's/D[0-9]\{7,\}//' | grep -E -A 1 '(^(o|\@)\ )' | sed '/^--/d' | paste - - | cut -c 4- | sed -e 's/flanggut//' | sed -e 's/[[:blank:]]\{1,\}/ /g' >~/.cache/fzf_hg_list"
    eval $FZF_HG
    FZF_DEFAULT_COMMAND="cat ~/.cache/fzf_hg_list" fzf \
        --ansi --no-sort --reverse --preview-window right:60% \
        --preview "rg -N --passthru --color=always --colors 'match:bg:white' (echo {} | cut -c -9) ~/.cache/fzf_hg_smartlog" \
        --bind "enter:execute(hg up (echo {} | cut -c -9) && hg fsl --color always 2>/dev/null)+abort" \
        --bind "ctrl-e:execute-silent(hg hide (echo {} | cut -c -9))+become(__fzf_hg)" \
        --bind "ctrl-u:execute(hg up (echo {} | cut -c -9))+become(__fzf_hg)" \
        --bind "ctrl-g:execute(hg graft (echo {} | cut -c -9))+become(__fzf_hg)" \
        --bind "ctrl-h:execute(hg rebase -s (echo {} | cut -c -9) -d .)+become(__fzf_hg)" \
        --bind "ctrl-p:execute(hg rebase -s (echo {} | cut -c -9) -d (cat ~/.cache/hg_hash))+become(__fzf_hg)" \
        --bind "ctrl-r:execute(hg rebase -s (echo {} | cut -c -9) -d stable)+become(__fzf_hg)" \
        --bind "ctrl-s:execute(hg show --color always (echo {} | cut -c -9) | less -R)" \
        --bind "ctrl-n:execute(jf s -n -r (echo {} | cut -c -9))+execute(hg show --stat (echo {} | cut -c -9))+abort" \
        --bind "ctrl-t:execute(hg rebase -s (cat ~/.cache/hg_hash) -d (echo {} | cut -c -9))+become(__fzf_hg)" \
        --bind "ctrl-o:execute(hg show --stat (echo {} | cut -c -9) | grep https | sed 's/.*https/https/' | xargs open)+clear-query" \
        --bind "ctrl-y:execute-silent(printf (echo {} | cut -c -9) | tee ~/.cache/hg_hash)+clear-query"

    # Reprint the command line
    # commandline ""

end
#--bind "ctrl-h:execute(hg rebase -s (echo {} | cut -c -9) -d .  && eval $FZF_HG)+reload($FZF_DEFAULT_COMMAND)+refresh-preview+clear-query" \
# --bind "ctrl-u:execute(hg up (echo {} | cut -c -9) && eval $FZF_HG)+reload($FZF_DEFAULT_COMMAND)+refresh-preview+clear-query" \
