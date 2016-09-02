---
date:      "2016-09-03T19:24:01+01:00"
title:     "cmdr-pixel"
author:    "raph"
project:   "cmdr-pixel"
progress:  99
state:     "in production"
ascii:     "ascii/na.txt"
---
My first stab at a custom-designed keyboard. It's for a [61-key VP3 from WASD](http://www.wasdkeyboards.com/index.php/products/mechanical-keyboard/wasd-vp3-61-key-custom-mechanical-keyboard.html).

# The design
It's a retro-kitsch take on the HUD of a sci-fi simulator game with a dash of 8-bit nostalgia. Terminology loosely based on [Elite Dangerous](https://en.wikipedia.org/wiki/Elite:_Dangerous). Elite uses more orange in the HUDs, but I think the classic black-green sci-fi palette worked better.

The font I used for the legends is [Telegrama raw](http://www.yoworks.com/telegrama/index.html) by [YOWorks](http://www.yoworks.com).

## Layout features
* swapped the `@` and `"` (more UK-ish)
* dedicated legends for some of the VP3's default layer functions:
* arrow keys on `JIKL`
* volume control on `SDF`
* default layer selector on `M`
* Emacs `Command` and `Meta` keys where I like them (`CAPS` and `Left-Alt`)
* `0` through `9` in binary
* A red self-destruct button for `ESC`
* Plenty of techno-babble from `Elite: Dangerous`
* Notalgia-licious pixel legends

{{% fig caption="Legends only" %}}
{{% img src="/img/project/cmdr-pixel/legends.png" link="/img/project/cmdr-pixel/legends.png" width="500px" %}}
{{% /fig %}}

{{% fig caption="Digital preview of the layout" %}}
{{% img src="/img/project/cmdr-pixel/digital-preview.png" link="/img/project/cmdr-pixel/digital-preview.png" width="500px" %}}
{{% /fig %}}

# Source code
The keyboard is in production with WASD - I won't know if this design is any good until the result comes back. You were warned.

[`mechanical-keyboard` GitHub repo](https://github.com/galaktor/mechanical-keyboard)![CC-BY-NC-SA](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)

# Inspiration
{{% fig caption="Inspiration for the general idea" attr="Data from Geekhack" attrlink="https://www.massdrop.com/buy/danger-zone-sa-keycap-set"  %}} {{% img src="/img/project/cmdr-pixel/danger-zone.jpeg" link="/img/project/cmdr-pixel/danger-zone.jpeg" width="500px" %}} {{% /fig %}}

{{% fig caption="Inspiration for the sci-fi theme" attr="Elite Dangerous Wiki" attrlink="http://elite-dangerous.wikia.com/wiki/HUD"  %}} {{% img src="/img/project/cmdr-pixel/elite-hud.jpeg" link="/img/project/cmdr-pixel/elite-hud.jpeg" width="500px" %}} {{% /fig %}}

