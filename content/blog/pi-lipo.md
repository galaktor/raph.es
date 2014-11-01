+++
author = "raph"
date = "2014-10-10T17:25:49+01:00"
draft = false
projects = [ "mudcam" ]
series = [ "battery pi" ]
tags = [ "raspberry pi", "power", "hardware" ]
title = "Feasability of powering a Raspberry Pi with a 3.7V battery"
wasblogger = false
slug = "feasible-power-raspberry-pi-3.7V-lipo-battery"
+++
I recently got thinking about how I might power a Raspberry Pi off batteries. The [project](/project/mudcam) I have in mind is effectively a wearable video camera, so it has to be as compact as possible and have a good few hours of battery life to be of any practical use.

Raspberry Pi boards are not designed for embedded projects. Instead, they are supposed to be small, cheap computers for use with simple USB keyboards and HD TVs. There is much confusion around how to power the Pi, and every revision has brought changes to the power circuits.

That said, with some modification a Pi can still be very useful in embedded projects such as the one I have in mind. The following is the summary of my research on the subject of powering the Raspberry Pi, particularly with an eye towards lower-than-recommended voltage like from batteries.

# The 5V requirement
It seems that the Pi only requires 5V in order to comply with the USB and HDMI standards. Otherwise, the board itself has no need for 5V at all.

