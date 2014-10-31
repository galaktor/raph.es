+++
author = "raph"
date = "2014-10-20T07:56:12+01:00"
projects = [ "mudcam" ]
series = [ "battery pi" ]
tags = [ "raspberry pi", "power", "hardware" ]
title = "replace pi rg2"
slug = "replace-raspberry-pi-voltage-regulator-rg2"
draft = true
+++
maximize usage of battery via lowest possible dropout voltage

new reg much closer to 3.3v on nominal 3.77v from lipo. hope to maximize battery life by replacing reg

voltage reg test results:

on board with pi, ncp1117
in: 3.63v (seem to lose ~1.4v between usb and regulator??) ->bypass FUSE!
reg out: 2.71v
diff: ~0.9


new mcp1826s
in: 3.77v
out: 3.25V
diff: ~0.52v
do??

mcp1ts est using arduino 5v output
in: 5.15V
out: 3.25V
do: 

new pi mod a
at batt: 3.71v
test points: 3.62v
reg in: 3.62v
reg out: 2.68v
reg diff: 0.96v

test after repl rg, NO SD CARD:
at batt: 4.02V
test points: 4.02V
reg in: 4.02V
reg out: 3.25V

test after repl rg, WITH SD CARD:
at batt: 4.02V
test points: 3.94V
reg in: 3.94V
reg out: 3.25V
