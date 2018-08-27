function mov2gif
  ffmpeg -i $argv -vf scale=w=1000:h=1000:force_original_aspect_ratio=decrease -pix_fmt rgb24 -r 10 -f gif - | gifsicle --optimize=3 --delay=3 > out.gif
end
