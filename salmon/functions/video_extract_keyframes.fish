function video_extract_keyframes
  ffmpeg -i $argv -vf select="eq(pict_type\,PICT_TYPE_I)" -vsync 0 keyframe_%05d.png
end
