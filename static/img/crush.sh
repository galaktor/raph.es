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
      echo "todo: convert"
      ext="_wm.jpeg"
      target="$base$ext"
      convert "$img" -quality 95 "$target"
      ;;
  esac
done
