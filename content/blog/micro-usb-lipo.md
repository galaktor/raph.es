+++
author = "raph"
date = "2014-10-14T19:35:00+01:00"
projects = [ "mudcam" ]
series = [ "battery pi" ]
tags = [ "raspberry pi", "power", "hardware", "usb" ]
title = "Custom lipo-to-usb connector"
slug = "lipo-battery-to-micro-usb-power-adapter"
+++
I want to power a Raspberry Pi off a LiPo battery. In an attempt to be as littleinvasive as possible I figured I might just route the power through the micro USB port.

There is a pin on the GPIO that is connected to the +5V rail, but it bypasses the fuse and I'd like to stick to recommended usage scnearios unless I have good reason not to. The Pi is meant to get power through USB, so let's do that.

This is first and foremost an experiment to get a feel for the voltage drop on the way into the `RG2` regulator.

# Power pins
The Pi doesn't use all of the USB pins. It only takes the +5V on pin 1 and connects to ground on pin 5.

{{% fig caption="Pins 1 and 5 are for power" attr="Peter Vis" attrlink="http://www.petervis.com/Raspberry_PI/Raspberry_PI_Power_Supply/Raspberry_PI_Micro_USB_B_Specification.html" %}}
{{% img src="/img/project/mudcam/micro-usb-power-pins_peter-vis.gif"  link="/img/project/mudcam/micro-usb-power-pins_peter-vis.gif" widht="400em" %}}
{{% /fig %}}

So I bought some male USB connectors.

{{% fig %}}
{{% img src="/img/project/mudcam/micro-usb-male_thumb.jpeg" link="/img/project/mudcam/micro-usb-male.jpeg" %}}
{{% /fig %}}

The pins are quite close together and since I only need the two on the outside, I took off the other three. I found the easiest way to do this was by bending the pins left and right with tweezers until it broke off. That way there's enough room to solder - it's still a bit tricky.

To not have to remember which wire is which it makes sense to stick with convention and put the red wire onto pin 1, and the black wire to pin 5. This is a power connector after all. Stick heat shrinks over the solder joints after soldering.

{{% fig %}}
{{% img src="/img/project/mudcam/micro-usb-solder_thumb.jpeg" link="/img/project/mudcam/micro-usb-solder.jpeg" %}}
{{% img src="/img/project/mudcam/micro-usb-shrinks_thumb.jpeg" link="/img/project/mudcam/micro-usb-shrinks.jpeg" %}}
{{% /fig %}}

Finally, I stuck on a glob of hot glue as a crude strain relief.

{{% fig %}}
{{% img src="/img/project/mudcam/micro-usb-pins-close_thumb.jpeg" link="/img/project/mudcam/micro-usb-pins-close.jpeg" %}}
{{% img src="/img/project/mudcam/micro-usb-glue_thumb.jpeg" link="/img/project/mudcam/micro-usb-glue.jpeg" %}}
{{% /fig %}}

That's it! Now I can run the Pi off any power source I like.