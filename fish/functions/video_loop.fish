function video_loop
  for i in (seq 1 $argv[2]); printf "file '%s'\n" $argv[1]; end > loopfiles.txt
  ffmpeg -f concat -i loopfiles.txt -c copy loop_$argv[1]
  rm loopfiles.txt
end
