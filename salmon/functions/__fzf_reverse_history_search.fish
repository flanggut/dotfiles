function __fzf_reverse_history_search
    history -z | fzf --read0 --print0 -m --tiebreak=index --bind "ctrl-y:execute(printf {} | pbcopy)+abort" | while read -lz i
        set command "$command""$i"' ; and '
    end
    set command (echo $command | tr '\n' ' ' | sed -e 's/.;.and..$//g')
    commandline -- $command
    commandline -f repaint
end
