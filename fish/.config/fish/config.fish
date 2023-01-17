############################
#     Bootstrap fisher     #
if not functions -q fisher
    echo "curl -sL https://git.io/fisher | source"
    echo fisher install jorgebucaran/fisher
    echo fisher install IlanCosman/tide@v5
end

############################
#      Global Configs      #
set -gx SHELL fish
set -gx EDITOR nvim
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8
set -gx LC_CTYPE en_US.UTF-8
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

# This expands .. to cd ../, ... to cd ../../ and .... to cd ../../../ and so on.
function multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
abbr --add dotdot --regex '^\.\.+$' --function multicd

alias vim="nvim"
alias duh="du -h -d1"
alias ll="tree -C | less -r"
alias mru="ls -t | head -5"
alias p3="python3"

alias rg="rg --no-ignore-messages --max-columns=160 -S"

alias xtrace="xcrun xctrace record --template 'Time Profiler' --launch --"
alias xtracemem="xcrun xctrace record --template 'Allocations' --launch --"

############################
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

function is_inside_git
    set -l repo_info (command git rev-parse --git-dir --is-inside-git-dir --is-bare-repository --is-inside-work-tree HEAD 2>/dev/null)
    test -n "$repo_info"
    or return 1
    return 0
end

function ci
    if is_inside_git
        git ci
    else
        hg ci
    end
end

function dff
    if is_inside_git
        git diff | delta | less -r
    else
        hg diff | delta | less -r
    end
end

function sl
    if is_inside_git
        git sl
    else
        hg fsl
    end
end

function show
    if is_inside_git 
        git show | delta | less -r
    else
        hg diff -r .^ | delta | less -r
    end
end

function st
    if is_inside_git
        git st
    else
        hg st
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
