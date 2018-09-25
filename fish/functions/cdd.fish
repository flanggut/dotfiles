function cdd
  set dir (find -L . -mindepth 1 -maxdepth 4 -path '*/\.*' -prune -o -type d -print ^ /dev/null | cut -b3- | fzf --reverse --preview 'tree -C {} | head -200')
  if [ $dir ]
    cd $dir
  end
end
