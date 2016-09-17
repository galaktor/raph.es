---
date:      "2016-09-03T19:24:01+01:00"
title:     "cmdr-pixel"
author:    "raph"
project:   "mk"
progress:  60
state:     "in production"
ascii:     "ascii/keyboard.txt"
---
My first stab at a custom-designed keyboard. It's for a [61-key VP3 from WASD](http://www.wasdkeyboards.com/index.php/products/mechanical-keyboard/wasd-vp3-61-key-custom-mechanical-keyboard.html).

## Design
{{% fig caption="The design I sent to *WASD Keyboards*" %}}
{{% img src="/img/project/cmdr-pixel/legends.png" link="/img/project/cmdr-pixel/legends.png" width="500px" %}}
{{% img src="/img/project/cmdr-pixel/digital-preview.png" link="/img/project/cmdr-pixel/digital-preview.png" width="500px" %}}
{{% /fig %}}

## Actual keyboard
{{% fig caption="The keyboard as I received it" %}}
{{% img src="/img/project/cmdr-pixel/top_phone_thumb.jpg" link="/img/project/cmdr-pixel/top_phone.jpg" width="500px" %}}
{{% img src="/img/project/cmdr-pixel/left-angle_dslr_thumb.jpg" link="/img/project/cmdr-pixel/left-angle_dslr.jpg" width="500px" %}}
{{% img src="/img/project/cmdr-pixel/right-angle_dslr_thumb.jpg" link="/img/project/cmdr-pixel/right-angle_dslr.jpg" width="500px" %}}
{{% /fig %}}

# Source code
Here's the SVG file I used to provide the design to WASD. You should be able to re-use or modify it as you see fit, just respect the license. You'll have to pick the keycap colours in their online designer tool.

[`mechanical-keyboard` GitHub repo](https://github.com/galaktor/mechanical-keyboard)![CC-BY-NC-SA](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)

# Next steps
* <strike>Pics of actual keyboard when it arrives</strike>
* Add backlighting by soldering on LEDS, as shown [here](https://medium.com/@DavidNZ/adding-led-lights-to-a-pok3r-keyboard-e772fdea86f0#.71gyefutn) and [here](http://imgur.com/a/Y2Yyn)
* Make a better USB cable; possibly replace/stabilize the USB connector on the PCB
* Find a case or sleeve to store the thing when not in use
