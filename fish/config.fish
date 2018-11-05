############################
#     Bootstrap fisher     #
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

############################
#        Setup Theme       #
set -g theme_color_scheme solarized
set -g theme_date_format "+%H:%M:%S"

############################
#       Alias Config       #
alias vim="nvim"

alias dff="hg diff --color=always | diff-so-fancy | less -R"
alias show="hg diff -r .^ --color=always | diff-so-fancy | less -R"
alias shows="hg show --stat"
alias sl="hg fsl"
alias histe="hg histedit"

alias brewown="sudo chown -R (whoami) /usr/local/lib /usr/local/sbin"

alias rg="rg --max-columns=160 -S"
alias ...="cd ../.."

############################
#       Mac Specifics      #
switch (uname)
  case Darwin
    test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish
    alias cmake="cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1"
    alias fll="rg --files | rg"
end

############################
#          Colors          #
set -x LS_COLORS 'di=0;34:ln=0;36:ex=0;91'

set fish_color_autosuggestion 555 brblack
set fish_color_cancel -r
set fish_color_command --bold
set fish_color_comment red
set fish_color_cwd green
set fish_color_cwd_root red
set fish_color_end brmagenta
set fish_color_error brred
set fish_color_escape bryellow --bold
set fish_color_history_current --bold
set fish_color_host normal
set fish_color_match --background=brblue
set fish_color_normal normal
set fish_color_operator bryellow
set fish_color_param cyan
set fish_color_quote yellow
set fish_color_redirection brblue
set fish_color_search_match bryellow --background=brblack
set fish_color_selection white --bold --background=brblack
set fish_color_user brgreen
set fish_color_valid_path --underline

