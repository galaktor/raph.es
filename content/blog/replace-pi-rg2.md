+++
author = "raph"
date = "2014-10-18T20:11:00+01:00"
projects = [ "mudcam" ]
series = [ "battery pi" ]
tags = [ "raspberry pi", "power", "hardware" ]
title = "replace pi rg2"
slug = "replace-raspberry-pi-voltage-regulator-rg2"
draft = true
+++
When I connect up the power to the Pi, it seems to turn on just fine. An SD card running Arch for ARM is in. Hooking up my multimeter probes to the test points `TP1` (+) and `TP2` (-), this is what I get:

* at battery: 3.71v
* at test points: 3.62v
* at `RG2` *in*: 3.62v
* at `RG2` *out*: 2.68v

Knowing that the vanilla regulator at `RG2` has a DO of about 1V or more, I'm not surprised that it's not able to provide good 3.3V anymore given the low voltage from the LiPo.

The Pi seems to be running well enough, but I haven't tried doing anything interesting with it yet. The fact that all components which expect to get 3.3V are now on less than 3V means things won't run reliably. And as battery voltage drops, behaviour is unpredictable. Not great conditions for a project that I want to run stable for hours.

So having seen this, I'm going to have to remove `RG2` and replace it with a voltage regulator that has a lower DO.



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
