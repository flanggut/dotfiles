function zd
  set dir (z -l $argv | cut -b12- | tail -r | fzf --reverse --preview 'tree -C {} | head -200')
  if [ $dir ]
    cd $dir
  end
end
