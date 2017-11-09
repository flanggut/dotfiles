# Exports
#----------------------------------------------------------
export PLATFORM=$(uname -s)
export PATH=~/bin:/usr/local/bin:/usr/local/sbin:/Library/TeX/texbin:$PATH
export EDITOR=vim
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

[ "$PLATFORM" = 'Darwin' ] ||
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.:/usr/local/lib

# set terminal prompt
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    export PS1="\[\033[32m\]\u@\h: \[\033[34m\]\w $\[\033[0m\] "
else
    export PS1="\[\033[32m\]\u: \[\033[34m\]\w $\[\033[0m\] "
fi

# Fix bash history
HISTCONTROL=ignoreboth:erasedups
HISTFILESIZE=1000000
HISTSIZE=1000000
HISTTIMEFORMAT='%F %T '
shopt -s cmdhist
PROMPT_COMMAND='history -a'

# Aliases
#----------------------------------------------------------
alias ll="ls -lhG"
alias la="ls -lahG"
alias ls="ls -G"

alias sift="sift --binary-skip -n"

if [ "$PLATFORM" = 'Darwin' ]; then
  alias vim='mvim'
  alias vi='vim'
fi

# Custom Commands
#----------------------------------------------------------
if [ "$PLATFORM" = 'Darwin' ]; then
  f() { #open in finder
    open --reveal "${1:-.}"
  }
fi


# FZF Commands
#----------------------------------------------------------
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export FZF_DEFAULT_OPTS='--height 60%'
export FZF_ALT_C_COMMAND="command find -L . -mindepth 1 -maxdepth 2 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune -o -type d -print 2> /dev/null | cut -b3-"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
# cdd - cd to selected directory
cdd() {
  local dir
  dir=$(find ${1:-*} -path '*/\.*' -prune \
                  -o -type d -maxdepth 1 -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}
# cda - including hidden directories
cda() {
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
}

# cdf - cd into the directory of the selected file
cdf() {
   local file
   local dir
   file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir"
}

