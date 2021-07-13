function cdd
  set dir (find -L . -mindepth 1 -maxdepth 1 -type d | cut -b3- | fzf --preview 'tree -C {} | head -200')
  if [ $dir ]
    cd $dir
  end
  commandline -f repaint
end
