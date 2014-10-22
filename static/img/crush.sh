#!/bin/bash



for img in **/*.* **/**/*.*; do
  # todo: exclude files already converted; e.g. by adding "wm" to file name or similar
  echo processing \"$img\"
  base=${img%.*} # no dir: $(basename ${img%.*}
  echo  "$base"
  case "$base" in
    *_thumb)
      echo "is thumb; skipping"
      ;;
    *_wm)
      echo "already watermarked; skipping"
      ;;
    *)
      echo "watermarking $img"
      ext="_wm.jpeg"
      target="$base$ext"
      width=$(identify "$img" | cut -d" " -f3 | cut -dx -f1)
      height=$(identify "$img" | cut -d" " -f3 | cut -dx -f2)
      size=$(($height/45))
      # first pass, black text
      convert "$img" -pointsize "$size" -gravity southeast -fill "#000000" -draw "text 5,5 '(c) 2014 http://raph.es'" -quality 100 "$target"
      # second pass, white text and some compression
      convert "$target" -pointsize "$size" -gravity southeast -fill "#FFFFFF" -draw "text 6,6 '(c) 2014 http://raph.es'" -quality 95 "$target"
      # thumbnail
      echo "thumbnailing $img"
      ext="_thumb.jpeg"
      target="$base$ext"
      if [ $width -gt $height ]
	  then
  	    convert "$img" -resize 300x -quality 95 "$target"
          else
            convert "$img" -resize x300 -quality 95 "$target"
      fi
      ;;
  esac
done
