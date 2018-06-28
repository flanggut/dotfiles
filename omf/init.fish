set -g theme_color_scheme solarized
set -g theme_date_format "+%H:%M:%S"

set -gx BD_OPT 'insensitive'

alias rg="rg --max-columns=160 -S"
alias ...="cd ../.."

switch (uname)
  case Darwin
    source ~/.iterm2_shell_integration.fish
    alias vim="mvim"
    alias vi="vim"
    alias cmake="cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1"
end

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
