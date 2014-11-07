+++
author = "raph"
date = "2014-11-07T07:58:47Z"
draft = true
projects = []
series = []
tags = []
title = "website version nr"

+++
Since this website is deployed via pushing to git, I wanted a way to see which version it was that was currently rendered at any given time. The deployment to github pages happens on Travis, which means there's a delay between me pushing a change and the HTML updating. Additionally, client side caching could cause the HTML shown to be older even if the content on the server was already updated.

In order to have a version number displayed on the page, I first had to decide what *exactly* it was I want versioned. The entire page is obviously in git. A version of any given page would be overkill. What I wanted was the revision of the entire website.

Having the website output deployed into a separate git repository means it has a separate history from the source code I actively work in. A single `commit` to my source code can be a trivial tiny change, so individual commits don't mean much there. But only when I `push` my changes will there be a new HTML build. This is what I want to track as a new *revision*.

# Lines of log
The command `git log` dumps the entire history of a repository into the console.

    $> git log
    commit d9ca75c82886a1705a9f8741f4ee6b6f4fa3e7e8
    Author: galaktor <travis@localhost.localdomain>
    Date:   Thu Nov 6 11:07:16 2014 +0000
    
        rebuilding site Thu Nov  6 11:07:16 UTC 2014
    
    commit dd02dc23d4fdf7ca9e9171f983644fee1dcf768d
    Author: galaktor <travis@localhost.localdomain>
    Date:   Thu Nov 6 11:06:22 2014 +0000
    
        rebuilding site Thu Nov  6 11:06:22 UTC 2014
    
    commit b9ac0d9640c692e45b7d23ec183dee606a4b751e
    Author: galaktor <travis@localhost.localdomain>
    Date:   Wed Nov 5 20:00:45 2014 +0000
    
        rebuilding site Wed Nov  5 20:00:45 UTC 2014
    <etc>

By adding the switch `--oneline`, git formats it neatly into individual lines. That way I get a line for every build of the website.

    $> git log --oneline
	d9ca75c rebuilding site Thu Nov  6 11:07:16 UTC 2014
    dd02dc2 rebuilding site Thu Nov  6 11:06:22 UTC 2014
    b9ac0d9 rebuilding site Wed Nov  5 20:00:45 UTC 2014
    7d12d25 rebuilding site Wed Nov  5 19:52:31 UTC 2014
	<etc>


By counting the number of lines I can get an incrementing integer number representing the amount of pushes I have made for the page. `wc` can be used to count words, and using the `-l` switch, lines.

    $> git log --oneline | wc -l
	15

`15` is what I wanted. It's the amount of pushes to the websites output repository. It shows how often it was updated. When I release a new version by pushing my sources, travis rebuilds and increments the number.

# TODO: updatingn the partial in hugo
