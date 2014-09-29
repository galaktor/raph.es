#!/bin/bash
echo "<div id=\"logo\">"
echo "  <div class=\"line\">"
while IFS= read -r -N 1 char
do
  if [[ "$char" == $'\n' ]]
  then
    echo "</div>"
    echo "<div class=\"line\">"
  elif [[ "$char" == $' ' ]]
  then
    echo "<div class=\"pixel-fade\"></div>"
  else
    echo "<div class=\"pixel\"></div>"
  fi
done < logo.txt
echo "</div>"

