function fzf_hg_commit

  hg sl --color always 2>/dev/null > /tmp/fzf.tmp

  hg sl 2>/dev/null | sed -e 's/^[\|\ \/]*//' | egrep '(^o|^\@)' | cut -c 4-11 | fzf --ansi --no-sort --tiebreak=index --reverse --preview-window right:90% --preview "grep --color=always -E '{}|\$' /tmp/fzf.tmp" --bind "ctrl-u:execute(hg up {})" | read -l result

  if test $result
    commandline -it -- $result
  end

end

