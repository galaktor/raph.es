+++
author = "raph"
date = "2016-09-03T19:24:01+01:00"
projects = [ "mk" ]
series = []
tags = [ "mecha", "wasd", "pok3r", "gaming" ]
title = "Today I designed a mechanical keyboard"
wasblogger = false
aliases = []
slug = "i-designed-a-wasd-mechanical-keyboard-pok3r"
draft = false
+++
# The dream
I always wanted a mechanical keyboard. And while I'm at it, I wanted it to be something special - something only I could love.

When I had some bucks left to spend from a cash reward, the time had come. I pulled the trigger and got me a [60% VP3 from WASD](http://www.wasdkeyboards.com/index.php/products/mechanical-keyboard/wasd-vp3-61-key-custom-mechanical-keyboard.html) - essentially a non-backlit [Vortex Pok3r](https://corus-kb.com/en/27-pok3r) with custom-designed legends and keycaps printed by WASD.

The ABS keycaps from WASD aren't supposed to be top notch, but I can upgrade those later. Neither is the lack of backlighting an issue for me, because LEDs can be added on later, too. Other than that, the pok3r is supposed to be a pretty solid MK.

# The design
It's a retro-kitsch take on the HUD of a space simulator game with a dash of 8-bit nostalgia. Word fragments are loosely based on [Elite: Dangerous](https://en.wikipedia.org/wiki/Elite:_Dangerous). Elite uses more orange in the spaceship HUDs, but I think the classic black-green sci-fi palette worked better.

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
* Plenty of techno-babble from *Elite: Dangerous*
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