According to [Dave Akerman](http://www.daveakerman.com/?page_id=1294), the 5V from USB only powers a handful of components:

1. USB peripherals
2. HDMI output
3. VSense pin on the BCM2835 MCU
4. the 3.3V voltage regulator


# 1. USB power
The Pi was designed to be a cheap, small,  stationary computer that can easily interface with most keyboards and screens. Naturally it was built around the USB power standards. Specifically USB 2.0 at the time. The micro USB port of the Pi gets +5V DC via pin 1 and the 0V/GND line on Pin 5. None of the USB data lines are used.

It makes sense that the Pi requires 5V input in order to provide the same to it's standard keyboard and mouse peripherals.

I don't want to use USB peripherals at all, so I should be able to ignore this requirement.

## 2. HDMI
Another main feature of the Pi that made the designers opt for a 5V power requirement is HDMI video output. The HDMI standard [requires](http://www.hdmi.org/learningcenter/kb.aspx?c=13) 5V on one of it's lines.

> The HDMI specification requires all source devices to provide at least 55mA (milliamps) **on the 5V line** for the purpose of reading the EDID of a display.

HDMI is basically the USB for displays and it's everywhere. It was good call since HDMI support is  one of the most popular features of the Pi. Just look at how many people use it as a hi-def media center.

I don't require HDMI output for my project, so again, I should be able to safely ignore this requirement.

## 3. VSense pin
This is a special pin on the Broadcom SoC. From what I could gather it has to be kept high so that the MCU knows that there's sufficient voltage for operation. If voltage drops too low, the chip will deactivate and the Pi will not work.

However, it [seems](http://www.daveakerman.com/?page_id=1294) that 3.3V is sufficient to keep the pin high. 5V is not really required here.

Three down, one to go.

## 4. RG2
Most of the components on the Pi PCB work off 3.3V or less, so a voltage regulator marked `RG2` on the PCB has the job of stepping down the 5V from USB to more tolerable 3.3V. The regulated output from RG2 also flows into two other regulators, `RG1` and `RG3` - those step the voltage down even further for more sensitive components.

`RG2` in most new boards is a linear voltage regulator of type [NCP1117](http://www.onsemi.com/PowerSolutions/product.do?id=NCP1117). It's takes in a more or less wide range of voltage and steps it down to 3.3 volts. The excess is lost as heat.

This is where things get very interesting, and I'll come back to `RG2` in a moment.

# Current draw
The less current the Pi needs, the smaller my batteries can be and the longer they can last. The amount of current a Raspberry Pi will draw depends on a few factors. Here's some tricks I collected to reduce current draw to a minimum.

## Model A FTW
I have a Raspberry Pi Model A which according to spec can draw up to 500mA. Fortunately for me, this is an upper limit for standard use cases involving HDMI screens and some USB devices connected.

Hackers on the interwebs report that a model A can draw as little as 115mA. The model B has additional components - most notably an ethernet controller - and requires up to three times as much as the model A. The B+ is fairly new and I've heard it's optimized a bit compared to the B even though it has even more connectors. Still, it pulls more amps than a model A.

I don't need any of the fancy additions in models B or B+. I managed to get my hands on another model A which I'll be using for the project. Model As are hard to come by these days. Grab one when you get the chance. I got one off eBay. *Slightly* overpriced - just a bit. Hope it's worth it...

## Don't trust USB.                                          
In addition to the on-board components, any connected USB peripherals can increase the Pi's draw significantly. Unless you use a powered USB hub or some other form of external power for your devices, they will pull power straight through the Pi. This can have all kinds of strange side effects.

Many a newbie problem can be traced back to insufficient or irregular power supply.

In *theory*, you can power a Pi from the USB on your computer or hub. USB 2.0 devices are allowed to draw up to 500mA. But because the Pi is not connected to the two USB data lines, it will not be detected by a host that enumerates it's USB slaves. USB devices communicate their power requirements via the data lines to the host. The Pi cannot do that, so it's very possible that a host will limit current to merely 100mA.

Best *practice* is to use a powered USB hub and/or dedicated power supply. Some people even build their own PSUs. Otherwise the combined current draw of Pi plus USB devices can exceed what is provided via the USB port alone. Similar problems arise when using random power supplies such as phone chargers.

As I mentioned earlier, I have no intention of using USB devices in my project. Bullet dodged.

## Disable video output to save power
You can disable certain components on the Pi to save some power consumption, most notably the video outputs. Here's what I found on the web for the default Raspbian distro:
    
	# on startup of Raspbian
	# deactivate video output
    /opt/vc/bin/tvservice -off

I believe it's the same in Arch, my preferred distro - not only for the Pi. I've yet to test this.

It is not clear to me how much this will save. The HDMI spec indicated up to 55mA draw. How much this actually is without a TV connected, I cannot say. I suspect that this will have very little effect on power consumption.

## Underclock the MCU to save power
You can change some boot parameters for the Pi firmware, including clock rates for MCU/GPU and memory sizes. It would seem intuitive to assume that clocking the chips down a notch could save some power.

However, from what I heard, underclocking doesn't seem to make a relevant difference compared to other big spenders like USB, the `RG2` regulator and in some cases the `F3` fuse (see below).

## Bypass the fuse
There are a few fuses on board. Some smaller ones protect connected USB devices, so the power leaving the Pi. But a big one is on the input side and is hooked up to the micro USB power input.

The fuse increases resistance as current levels go up. It starts to kick in around 700mA, and blows somewhere over 1A. Notice that this puts a hard limit on how much current your Pi and all of it's USB devices can get, even if the PSU you have connected to the micro USB connector can give more.

Even if you are well under the 700mA draw, the fuse might drop some voltage before the power even hits the rest of the board. How much depends on the fuse, since they have some production-based variance. Also, if you ever blew the fuse it can take days and weeks until the drop goes away.

Having the fuse is a good thing for most use cases. You don't want little Jimmy to burn his Pi just because he hooked up his USB hair dryer to the Pi. But in my case the batteries won't even be able to give enough juice to max out the fuse. Plus, I'm going for as little current draw as possible. So bypassing the fuse altogether is definitely an option.

You can either bridge the fuse connectors with a smaller resistor, so current flows through that rather than the fuse. Or maybe even put a jumper across for zero resistance.

A simpler, less invasive way is to power the Pi via it's GPIO pins. One is connected to the 5V rail after the fuse. This is what most embedded projects do.

Obviously at the risk of frying the board.

Well, **YOLO**.

## RG2 is a problem
Revistion 2 boards (i.e. newer model Bs and all model As) have a `NCP1117-3V3` primary voltage regulator at `RG2`. It, in turn, powers two other regulators `RG1` and `RG3`. The stuff I care about all takes power from this guy.

The problem with RG2 is, it was chosen to fit the typical conditions for the Pi: regulated +5V DC. The NCP1117 has a drop out voltage of over 1.2V. This means the difference between it's input and output voltage has to be at least 1.2V. If the voltage is lower than the DO, the regulator will stop working. No power downstream means, well, no power for your Pi.

We know the output of RG2 is 3.3V. So the minimum input voltage after the fuse has to be *at least* 4.5V. This is a problem if you're trying to run on batteries. Most affordable batteries have lower voltages than 5V.



# Ways to make batteries work
There's a few ways to work around the issue of `RG2`'s minimum voltage, which I'll describe in the next section.

## Use higher voltage batteries
And let RG2 step it down again.
Loose the difference as heat.
Wasteful.

## Step up lower voltage batteries
Take lower volt batteries, and run them through a step up converter.
Draws more power from your batteries.
Is not very efficient, and you're only doing it to step it down again in `RG2`.

## Replace RG2 with lower DO
THIS

----

use higher voltage batteries, and step them down to 5v: for example, 4 AA batteries in series provide ~6V. >1 lipo cell will also need to be stepped down, say 2S (2 cells in series) = 2x3.7V = 7.4V.

stepping down usually done via voltage regulators, linear or switching. switching more configurable and efficient, but more expensive and take a bunch of space. some elaborate engineering going on in the forums about this :-) linear is much simpler but often much less efficient than switching ones, although the efficiency of linear regulators generally increases the closer your input voltage gets to your output voltage. the efficiency correlation is ... linear!

if like me you don't really care about USB and HDMI (headless mode, no wifi or similar) you might wonder why do you need 5V at all? or even the higher voltages above? the energy you provide will be wasted largely anyway (rg2 is linear, so efficiency gets worse the higher the input voltage is). very inefficient for me.

ideally i would be able to supply as close to 3.3V as possible, allowing for sufficient current draw under recording/IO load (VERY rough guess: ~500mA - 1A). a single cell LiPo provides between ~3V(ish) (drained) and ~4.2V (charged). this is assuming lipo has undervoltage protection that cuts off at some point, typically a bit over/under 3V.

so how to use lowe voltage?
step up lower voltage to 5V. this is accomplished using step up/boosters which again are not known to be very efficient in the first place. you can find many examples on the web where people show off their nice Pi running of two AA batteries (3V) but generally their battery life will be terrible. cool hack, but not great if you want to run the thing for a few hours. booster efficiency is (from what i gather reading about them...) roughly 70%. So you loose 30% power just pushing power into the Pi. Then that 5V power gets used for stuff you might not even need (usb, hdmi). The rest gets regulated down again into 3.3V by your rg2, again at (best) approx 70% efficiency, losing another 30%. keep in mind, rg2 efficiency can be as bad as 50%. So there goes lots of precious battery life!

so why not just plug in a single cell lipo?
I could take a male micro-usb connector, and attach a JST plug or similar for battery to go into the USB D+ and D- pins. This would feed battery directly into the pi.
PROBLEM: built in regulator has a drop out voltage of at least 0.9V, with 1A current draw it will be around 1.1V, up to even 1.2V. That means the difference between output (3.3V) and it's input has to be at least 1.1V realistically. that's 3.3V + 1.1V = 4.4V. the specs say min is 4.75V, i suppose to not be to close to the edge given variance in parts and power stability.

So the regulator will not do anything if voltage is below 4.4V - and a single cell lipo will AT BEST (for a brief period of time) provide about 4.2V. most of the time 3.7V. NOT GOING TO WORK!

Even though the Model A is often used for embedded projects due to it's lower current draw, the Pi was not designed with embedded projects in mind. It's meant to be a learning computer that powers from USB and connects to various other USB devices, hence the 5V situation. But if you really just want to leverage the onboard MCE and maybe the camera and some GPIO you don't need 5V at all, but the rg2 regulator forces you to.

IT'S WARRANTY VOIDING TIME! We can remove this limitation by replacing the rg2 regulator. Warning, this is an insanely cool hack and you absolutely should try it - if you're willing to sacrific your Pi when things go wrong. FOR SCIENCE!
For this to work we need to have a clear picture of our power requirements. Given a single cell LiPo, our input voltage is going to be between 3.5V(ish) and 4.2V(ish). The draw of model A and cam is estimated to be around 600ma. The original rg2 can do between 1A and 2.2A. Let's compromise around 1A here.
To maximise efficiency we could look at using switching regulators, but their efficiency can vary to a point of being not much better than linear ones, plus their more expensive and more involved to install (i.e. mount the big thing somewhere).

What we really need is a lower drop out voltage than the original Pi has, since that's what's preventing us from using our lipo battery cell in the first place. Thankfully, there are many that have much lower drop out, aka "low drop out" LDO. for instance the 182x series from Microchip:
* MCP1825,  500mA output current, ~0.21V DO, ~5 EUR on ebay
* MCP1826, 1000mA output current, ~0.30V DO, ~5-6EUR on ebay
* MCP1827, 1500mA output current, ~0.33V DO, ~7EUR on ebay

say we used the MCP1827 with a typical DO of 0.33V. Set to 3.3V output, that's a min of 3.6V input. Remember out typical lipo cell has 3.7 nominal output voltage. it seems hard to get input voltage any closer to the 3.3V we really want to use! you could probably get a bit more life out of your battery when using the 1826 or even 1825, but you'll sacrifice output current as you do. so you really need to understand how much you will be drawing before you can make the best decision here. if in doubt, without HDMI or USB I suspect you can easily go with 1A current, but I'm not fully sure about the 1825 - reports do indicate the Pi can run as low as 115mA so it might work, depending on how you utilize the pi. 
The Pi fuse appears to be at 750mA
The USB 2.0 standard says max 500mA
So it's reasonable to assume that a Pi w/o video or USB peripherals will draw not even close to 500mA.

How long can we expect the battery to last? This of course depends on the lipo capacity. I have a spare 1200mAh 3.7V single cell lipo at home, let's do a Gedankenexperiment here. I'm going to assume I run some tests and determine that my requirements are under 500mA and I can run with the 1825. that has very low drop out and can run longer on lower voltage from my batteries as they drain.


3.7V nominal battery voltage, let's be pessimistic and say it's at the lowest allowed
3.7V - 0.21 DO = 3.49V (around here the undervoltage protection could kick out, but let's ignore for now)

available power in watt = V * Ah
3.49V * 1.2Ah = 4.188 Wh 
(guestimated worst case; capacity could vary as well, but let's leave some optimism in there!)

required power in watt
3.3V * 0.5Ah (mcp1825 max out) = 1.65 Wh 
(guesstimated worst case, exact power requirements will go up and down, and have yet to be measured with picam and IO)

so theoretically, given the above assumptions of course, I could run
4.188 Wh / 1.65 Wh = 2.53 h
off just that tiny single cell lipo!

keep in mind, if I do need more than 500mA and opt for 1826 or even 1827 I'll have to expect a drop out earlier than that, but that's cutting it pretty close to the nominal 3.7V of the battery. and limits will also vary based on temperature etc so it's hard to say. it will most certainly be less than the above.

NOW let's go further and say I bough a bigger lipo. let's say one of those tablet replacement lipos you can get on ebay for about 10 EUR, and can have over 3Ah of power. 

3.49V * 3Ah = 10.47 Wh available
10.47 Wh / 1.65 Wh = ~6.3 hours!

And that still with a fairly low profile, slim battery.

So that's the theory, I'll need to measure actual current requirements in experiment next. Then decide which regulator to get (hope I can get away with the 1825...). Then order a nice lipo that can fit into my space requirements.


 
 links
 
 Pi power
http://www.petervis.com/Raspberry_PI/Raspberry_PI_Power_Supply/Raspberry_PI_Micro_USB_B_Specification.html
 
 rg2
 http://www.onsemi.com/PowerSolutions/product.do?id=NCP1117
 http://www.onsemi.com/pub_link/Collateral/NCP1117-D.PDF
 
 mcp182X
 http://www.microchip.com/wwwproducts/Devices.aspx?product=MCP1825
 http://www.microchip.com/wwwproducts/Devices.aspx?product=MCP1826
 http://www.microchip.com/wwwproducts/Devices.aspx?product=MCP1827
 
 lipos sparkfun:
 https://learn.sparkfun.com/tutorials/battery-technologies/lithium-polymer
 
 lipos rc dude:
 http://www.rogershobbycenter.com/lipoguide/
 
 on rg2
 http://www.petervis.com/Raspberry_PI/dead-raspberry-pi/dead-raspberry-pi.html
 
 on battery life and voltage regulators
 http://www.daveakerman.com/?page_id=1294
 
 regulator?
 http://www.microchip.com/wwwproducts/Devices.aspx?product=MCP1826
