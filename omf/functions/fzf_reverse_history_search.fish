function fzf_reverse_history_search
  history merge
  history | fzf --reverse --no-sort | read -l command
  if test $command
    commandline -rb $command
  end
end

