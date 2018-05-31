set -g theme_color_scheme solarized
set -g theme_date_format "+%H:%M:%S"

set -gx BD_OPT 'insensitive'

switch (uname)
  case Darwin
    source ~/.iterm2_shell_integration.fish
    alias vim = "mvim"
    alias vi = "vim"
    set -g fish_user_paths "/usr/local/sbin" $fish_user_paths
end


