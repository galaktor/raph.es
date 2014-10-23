+++
author = "raph"
date = "2012-05-09T08:44:00+01:00"
draft = false
tags = [ "foss", "ux", "software" ]
title = "The blog gets some love"
projects = []
series = []
wasblogger = true
aliases = [ "/2012/05/blog-gets-some-love.html" ]
+++
**Note: this post was hosted on Blogger at the time of writing. Links in this post are old and could be broken.**

I took a wee bit of time to upgrade this site a bit. Not exactly a huge project worth bragging about, but I figured I'd highlight the changes (if they're not already obvious enough).

# Dynamic Template
I switched over to use the shiny "new" blog templates that Blogger provides. I resisted the urge for a while but I do think it gives the site a more modern feel. Surely far from perfect, but given that it came for free I think value for money is good.

Going back to black-on-white was not an easy decision because I'm a huge fan of light-on-dark themes. Despite the new color scheme being quite uninspired and more mainstream, it is an improvement in terms of usability. Currently it's almost entirely the vanilla Blogger template, I'll experiment with it going forward.

The interface is much less cluttered with "gadgets" now, they're hidden behind the sidebar on the right - something which I think is good for readability.

You can select different "dynamic views" over on the left of the main menu bar - most of them don't work well with this type of blog, exceptions being maybe "classic" and "sidebar", the latter which I have set to be the default. Google won't allow me to lock it down to just that view, so I guess that means you can switch them as you see fit - but be warned, they mostly suck.

{{% fig caption="Blogger's dynamic views crop images with awkward results" %}}
{{% img src="/img/blogger/dynamic_my_ass.jpeg" link="/img/blogger/dynamic_my_ass.jpeg" alt="Assembly gets cropped to *Ass*" width="500em" %}}
{{% /fig %}}

From an authors point of view, the most notable new feature is that the "preview" now presents an interactive version of the site. I like to test the likes of links and images *before* going live, something that just was not possible with the old template, which resembled more a photo of your site rather than a real website. 

Another nice gimmick is that Blogger finally got a sane "share" menu at the bottom of each post - featuring the actual number of tweets (was not there before) and ditching a bunch of who-gives-a-shit social networks (but obviously still hanging on to g+). Notice how there's even a Facebook "like" button - then again, I really consider that a bug, not a feature.

{{% fig caption="Social networks in order of importance - according to Google" %}}
{{% img src="/img/blogger/fake_shares.jpeg" link="/img/blogger/fake_shares.jpeg" alt="Google plus gets listed before Twitter and Facebook" width="500em" %}}
{{% /fig %}}

# New "code" section
I've always been eyeballing [github](https://github.com/) as a place where I can potentially dump some side projects of mine and possibly some of the larger code snippets and scripts from this site. But being the cheapskate that I am, I never liked that fact that github never offered a free plan for hosting code - even if it meant limitations to the number of repositories or something like that.

[Bitbucket](https://bitbucket.org/) on the other hand does have a [free plan](https://bitbucket.org/plans), and the only real limitation is the number of users per private repository. I'm making most of my projects public anyway, so that doesn't really matter to me. Otherwise you get unlimited private and public repositories. Bitbucket is arguably not as shiny as github, but it does exactly what I need and that for free, so there you go.

Many of my projects were already hosted elsewhere and lived in Mercurial repositories, so the fact that Bitbucket now supports both hg *and* git means I don't have to migrate my old projects and can move over to git on newer projects. Importing from other hosting sites was perfectly smooth.

Bitbucket makes it [very easy](http://confluence.atlassian.com/display/BITBUCKET/Using+your+Own+bitbucket+Domain+Name) to point a CNAME to your profile, so now [code.galaktor.net](http://code.galaktor.net/) goes straight to the repository list. That's exactly where you end up if you hit the new "code" button in the main menu. Keep in mind that all I did so far was import a few old-ish projects. I intend to give them some TLC and add more in the near future.

{{% fig caption="Blogger's stupid drop-down and the new 'code' menu item" %}}
{{% img src="/img/blogger/new_menu_bar.jpeg" link="/img/blogger/new_menu_bar.jpeg" width="450em" %}}
{{% /fig %}}

# Free beer
So Google is under pressure to make blogs look nicer next to Tumblr, Wordpress and the likes, and as the ~~product~~ user I get a new (mostly) nice template for free. As the [classic open source analogy](http://en.wikipedia.org/wiki/Gratis_versus_libre) goes, we're talking "free as in beer", not "free as in speech" - with the obvious downside that I cannot really change some of the things even if I don't want or like them. The "dynamic view" selector in the main menu being one example. There may be some trickery that can be done by fiddling with the HTML, but as it is it seems that they're at least trying to force it upon me (and you).

Same thing for Bitbucket - it's not perfect, and there's not much I can do about that aside from suggesting improvements to Altassian. Still, it costs me nothing, was simple to set up and does what I want, so who am I to complain?

The geek in me would prefer to host my own blog on my own server with my own geeky engine and templates, but reality is I just don't have much time available to tend this blog. As a matter of fact I'm happy if I get time to write or code stuff *at all*. So the fact that there are free, if imperfect services that allow me to focus on getting shit done, I'm happy. For now.
