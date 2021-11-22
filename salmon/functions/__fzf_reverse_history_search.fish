function __fzf_reverse_history_search
  history -z | fzf --read0 --print0 -m --tiebreak=index --bind "ctrl-y:execute(printf {} | pbcopy)+abort" | read -lz result
  and commandline -- $result
  commandline -f repaint
end

