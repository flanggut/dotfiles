function fd
  set dir (find -L . -mindepth 1 -maxdepth 3 -path '*/\.*' -prune -o -type d -print ^ /dev/null | cut -b3- | fzf --preview 'tree -C {} | head -200')
  if [ $dir ]
    cd $dir
  end
end
