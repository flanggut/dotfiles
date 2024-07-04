function __history() {
  (( ! $+commands[awk] )) && echo "awk not installed. Exiting..." && return
  fc -ln -1 0 | awk '!seen[$0]++'
}

function __fzf_reverse_history_search() {
  (( ! $+commands[fzf] )) && echo "FZF not installed. Exiting..."  && return

  local fzf_args='-m --tiebreak=index --bind "ctrl-y:execute(printf {} | pbcopy)+abort"'

  candidates=(${(f)"$(__history | fzf ${(Q)${(z)fzf_args}})"})

  BUFFER="${(j| && |)candidates}"

  zle vi-fetch-history -n $BUFFER
  zle end-of-line
  zle reset-prompt
}

autoload __fzf_reverse_history_search
zle -N __fzf_reverse_history_search
bindkey "^k" __fzf_reverse_history_search
