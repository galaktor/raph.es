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

Finally, I stuck on a glob of hot glue as a form of strain relief. Pretty? Maybe not. But works for me.

{{% fig %}}
{{% img src="/img/project/mudcam/micro-usb-pins-close_thumb.jpeg" link="/img/project/mudcam/micro-usb-pins-close.jpeg" %}}
{{% img src="/img/project/mudcam/micro-usb-glue_thumb.jpeg" link="/img/project/mudcam/micro-usb-glue.jpeg" %}}
{{% /fig %}}

That's pretty much it! Now let's find out what happens when we use a vanilla Pi odel A on a standard LiPo.

# Results
When I connect up the power to the Pi, it seems to turn on just fine. An SD card running Arch for ARM is in. Hooking up my multimeter probes to the test points `TP1` (+) and `TP2` (-), this is what I get:

* at battery: 3.71v
* at test points: 3.62v
* at `RG2` *in*: 3.62v
* at `RG2` *out*: 2.68v

Knowing that the vanilla regulator at `RG2` has a DO of about 1V or more, I'm not surprised that it's not able to provide good 3.3V anymore given the low voltage from the LiPo.

The Pi seems to be running well enough, but I haven't tried doing anything interesting with it yet. The fact that all components which expect to get 3.3V are now on less than 3V means things won't run reliably. And as battery voltage drops, behaviour is unpredictable. Not great conditions for a project that I want to run stable for hours.

So having seen this, I'm going to have to remove `RG2` and replace it with a voltage regulator that has a lower DO.
