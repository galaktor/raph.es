---
ascii: "ascii/radio.txt"
author: "raph"
date: "2014-01-05T19:30:28+01:00"
progress: 80
project: "gorf"
state: "frontend"
title: "gorf"
---
As part of the [wireless gamepad](/project/gamepad) project, I wrote middleware to allow control the Nordic NRF24L01+ transceivers in Linux. This is the side that will be receiving key presses from the gamepad, which has an Arduino inside - there already exists useful [Arduino libraries for this radio](https://github.com/maniacbug/RF24).

* [gorf24](https://github.com/galaktor/gorf24)

# v1: Simple port for POC
What's on the [master](https://github.com/galaktor/gorf24/tree/master) branch is a fairly straightforward port of the Arduino library. I used this for my proof-of-concept. 

# v2: Custom driver from scratch
Later, on the [port]https://github.com/galaktor/gorf24/tree/port) branch, I began writing my own user-space driver from scratch, bit-banging the Linux SPI drivers on the [Retro-Pie](project/retro-pi/).

I tried to use idiomatic Golang and find a nice abstraction of the radio's functions. The final (last) combining facade ([rf24.go](https://github.com/galaktor/gorf24/blob/port/rf24.go))is lacking some design decisions for the whole thing to come together. However, all the underlying logic is well-covered by in-memory unit tests, so I'm confident that it implements the Nordic specifications.

Too bad the final thing doesn't work yet! \_(ツ)_/¯

That said, this was a clear case where using TDD for low-level logic was a blessing - the bulk of the code is tested even though the usability questions aren't decided yet. Very little risk in the final steps. Not that anybody cares.
