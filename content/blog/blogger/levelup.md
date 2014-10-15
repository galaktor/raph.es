+++
author = "raph"
date = "2012-02-26T21:16:00+01:00"
draft = false
tags = [ "foss", "linux", "windows", "software" ]
title = "Yet another attempt to level up my geek-iness"
projects = []
series = []
wasblogger = true
aliases = [ "/2012/02/yet-another-attempt-at-levelling-up-my.html" ]
+++
I've been rather quiet over the past months and I'm sure the *entire* blogosphere was shocked and wants to know why. Well, in addition to holidays and the likes, for the probably 4th time in the past 15 years I am attempting to move my computing life from Windows into Linux. And since I rarely have much time for my geeky side projects, I have been dedicating it to that rather than the blog.

As just mentioned I tried this a few times before, but eventually failed. First time around I failed to even get my CD-ROM drive mounted in SuSe. Later on Ubuntu I lacked a few critical tools for my studies, like OneNote (which is brilliant) or VisualStudio for my thesis project. And Call of Duty.

# What's different now? 
I learned two things that I hope to get right this time.

One is that I need to move most, if not *all* my computing tasks into just one OS. Anything else will cause too much friction workflow-wise and I'll eventually get stuck on Windows again.

The other lesson was that Windows is simply best for two things I care somewhat about: .NET development and gaming. And since neither of these play well inside a VM I'll need to dual-boot. The good thing (in this context) is that these two points have become less important to me over the last years. I do .NET in my day job, so I rarely feel the need to continue at home.

And as much as it hurts to admit: I've outgrown my [hardcore gamer phase](http://www.techradar.com/news/gaming/consoles/11-signs-you-re-no-longer-a-hard-core-gamer-329291). Gaming is now something I do on a work-less, shave-less, spongebob-boxer-shorts days. But I'm determined to finish all those games I bought during the last few X-mas sales on Steam! I suppose that puts me into some form of mid-life crisis? Scary, how gaming was close to the center of my life at a time when I couldn't really afford the games I wanted. Now I have enough "allowance", but barely any time left to play games. Oh, the irony.

Anyhow, at the end of the day, I can now probably live with booting up Windows for these things as they are rather rare events.

# Stick with Windows, idiot! 
Why Linux at all then, you might ask? Well first of all I have been doing professional .NET development for over 7 years now (albeit not exclusively) and feel very comfortable in Windows, VS and the likes. But feeling too comfortable is a bad sign, it means not learning very much. So while .NET will stay a good way to do cool stuff and earn a nice living, I feel the nerdy (read: masochist) urge to leave the comfort zone and learn new things. You know, things that make me feel like a first-grader again. That make me yell curses at the screen. That make me feel like a god after I do get them working.

Plus, and this is a big one: I think [Free Software](http://www.fsf.org/) is important. In a time where most of our daily life depends on computers that sit in virtually everybody's pocket, I believe it's important to have as much control over them as possible. Linux not only gives you very much that control, it's also arguably the best operating system out there. Many distros nowadays work out-of-the-box with WiFi and all the gimmicks. So really I see no reason why I should have to force my life into a proprietary operating system while I can get a better, more flexible and *free* one for...well, free.

# #! 
So what I did was upgrade my good old [M1530](http://reviews.cnet.com/Dell_XPS_M1530/4505-3121_7-32778979.html)'s RAM, back up my files....and do other things so boring that just writing about them makes me narcoleptic. So pardon me if I skip to the good parts. I stuck roughly to [this](http://www.iceflatline.com/2011/05/install-and-configure-crunchbang-linux-on-the-lenovo-t410-laptop/) excellent tutorial, which served me as a guideline although I did deviate a bit.

I installed Windows 7 as a primary OS using about 50% of the HDD, and then [Crunchbang](http://crunchbanglinux.org/) into dedicated partitions using the rest. Crunchbang is a minimalistic yet fully featured distro based on Debian Squeeze. I let the boot loader Grub2 install itself at the beginning of the disk. In CB I had to run the command `update-grub` so that the OS-prober could auto-detect Windows, then that was sorted.

While I'm moving into the brave new world of WTF'ing on Linux I will post about things I have learned along the way. One is the ability to use several window managers and select them at the login screen. The default on CB is [Openbox](http://openbox.org/), and it's great, but I'd like a mouse-less window manager for coding. Thus coming soon are my notes on how to get Openbox and [Ratpoison](http://www.nongnu.org/ratpoison/) to co-exist. (This is also a prime example of why proprietary software can lock you down - there's no nice way to change your window management on Windows. On Linux, if it doesn't exist, you can always roll your own.)

And yes, there will still be Windows/.NET related posts in the future - we'll have to wait and see how *this* attempt at Linux will work out for me.
