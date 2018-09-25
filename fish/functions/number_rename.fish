function number_rename
  set x 0
  for f in (ls | grep $argv)
    set num (printf "%05d" "$x")
    set x (math "$x+1")
    mv $f frame_$num.$argv
  end
end
