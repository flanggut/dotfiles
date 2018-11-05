function cdf

  set FILE (fzf --reverse --preview 'tree -C `dirname {} | head -200`')
  cd (dirname $FILE)

end
