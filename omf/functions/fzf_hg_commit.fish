function fzf_hg_commit
  # hg sl --color always 2>/dev/null | fzf --ansi --no-sort --tiebreak=index --reverse --preview-window down:30 --preview "echo {} | sed -e 's/^[\|o\ \/\@]*//' | cut -c 1-6 | xargs hg show --stat --color always" | egrep -o '\ \w{6}\ ' | read -l result
  hg sl 2>/dev/null | egrep -v '\|$' | paste -s -d' \n' - - | sed -e 's/^[\|o\ \/\@x]*//' | cut -c 1-6 | fzf --ansi --no-sort --tiebreak=index --reverse --preview-window right:90% --preview "hg sl --color always 2>/dev/null | grep --color=always -E '{}|\$' && hg show --color always --stat {}" | read -l result
  if test $result
    commandline -it -- $result
  end
end

