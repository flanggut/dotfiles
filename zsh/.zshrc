######     Helpers      ######

function is-macos() {
  [[ $OSTYPE == darwin* ]]
}

is_inside_git_repo() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1
}


##############################     Main      #################################
######     Path      ######
path+=("${XDG_CACHE_HOME:-$HOME}/bin")
path+=("${XDG_CACHE_HOME:-$HOME}/homebrew/bin")
path+=("${XDG_CACHE_HOME:-$HOME}/Library/Python/3.10/bin")
export PATH

fpath=( ~/.zsh_func "${fpath[@]}" )

export EDITOR=NVIM

######     Helpers / Completion      ######
is_git() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

just-fzf-and-run() {
    a=$(just --list --unsorted --list-heading '' | fzf | awk '{print $1}')
    if [[ ! -z $a ]]; then just $a; fi
}

_just_completion() {
    local options
    options="$(just --summary)"
    if [ $? -eq 0 ]; then
        reply=(${(s: :)options})  # turn into array and write to return variable
    fi
}

compctl -K _just_completion just

######     Alias      ######
alias ad="~/.antidote/antidote"
alias ..="cd .."
alias ...="cd ../.."
alias j="z"
alias ji="zi"
alias jl=just-fzf-and-run
alias vim=nvim
alias ls="ls --color"
alias la="ls --color -la"

#     Git + HG commands    #
alias shows="hg show --stat"
alias sshow="hg st -m"
alias histe="hg histedit"
alias hi="__fzf_hg"
alias hgn="hg next"
alias hgp="hg prev"
alias jfs="jf s"
alias jfa="jf a"
alias jfs2="jf s -r .^..."
alias jfs3="jf s -r .^^..."
alias jfs4="jf s -r .^^^..."
alias jfs5="jf s -r .^^^^..."
alias qd="adb devices && maui q d"

sml() {
   if is_git; then git sl; else hg fsl; fi
}

dff() {
  if is_git; then git diff | delta | less -r; else hg diff | delta | less -r; fi
}

show() {
  if is_git; then git show | delta | less -r; else hg diff -r .^ | delta | less -r; fi
}

st() {
  if is_git; then git st; else hg st; fi
}


######   Completion    ######
# Fuzzy Matching
# 0 -- vanilla completion (abc => abc)
# 1 -- smart case completion (abc => Abc)
# 2 -- word flex completion (abc => A-big-Car)
# 3 -- full flex completion (abc => ABraCadabra)
zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'
# Completion colors
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Completion init
autoload -U compinit && compinit

# fzf
source <(fzf --zsh)

################     Plugins      ##############
# Antidote
# Bootstrap
if [[ ! -d ${ZDOTDIR:-$HOME}/.antidote  ]]; then
  git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote
  chmod u+x ${ZDOTDIR:-~}/.antidote/antidote
fi


zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  (
    echo "Re-generating antidote bundle..."
    source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh
    antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
  )
fi
source ${zsh_plugins}.zsh

# Zoxide
eval "$(zoxide init zsh)"

# Pure
# adjustments:
#   if [[ $OSTYPE == darwin* ]]; then
#     preprompt_parts+=('%f')
#   fi
#   preprompt_parts+=('%F{${prompt_pure_colors[path]}} %~%f')
autoload -U promptinit; promptinit
prompt pure

######     Opts      ######
# Highlight styles
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[alias]='bold'
ZSH_HIGHLIGHT_STYLES[global-alias]='bold'
ZSH_HIGHLIGHT_STYLES[function]='bold'
ZSH_HIGHLIGHT_STYLES[command]='bold'
ZSH_HIGHLIGHT_STYLES[hashed-command]='bold'

### Colors
export FZF_DEFAULT_OPTS="
	--color=fg:#797593,bg:#faf4ed,hl:#d7827e
	--color=fg+:#575279,bg+:#f2e9e1,hl+:#d7827e
	--color=border:#dfdad9,header:#286983,gutter:#faf4ed
	--color=spinner:#ea9d34,info:#56949f,separator:#dfdad9
	--color=pointer:#907aa9,marker:#b4637a,prompt:#797593"

LS_COLORS='di=0;34:ln=0;36:ex=0;91'
export LS_COLORS

### History
HISTSIZE=10000000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
# To save every command before it is executed
setopt inc_append_history
# To read and update history on every command
# setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_find_no_dups

if [[ -f ${ZDOTDIR:-$HOME}/.profile  ]]; then
  source ${ZDOTDIR:-$HOME}/.profile
fi
