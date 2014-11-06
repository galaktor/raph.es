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

# Minimizing current draw
The less current the Pi draws, the smaller my batteries can be and the longer they can last. The amount of current a Raspberry Pi will draw depends on a few factors. Here's some tricks I collected to reduce current draw to a minimum.

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

## Disable video output
You can disable certain components on the Pi to save some power consumption, most notably the video outputs. Here's what I found on the web for the default Raspbian distro:
    
	# on startup of Raspbian
	# deactivate video output
    /opt/vc/bin/tvservice -off

I believe it's the same in Arch, my preferred distro - not only for the Pi. I've yet to test this.

It is not clear to me how much this will save. The HDMI spec indicated up to 55mA draw. How much this actually is without a TV connected, I cannot say. I suspect that this will have very little effect on power consumption.

## Underclocking
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

# Going below 5V
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

This is where things get very interesting.

Revistion 2 boards (i.e. newer model Bs and all model As) have a `NCP1117-3V3` primary voltage regulator at `RG2`. It, in turn, powers two other regulators `RG1` and `RG3`. The stuff I care about all takes power from this guy.

The problem with RG2 is, it was chosen to fit the typical conditions for the Pi: regulated +5V DC. The NCP1117 has a drop out voltage of over 1.2V. This means the difference between it's input and output voltage has to be at least 1.2V. If the voltage is lower than the DO, the regulator will stop working. No power downstream means, well, no power for your Pi.

We know the output of RG2 is 3.3V. So the minimum input voltage after the fuse has to be *at least* 4.5V. This is a problem if you're trying to run on batteries. Most affordable batteries have lower voltages than 5V.


# How other people do it
I've seen people work around the issue of `RG2`'s voltage limitations in two ways.

## Use higher voltage
Take higher voltage batteries - like the ones used for RC cars - and step down the voltage five volts. For example, 4 AA batteries in series provide ~6V. More than one LiPo cell will also need to be stepped down, say 2S (2 cells in series) = 2x3.7V = 7.4V. Linear is much simpler but can be less efficient than switching ones. The efficiency of linear regulators generally increases the closer your input voltage gets to your output voltage. The efficiency correlation is ... *linear*! So the closer your input is to your output, the more attractive the simple linear regulators start to look.

The trade-off here is that while it works, you're wasting energy as you step it down to 5V - just so RG2 can step it down more. In both cases, the difference is lost as heat.

## Step up lower voltage batteries
You can go the other way, too. By taking lower voltage - like from a few AA batteries - and stepping it *up* to 5V. Again, it's not super efficient especially if you consider that you're only stepping it up so it can be regulated down again in `RG2`.

Stepping down usually done via voltage regulators, which come in two flavours: *linear* or *switching*. Switching is more configurable and efficient, but cost more and use up loads of space. You can find many examples on the web where people show off their nice Pi running of two AA batteries (3V) but generally their battery life will be terrible. Cool hack, but not great if you want to run the thing for a few hours.

Booster efficiencies seem to be somewhere around 70%, so you loose 30% power just pushing power into the Pi. Then that 5V power gets used for stuff you might not even need (usb, hdmi). The rest gets regulated down further to 3.3V by your `RG2`, again at (best) approximately 70% efficiency - losing another 30%.

## Replace RG2 with lower DO
A rather advanced solution is to address the problem directly by removing `RG2` and putting a more efficient regulator in it's place. Even though he `NCP1117` is labelled *low-dropout*, there's others that have a much lower DO than 1.2V. The idea being that the lower voltage your regulator will continue to deliver it's output of 3.3V, the longer it will be able to run off batteries as they gradually drop voltage.

Dave Akerman [shows](http://www.daveakerman.com/?page_id=1294) how to replace `RG2` with an `MCP1825S` regulator. It has a DO of afound 300mV, depending on temperature and current draw.

This approach is very appealing to me, even if it means modding the Pi and potentially damaging it. It means I can take a farily cheap component, solder it on relatively easy and the result doesn't have any large parts or wires sticking out in the end (as might be the case with a switching regulator).

# Conclusion
I just want to use a Pi board and cam module. No USB devices, no video output. I'll try to supply as close to 3.3V as possible, allowing for sufficient current draw under recording/IO load (rough guess: around 500mA). A single cell LiPo provides between 3V and 4.2V. This is assuming lipo has undervoltage protection that cuts off at some point, typically a bit over/under 3V.

I'll try replacing `RG2` with an LDO that has a drop out in the mV range, which should allow me to get the most out of the LiPo. Maybe I can stick the LiPo directly to the USB power of the Pi.

So that's the theory. I'll need to measure actual current requirements running the camera. And decide which regulator to use as a replacement for `RG2`. Then order a nice LiPo that can fit into my space requirements. I saw some phone and tablet LiPo's which could give a few hours of running time if all goes well.

# Resources
* [Dave Akerman on battery life and voltage regulators]( http://www.daveakerman.com/?page_id=1294)
* [Peter Vis: Pi power](http://www.petervis.com/Raspberry_PI/Raspberry_PI_Power_Supply/Raspberry_PI_Micro_USB_B_Specification.html)
* [Peter Vis: RG2](http://www.petervis.com/Raspberry_PI/dead-raspberry-pi/dead-raspberry-pi.html)
* [RG2 datasheet]( http://www.onsemi.com/pub_link/Collateral/NCP1117-D.PDF)
* [MCP1825](http://www.microchip.com/wwwproducts/Devices.aspx?product=MCP1825)
* [MCP1826](http://www.microchip.com/wwwproducts/Devices.aspx?product=MCP1826)
* [MCP1827](http://www.microchip.com/wwwproducts/Devices.aspx?product=MCP1827)
* [LiPo guide (Sparkfun)](https://learn.sparkfun.com/tutorials/battery-technologies/lithium-polymer)
* [LiPo guide (RC cars)]( http://www.rogershobbycenter.com/lipoguide/)
