function fzf_file

  set FILES (fzf -m)
  for file in $FILES
    commandline -it -- "\"$file\""
    commandline -it -- " "
  end
  commandline -f repaint

end
