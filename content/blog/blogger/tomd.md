+++
author = "raph"
date = "2011-07-15T13:18:00+01:00"
draft = false
tags = [ "teamcity", "tests", "rants" ]
projects = []
title = "The Test of Mass Destruction"
wasblogger = true
aliases = [ "/2011/07/test-of-mass-destruction.html" ]
+++
The below is the log of a chat I had a while back with a colleague (you know who you are). I had just set up a fresh TeamCity build for his new project. This was a bit exciting for me since I am constantly encouraging developers to write tests for their code, *new code* in particular. After I had kicked off a first build, a very..."special" test appeared to be "hanging"...

    [me], 10:02:36:
    looks like some tests are taking ages to finish
    
    [me], 10:02:48:
    i might have to annoy you about that
    
    [you know who you are], 10:04:55:
    there are very few tests in there and they run instantly on mine...
    
    [me], 10:05:26:
    that's why we also run them on other machines :-)
    i'll wait till they're through then we can find out whats going on
    
    [you know who you are], 10:06:19:
    ah i can see whats wrong now
    
    [me], 10:06:45:
    missing dependency or something?
    
    [you know who you are], 10:11:09:
    an old broken test, deleted from visual studio but not removed from perforce
    
    [you know who you are], 10:12:36:
    you can kill it if you want
    
    [me], 10:16:32:
    i would - but viewing the logs of that build killed my machine :-D
    
    [me], 10:16:40:
    i shit you not
    
    [you know who you are], 10:16:52:
    it killed my chrome too
    
    [me], 10:17:05:
    that's one cool test
    
    [you know who you are], 10:17:22:
    it was a test i was running on my machine to get some idea of msmq inserts over time
    
    [you know who you are], 10:17:40:
    its trying to do 10 million msmq inserts to see how fast it runs
    
    [me], 10:17:47:
    OMFG
    
    [me], 10:17:50:
    are you nuts :-D
    
    [you know who you are], 10:17:51:
    so its probably going to generate 10 million exceptions
    
    [you know who you are], 10:17:54:
    lol
    
    [me], 10:17:59:
    that's going to take down the build server
    
    [me], 10:18:03:
    stop that build asap pls
    
    [you know who you are], 10:18:12:
    you started it, how do i stop it?

Yes, viewing the logs for that build did in fact crash one of my dev machines. Or it rather destroyed Firefox, which in turn killed my machine. A true *Test of Mass Destruction&trade;*. We eventually got the test to stop and removed it. But what do we learn from this?

# Know what you're doing
First of all, always know what you are submitting to source control. Always, as in 100%. Diff all files if necessary and understand what's in them - I know from personal experience that many developers do not understand most of what is inside [Visual Studio project and solution files](http://www.galaktor.net/2011/04/targeting-platforms-in-visual-studio.html), for example. Understand it - you are changing it, and you are an engineer, so learn it if you don't know what it is. Many developers think having a build server means not having to run stuff on your local machine anymore. That is wrong. The build server is a last line of defense in that matter, but if you break shared code you are hurting the productivity of other developers. If you make sure it [works on your machine](http://www.codinghorror.com/blog/2007/03/the-works-on-my-machine-certification-program.html) first, then nobody will notice that you screwed up and you are able to fix the problem before you switched to something else. If a build engineer has to call you up an hour later, you will probably need some time to retrace your steps to understand what's wrong. Do it early, save yourself and others the pain.

{{% fig %}}
{{% img src="/img/blogger/womm-label.png" alt="that's why we also run them on *other* machines -me" link="/img/blogger/womm-label.png" width="200em" %}}
{{% /fig %}}

# Know how to do it properly 
Second, master your tools. In this particular case it was a problem most of us have because we are *forced* to use per*force* (bad pun fully [intended](http://lmgtfy.com/?q=i+hate+perforce)). Perforce might have a few good features on the server and support side, but the client tools for Windows developers are way below standard. Because Perforce clients do not actively monitor your changes on the client side, the server relies on the client to tell it about any add/edit/delete/whatever explicitly. This means if you delete a file from your working directory, it does not automatically mean the client will detect that and submit a "delete" to the server. Instead, it stays there. Just like this test. *But*: Just having crappy tools is not an excuse for breaking stuff. There are [ways](http://www.jetbrains.com/teamcity/features/delayed_commit.html) to contain the damage you can cause. So either stop using the tool or learn how to deal with it.

# Do it as simple as possible
Finally, this test was designed to be dangerous. Why did it have to do something 10 *million* times? Why not 100,000? Or 100? This was supposed to measure performance, so quite a large batch of iterations is a valid thing to do. But more often than not I find developers doing this when it is not necessary. "Just to be safe" or "thorough" or "because we can" (it's automated, isn't it?). Most of the time tests are fine with just one (=1) single test case. That's why in [TDD](http://en.wikipedia.org/wiki/Test-driven_development) a test needs to break first, otherwise it's not worth executing it, yet alone implementing the new feature. If you are just tacking on several variants of the same test, testing the same logic/feature over and over, you are wasting screen space, your time and everyone else's time when they have to run and, most of all, *maintain* your tests.
