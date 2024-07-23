# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

######     Path      ######
path+=("${XDG_CACHE_HOME:-$HOME}/bin")
path+=("${XDG_CACHE_HOME:-$HOME}/homebrew/bin")
export PATH

fpath=( ~/.zsh_func "${fpath[@]}" )

######     Helpers      ######

function is-macos() {
  [[ $OSTYPE == darwin* ]]
}

is_inside_git_repo() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

######     Alias      ######
# helpers
is_git() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

alias ad="antidote"
alias ..="cd .."
alias ...="cd ../.."
alias j="z"
alias ji="/Users/flanggut/homebrew/bin/fish"
alias vim=nvim
alias ls="ls --color"
alias la="ls --color -la"
#     Git + HG commands    #
alias shows="hg show --stat"
alias sshow="hg st -m"
alias sl="hg fsl"
alias ssl="hg fssl"
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
alias dff="if is_git; then git diff | delta | less -r; else hg diff | delta | less -r; fi"
alias show="if is_git; then git show | delta | less -r; else hg diff -r .^ | delta | less -r; fi"
alias st="if is_git; then git st; else hg st; fi"
alias qd="adb devices && maui q d"


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

################     Plugins      ##############
# Antidote
# Bootstrap
if [[ ! -d ${ZDOTDIR:-~}/.antidote  ]]; then
  git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote
fi

zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  (
    source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh
    antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
  )
fi
source ${zsh_plugins}.zsh

# Zoxide
eval "$(zoxide init zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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
HISTSIZE=100000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
# To save every command before it is executed
setopt inc_append_history
# To read and update history on every command
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_find_no_dups


