+++
author = "raph"
date = "2014-10-20T07:55:43+01:00"
projects = [ "mudcam" ]
series = [ "battery pi" ]
tags = [ "raspberry pi", "power", "hardware", "usb" ]
title = "Custom lipo-to-usb connector"
slug = "lipo-battery-to-micro-usb-power-adapter"
draft = true
+++
be as little invasive as possible. go through intended power route, including fuse protection.




I could take a male micro-usb connector, and attach a JST plug or similar for battery to go into the USB D+ and D- pins. This would feed battery directly into the pi.
PROBLEM: built in regulator has a drop out voltage of at least 0.9V, with 1A current draw it will be around 1.1V, up to even 1.2V. That means the difference between output (3.3V) and it's input has to be at least 1.1V realistically. that's 3.3V + 1.1V = 4.4V. the specs say min is 4.75V, i suppose to not be to close to the edge given variance in parts and power stability.



So the regulator will not do anything if voltage is below 4.4V - and a single cell lipo will AT BEST (for a brief period of time) provide about 4.2V. most of the time 3.7V. NOT GOING TO WORK!
