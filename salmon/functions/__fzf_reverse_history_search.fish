function __fzf_reverse_history_search
  history | fzf -m --tiebreak=index --bind "ctrl-y:execute(printf {} | pbcopy)+abort" | while read i; set command "$command""$i"' ; and '; end
  set command (echo $command | rev | cut -c7- | rev)
  if test $command
    commandline -rb $command
  end
end

