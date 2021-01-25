function __fzf_zd
  set dir (z -l $argv | cut -b12- | tac | fzf --tac --no-sort --preview 'tree -C {} | head -200' --preview-window down:40)
  if [ $dir ]
    cd $dir
  end
  commandline -f repaint
end
