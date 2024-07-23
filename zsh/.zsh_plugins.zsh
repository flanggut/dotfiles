fpath+=( $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-Aloxaf-SLASH-fzf-tab )
source $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-Aloxaf-SLASH-fzf-tab/fzf-tab.plugin.zsh
fpath+=( $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-romkatv-SLASH-powerlevel10k )
source $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-romkatv-SLASH-powerlevel10k/powerlevel10k.zsh-theme
source $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-romkatv-SLASH-powerlevel10k/powerlevel9k.zsh-theme
fpath+=( $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-completions )
source $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-completions/zsh-completions.plugin.zsh
fpath+=( $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions )
source $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
fpath+=( $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-syntax-highlighting )
source $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
fpath+=( $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-getantidote-SLASH-use-omz )
source $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-getantidote-SLASH-use-omz/antidote-use-omz.plugin.zsh
source $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-getantidote-SLASH-use-omz/use-omz.plugin.zsh
fpath+=( $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-ohmyzsh-SLASH-ohmyzsh/plugins/git )
source $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-ohmyzsh-SLASH-ohmyzsh/plugins/git/git.plugin.zsh
if is-macos; then
  fpath+=( $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-ohmyzsh-SLASH-ohmyzsh/plugins/brew )
  source $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-ohmyzsh-SLASH-ohmyzsh/plugins/brew/brew.plugin.zsh
fi
if is-macos; then
  fpath+=( $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-ohmyzsh-SLASH-ohmyzsh/plugins/macos )
  source $HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-ohmyzsh-SLASH-ohmyzsh/plugins/macos/macos.plugin.zsh
fi
fpath+=( $HOME/dotfiles/zsh/plugins/fzf )
source $HOME/dotfiles/zsh/plugins/fzf/fzf.plugin.zsh
fpath+=( $HOME/dotfiles/zsh/plugins/adb )
source $HOME/dotfiles/zsh/plugins/adb/adb.plugin.zsh
fpath+=( $HOME/fbconfig/zsh/plugins/dbu )
source $HOME/fbconfig/zsh/plugins/dbu/dbu.plugin.zsh
