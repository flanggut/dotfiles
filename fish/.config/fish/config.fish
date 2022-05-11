############################
#     Bootstrap fisher     #
if not functions -q fisher
    echo "curl -sL https://git.io/fisher | source"
    echo fisher install jorgebucaran/fisher
    echo fisher install jethrokuan/z
    echo fisher install IlanCosman/tide@v5
end

############################
#      Global Configs      #
set -gx SHELL fish
set -gx EDITOR nvim
set -gx LC_ALL en_US.UTF-8
set -gx NNN_NO_AUTOSELECT 1

set -g tide_cmd_duration_threshold 100
set -g tide_cmd_duration_decimals 1
set -g tide_left_prompt_items os pwd git newline character
set -g tide_right_prompt_items status context jobs virtual_env cmd_duration time

zoxide init fish | source

############################
#       Alias Config       #
abbr -a j z
abbr -a ji zi

alias vim="nvim"
alias duh="du -h -d1"
alias ll="tree -C | less -r"
alias mru="ls -t | head -5"
alias p3="python3"

alias dff="hg diff | delta | less -r"
alias show="hg diff -r .^ | delta | less -r"
alias shows="hg show --stat"
alias sshow="hg st -m"
alias sl="hg fsl"
alias ssl="hg fssl"
alias histe="hg histedit"
alias hgn="hg next"
alias hgp="hg prev"
alias jfs="jf s"
alias jfs2="jf s -r .^..."
alias jfs3="jf s -r .^^..."
alias jfs4="jf s -r .^^^..."
alias jfs5="jf s -r .^^^^..."

alias brewown="sudo chown -R (whoami) /usr/local/lib /usr/local/sbin /usr/local/bin"

alias rg="rg --no-ignore-messages --max-columns=160 -S"
alias ...="cd ../.."

alias xtrace="xcrun xctrace record --template 'Time Profiler' --launch --"
alias xtracemem="xcrun xctrace record --template 'Allocations' --launch --"

function zp
  if test "$history[1]" != "zp"
    eval $history[1]
  else
    eval $history[2]
  end
end

############################
#       Mac Specifics      #
switch (uname)
  case Darwin
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

# Enable shell-integration for kitty
if set -q KITTY_INSTALLATION_DIR
    set --global KITTY_SHELL_INTEGRATION enabled
    source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
    set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
end
