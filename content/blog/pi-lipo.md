+++
author = "raph"
date = "2014-10-10T17:25:49+01:00"
draft = false
projects = [ "mudcam" ]
series = []
tags = [ "raspberry pi", "power", "lipo", "hardware" ]
title = "Thoughts on Running a Raspberry Pi off a single cell LiPo battery"
wasblogger = false
+++
I recently got thinking about how I could power a Raspberry Pi off batteries. The [project](/project/mudcam) I have in mind is effectively a wearable video camera, so it has to be as compact as possible and have a good few hours of battery life to be of any practical use. 

## The 5V requirement
What's interesting is that the Pi only requires 5V for USB peripherals and HDMI output to some extent. Otherwise, the board itself has no need for 5V at all. It was merely for convenience of interoperability with the USB and HDMI standards.

According to [Dave Akerman](http://www.daveakerman.com/?page_id=1294), the Pi only powers a handful of components via the 5V that come in from the micro USB port:
 * USB ports (see above)
 * HDMI connector (see above)
 * VSense pin on the BCM2835 MCU (see below)
 * the 3.3V voltage regulator marked as "RG2" on the PCB (see below)

### USB power
The Pi was designed to be a cheap, small, but stationary computer that can interface with standard USB devices. Naturally it was designed around the USB power standards, more specifically USB 2.0 at the time. The micro USB port of the Pi takes in +5V DC via pin 1 and the 0V (ground) on Pin 5. None of the other USB pins are used, as they are for data transfer, and the Pi only uses USB for power.

The range of power the Pi officially can take in is also precisely what USB specifies: between +4.75V and +5.25V. USB 2.0 devices can draw a maximum of 500mA, although there are options on some systems to request more [citation needed]. This is also why if you anything more power hungry than 500mA on a Pi, it's recommended to use a powered USB hub. Otherwise all the devices draw plus the basic draw of the Pi can exceed what is provided through USB alone [citation needed].

So in a nutshell, the Pi is designed to get around 5V and 500mA so that it's compatible with the USB standard.

### HDMI
Another main feature of the Pi that made the designers opt for a 5V power requirement is the HDMI video output. The HDMI standard [requires](http://www.hdmi.org/learningcenter/kb.aspx?c=13) 5V on one of it's lines.

> The HDMI specification requires all source devices to provide at least 55mA (milliamps) on the 5V line for the purpose of reading the EDID of a display.

### VSense pin
This is a special pin on the microcontroller of the Pi. From what I could gather, it has to be kept high so that the MCU knows that there's sufficient voltage for operation. If this has no power, the MCU will not work. For this however, it seems that 3.3V is sufficient and 5V is not really required. [citation needed]

### RG2
Since most of the board works with 3.3V or less, the regulator at "RG2" has the job of stepping down the USB 5V to be 3.3V. The 3.3V that come out of RG2 go into two other regulators, "RG1" and "RG3" - those step the voltage down even more for components that need less than the 3.3V from RG2.

This is where things get very interesting, and I'll get back to RG2 in a moment.

## How much current does a Pi draw?
TODO

### Disable video output to save power
You can disable certain components on the Pi to save some power consumption, most notably the PAL and HDMI outputs (I have yet to find out how to do this in Arch, my prefered distro on the Pi)
    
	# on startup of Raspbian
	# deactivate video output
    /opt/vc/bin/tvservice -off

### Underclock the MCU to save power
From what I heard, underclocking doesn't seem to make a relevant difference so I'll just accept that for now (and I might even dare to overclock a bit later). This is certainly relative to the other power consumers, most notably the quite inefficient voltage regulator at RG2.

### RG2 - the bad guy
RPi rev2 (newer model b's and all model a) have a NCP1117-3V3 primary voltage regulator (rg2, confusingly), which in turn powers two other regulators (rg1 and rg3)

the few other 5v parts on pi (usb, hdmi, vsense pin) are powered directly from the +5V V(in) line from micro USB, which is expected to be stable +5V DC.

the fourth part is rg2, which provides 3.3v to the most important components.

how to power pi from battery? since vanilla pi wants +5V (USB standard min +4.75V; rg2 min ~4.5V;), several options exist:

use higher voltage batteries, and step them down to 5v: for example, 4 AA batteries in series provide ~6V. >1 lipo cell will also need to be stepped down, say 2S (2 cells in series) = 2x3.7V = 7.4V.

stepping down usually done via voltage regulators, linear or switching. switching more configurable and efficient, but more expensive and take a bunch of space. some elaborate engineering going on in the forums about this :-) linear is much simpler but often much less efficient than switching ones, although the efficiency of linear regulators generally increases the closer your input voltage gets to your output voltage. the efficiency correlation is ... linear!

if like me you don't really care about USB and HDMI (headless mode, no wifi or similar) you might wonder why do you need 5V at all? or even the higher voltages above? the energy you provide will be wasted largely anyway (rg2 is linear, so efficiency gets worse the higher the input voltage is). very inefficient for me.

ideally i would be able to supply as close to 3.3V as possible, allowing for sufficient current draw under recording/IO load (VERY rough guess: ~500mA - 1A). a single cell LiPo provides between ~3V(ish) (drained) and ~4.2V (charged). this is assuming lipo has undervoltage protection that cuts off at some point, typically a bit over/under 3V.

so how to use lowe voltage?
step up lower voltage to 5V. this is accomplished using step up/boosters which again are not known to be very efficient in the first place. you can find many examples on the web where people show off their nice pi running of two AA batteries (3V) but generally their battery life will be terrible. cool hack, but not great if you want to run the thing for a few hours. booster efficiency is (from what i gather reading about them...) roughly 70%. So you loose 30% power just pushing power into the Pi. Then that 5V power gets used for stuff you might not even need (usb, hdmi). The rest gets regulated down again into 3.3V by your rg2, again at (best) approx 70% efficiency, losing another 30%. keep in mind, rg2 efficiency can be as bad as 50%. So there goes lots of precious battery life!

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

say we used the MCP1827 with a typical DO of 0.33V. Set to 3.3V output, that's a min of 3.6V input. Remember out typical lipo cell has 3.7 nominal output voltage. it seems hard to get input voltage any closer to the 3.3V we really want to use! you could probably get a bit more life out of your battery when using the 1826 or even 1825, but you'll sacrifice output current as you do. so you really need to understand how much you will be drawing before you can make the best decision here. if in doubt, without HDMI or USB I suspect you can easily go with 1A current, but I'm not fully sure about the 1825 - reports do indicate the pi can run as low as 115mA so it might work, depending on how you utilize the pi. 
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
