+++
author = "raph"
date = "2014-10-20T22:09:02+01:00"
projects = [ "mudcam" ]
publishdate = "2014-10-20T00:00:00+01:00"
series = [ "battery pi" ]
tags = [ "raspberry pi", "power", "hardware" ]
title = "bypassing the main raspberry pi fuse f3"
slug = "bypass-raspberry-pi-fuse-f3"
draft = true
+++
voltage drop of 140mV. want to max battery usage. voltage from lipo never over 5v, and current draw minimal since no usb peripherals and only low-v camera


bypassing fuse doesn't seem to make massive difference...will go with usb for now. pass f3 still an option. must benchmark first


Voltage drop seems related to additional current draw by SD Card. Fuse is sensitive to additional draw, and limits voltage as a response.
