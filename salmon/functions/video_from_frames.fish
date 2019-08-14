function video_from_frames
  ffmpeg -r 30 -f image2 -i $argv -c:v libx264 -preset slow video.mp4
end
