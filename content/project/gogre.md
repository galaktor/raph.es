---
ascii: "ascii/cube.txt"
author: "raph"
date: "2012-10-04T20:38:52+01:00"
progress: 20
project: "gogre3d"
state: "prototype"
title: "gogre3d"
---
[Ogre 3D](http://www.ogre3d.org/) is mature, open-source graphics engine for interactive applications and games. I ilke to play with it occasionally - and at one point wanted to try Golang for making a game. Not many libraries were around for this at the time, so I attempted to make an Ogre wrapper in Go.

Since Go has rather neat C-bindings, it made sense to first abstract the C++ Ogre code via a C layer, then bind that into a Go library via cgo.

* [llcoi](https://bitbucket.org/galaktor/llcoi): Low-Level C Ogre Interface
* [gogre3d](https://github.com/galaktor/gogre3d): Golang bindings to llcoi

The Ogre community never sleeps, but I've discontinued my efforts on this front. So chances are, someone forked and continued without me; I haven't checked yet.

