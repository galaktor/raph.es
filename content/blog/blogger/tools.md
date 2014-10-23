+++
author = "raph"
date = "2011-11-10T06:29:00+01:00"
draft = false
tags = [ "dotnet", "agile", "rants", "software", "ux" ]
title = "Stop using the wrong tools"
projects = []
series = []
wasblogger = true
aliases = [ "/2011/11/stop-using-wrong-tools.html" ]
+++
When Apple gave us pure touchscreen interfaces, it was as if yet [another](http://screenrant.com/tech-terminator-iron-man-is-here-brusimm-7985/all/1/) science fiction dream came true. Apparently whenever we get a little bit closer to our sci-fi fantasies, we imagine the future will just take the same idea a bit further. "Look ma, no [hands](http://www.ted.com/talks/john_underkoffler_drive_3d_data_with_a_gesture.html)!" Awesome, no doubt. But the danger of small increments is that it feels like progress, even though you could be heading in the wrong direction.

Having robot monkey butlers go skynet on mankind makes great fiction. But could our pursuit of Asimov's smart robots really be distracting us from other, entirely different solutions to our monkey butler needs? Like genetically enhanced apes? Sci-fi inspires authors inspire engineers inspire sci-fi. That chain of inspiration has undoubtedly led to some impressive technological [innovation](http://www.youtube.com/watch?v=Bmglbk_Op64). At which point, though, could recycling century-old inspiration from fiction become a bad thing? When should we dismiss them as bad ideas to instead focus our efforts on alternatives? 

I'm drifting a bit here. The other day I read Bret Victor's [opinion](http://worrydream.com/ABriefRantOnTheFutureOfInteractionDesign/) on a very common vision of how we might interact with technology in the future. He argues that when envisioning the designs of the future, people make small increments to present technology and while doing so, tend to forget about what really makes a tool great.

> "That is, a tool converts what we can *do* into what we *want to do*. A great tool is designed to fit **both** sides."

The touchscreens in modern devices might be closer to what we expect from futuristic high-tech devices. But just because they let us use a mobile web browser more efficiently, does that mean the future will be all chrome and touchscreens? 

{{% fig caption="Everything is chrome in the future!" attrlink="http://www.unitedspongebob.com/" attr="Nickelodeon" %}}
{{% img src="/img/blogger/chrome.jpeg" link="/img/blogger/chrome.jpeg" alt="Squidward dreams of a future where everything is literally chrome" width="300em" %}}
{{% /fig %}}

# Usability is hard
I don't know what the future will bring. What I do know is that people are generally not very good at picking the right tools. And I see no reason why that could not also apply in the future. Revisiting the above definition, there are two things that can go wrong: 1) a tool fails to do "what we want to do", or 2) that "what we can[not] do" prevents us from using the tool properly (or use it at all).

The first one seems obvious. I need to drive a nail into a wall, so I use a hammer, not a wrench. But it's not always that obvious, and we often end up using tools for things they were never intended to do. That's cool if you're aware of the problem and know what you are doing - MacGyver! - but just as foolish otherwise.

The other type of tool abuse is more subtle: failing to bridge the tool's abilities with those of it's user. Buzz word: *usability*. Creating a tool that can do something is the easy part - making it so that people can, will, and repeatedly use it is much harder. Simply put: the most effective tool is not really a tool if nobody uses it.

# Examples I'd like to rant about
As a software engineer, I happen to see wrong-tool-syndrom a lot in - wait for it - software development. There are a few examples in particular that I have noticed recently and I would like to put them here for two reasons. To make my point (duh) and to rant.

## Email chain discussions
The 80's called, they want their mailing lists back! I totally and absolutely *despise* mailing lists. Whenever I need to go to one for help with a tool, I do my best to ditch the tool. They used to have their purpose, nowadays they're just obsolete usability nightmares.

Email is simply the wrong tool for multi-user, text-based conversations. It gets worse with corporate email. It's a nightmare to keep people on/off the receipient list; people get spammed. It's insanely redundant - having to resend the entire past correspondence at the bottom of each message. And once someone hits "Reply" instead of "Reply All", then the discussion gets fragmented and redundancy even increases.

There are [much](http://xmpp.org/extensions/xep-0045.html) [better](http://trac-hacks.org/wiki/DiscussionPlugin) [tools](http://www.coordino.com/) available for online discussions. They were designed to allow for sane reading, backtracking, quoting and searching. And above all, they're much less redundant than when using email.

{{% fig caption="Mailing lists are sooo 80's. And, unlike this here boombox, they *suck*." attr="Wikipedia" attrlink="http://www.wikipedia.org" %}}
{{% img src="/img/blogger/boombox.jpeg" link="/img/blogger/boombox.jpeg" alt="A classic, cool cassette player from the eighties" width="400em" %}}
{{% /fig %}}

## Avoiding OOP features in OOP languages
Modern programming languages have some comfortable features, like just-in-time compilation, sandboxing or garbage collection. Take the .NET runtime. With C# as it's "native" language, it supports polymorphism, i.e. virtual methods.

I have seen people spend significant amounts of time "optimizing" their code to prevent the runtime from having to look for the right method to call in the inheritance chain. They end up with lots of [sealed](http://msdn.microsoft.com/en-us/library/88c54tsw%28v=VS.100%29.aspx) classes which tell the compiler that no other classes may be derived from them. Consequently, the runtime will not need to check for overrides at execution time, thus making the code a few friggaseconds faster. Neat, huh?

Not. My problem with this is not *that* the classes are sealed (even though unit testing them can be a bitch). It is *why* they are sealed. It's not the result of some object-oriented design decision. It's done with the sole purpose to prevent the CLR from doing something it was *designed* to do. C# is object-oriented, so there are virtual methods - deal with it. If you are afraid of the cost, then C# is the wrong tool for your problem - maybe have a look at C/C++ instead.

## Static methods in OOP languages
Within the last 10 years, many programmers have migrated from C++ to C#. I can recognize their (early) code right away: static methods everywhere. That is not object oriented. It's method oriented - *procedural*. There are only very few cases that justify the use of static methods in OOP. You are either using C# for the wrong reasons or you don't understand OOP. Either way, you will not be able to use the tool the way it was designed to be used.

## Videos in (tech) blogs
When I go to your blog, I want to read it - not watch a stupid video. Chances are my mobile browser does not know your codec, and if it does, it still looks like crap. And do you really expect me to turn down my music in order to listen to you say stuff you were too lazy to write down? There's so many things that make videos bad for this: I can't skim over the content like I usually do - instead I end up jumping around in the timeline, buffering, cursing. Fuck your [vlog](http://de.wikipedia.org/wiki/Vlog) or whatever you call it, do a podcast if that's your thing. If you have a blog, I want to *read* it. Period.

## Perforce for version control
"Perforce" and "control" is an contradiction. There you go. I just had to put this one in.

{{% fig caption="Me when I see your vlog" attr="thestupiditburns.com" attrlink="http://www.thestupiditburns.com" %}}
{{% img src="/img/blogger/thestupiditburns.jpeg" link="/img/blogger/thestupiditburns.jpeg" alt="when something is so stupid that makes your head hurt" width="450em" %}}
{{% /fig %}}

# The thin line between a pragmatist and a moron
Now, you cannot always switch tools. Switching language on a gazillion LOC project is not going to happen overnight. Then, at least try to use the tools you have the way the were designed to be used. Make the most of what you have, and don't try to bastardize it just because you are too lazy to use it the right way. 

What I really hate is that engineers that abuse a tool beyond recognition are often admired. Yes, it's great to be able to improvise when required - but it's far more important to be able to [decide](http://www.engineyard.com/blog/2011/the-number-one-trait-of-a-great-developer/) what the right tool for the job/situation/user is. A construction worker that uses a screwdriver to punch holes into walls instead of using a drill will not be considered creative, but a moron. Why do the opposite in software?
