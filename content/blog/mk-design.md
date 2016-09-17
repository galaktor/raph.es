+++
author = "raph"
date = "2016-09-03T19:24:01+01:00"
projects = [ "mk" ]
series = [ "cmdr-pixel" ]
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

The ABS keycaps from WASD don't have a great reputation amongst MK enthusiasts, but should be good enough to get started. I would like me some backlighting, but that can be added fairly easily on the pok3r by soldering on LEDs later.

I expect this board to be a good entry into the MK game. There's plenty of room upwards if I want to upgrade.

# The design
 I have a soft spot for old space simulators like *Elite* and *Wing Commander*. I spent more time than I'd like to admit trading alloys and hunting space pirates. All going well, this keyboard will be my workhorse for programming, and as such a central tool in my programming job. The dashboard to my spaceship, one could say.

So I came up with a retro-kitsch take on the HUD of a space simulator game with a dash of 8-bit nostalgia.  The word fragments on some of the keys are loosely based on [Elite: Dangerous](https://en.wikipedia.org/wiki/Elite:_Dangerous).

The colour palette, however, is more reminiscent of the *Wing Commander* games or *Aliens*. Outside the context of an actual game, the green-and-black palette brought to mind "sci-fi" easier than using the orange-y colours of an *Elite*.

In hindsight, I might have missed a few opportunities with the legends (I was in a bit of a hurry to not let the reward expire). For one, the space bar could use more interesting typography. Then I noticed a slight redundancy between the "Supercruise" (on left shift) and "Super".

Finally, I only found out after submitting the order that the newer pok3r firmware versions also includes default-layer media controls on the `Q`, `W` and `E` keys (and many more). I might have been able to design those in, too. Welp.

### Pixel font
The font I used for the legends is the free and amazing [Telegrama raw](http://www.yoworks.com/telegrama/index.html) by [YOWorks](http://www.yoworks.com). It comes in a *render* version, too, which would give more of a modern sci-fi feel - but I really wanted some pixels on there. Because I'm old, I guess.

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
{{% fig caption="Inspiration for the general idea of a HUD keyboard" attr="Data from Geekhack" attrlink="https://www.massdrop.com/buy/danger-zone-sa-keycap-set"  %}} {{% img src="/img/project/cmdr-pixel/danger-zone.jpeg" link="/img/project/cmdr-pixel/danger-zone.jpeg" width="500px" %}} {{% /fig %}}

{{% fig caption="Inspiration for the sci-fi theme" attr="Just Gamers" attrlink="http://www.just-gamers.fr/pc/wing-commander-iii-heart-of-the-tiger.html"  %}} {{% img src="/img/project/cmdr-pixel/wing-commander.jpeg" link="/img/project/cmdr-pixel/wing-commander.jpeg" width="500px" %}} {{% /fig %}}
