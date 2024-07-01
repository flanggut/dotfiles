# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

######     Path      ######
path+=('/Users/flanggut/homebrew/bin')
export PATH

######     Alias      ######
alias j="z"
alias ji="/Users/flanggut/homebrew/bin/fish"
alias vim=nvim
alias ls="ls --color"
#     Git + HG commands    #
alias shows="hg show --stat"
alias sshow="hg st -m"
alias ssl="hg fssl"
alias histe="hg histedit"
alias hgn="hg next"
alias hgp="hg prev"
alias jfs="jf s"
alias jfa="jf a"
alias jfs2="jf s -r .^..."
alias jfs3="jf s -r .^^..."
alias jfs4="jf s -r .^^^..."
alias jfs5="jf s -r .^^^^..."

######   Fuzzy Matching    ######
# 0 -- vanilla completion (abc => abc)
# 1 -- smart case completion (abc => Abc)
# 2 -- word flex completion (abc => A-big-Car)
# 3 -- full flex completion (abc => ABraCadabra)
zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'

######     Plugins      ######
# Antidote
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
