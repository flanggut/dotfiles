function number_rename
  set x 0
  for f in (ls)
    set num (printf "%05d" "$x")
    set x (math "$x+1")
    mv $f frame_$num.png
  end
end
