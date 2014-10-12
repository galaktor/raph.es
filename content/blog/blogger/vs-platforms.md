+++
author = "raph"
date = "2011-04-12T19:16:00+01:00"
draft = false
tags = [ "dotnet", "visual studio", "software", "builds" ]
projects = []
title = "Targeting Platforms in Visual Studio"
wasblogger = true
aliases = [ "/2011/04/targeting-platforms-in-visual-studio.html" ]
+++
None of Visual Studio's features is more essential than compiling text to binary assemblies - in VS terminology: "building". Since this is the single most important task you use an IDE for, it is crucial that you understand how it works if you want to have more control over what you build, and especially for what target platform - e.g. when automating your builds for continuous integration.

# Configuration != Configuration

{{% pic src="/img/blogger/configuration_platform_selector.png" caption="Solution configuration (left) and solution platform (right)" link="/img/blogger/configuration_platform_selector.png" width="300em" %}}

The *solution configuration* and *solution platform* selectors are two of the most used and at the same time most misunderstood UI elements in Visual Studio. You would think that they allowed you to define with which configuration and for which target platform your code will be compiled. What users *expect* is this:

    SLN config + SLN platform => Binary

Unfortunately, it is not that simple. There is a chain of five independent variables that define how a single project in your solution will be compiled. The solution configuration/platform settings from the VS toolbar are the first two. As a pair, they determine which project configuration and platform settings will be used to build a project. Those two then eventually define which *platform target* the compiler will use to eventually create your assembly. Change any of those variables and you can end up with an entirely different value for "platform target" when building your solution. So in reality, your chain of platform configuration looks like this:

    SLN config + SLN platform => PROJ config + PROJ platform => PROJ platform target => Binary

I will attempt to shed some light on the different parts of this chain and present a way - well, *my* way - of dealing with it's complexity in order to regain control of this process. I am going to roll up this chain from the end.

# Project configurations
A project in Visual Studio represents a binary that will be generated after compilation. As you would expect, the *project settings* window allows you to define [various options](http://msdn.microsoft.com/en-us/library/0hkyezwy%28v=VS.100%29.aspx) around that binary - most notably where the file will be copied to, if the compiler will optimize the generated IL (i.e. in Release mode) and what platform architecture you are targeting. Those settings are stored in a *project file*.

{{% pic src="/img/blogger/project_settings.png" caption="The *project settings* window. Be aware that *Platform* != *Platform target*... o_O" link="/img/blogger/project_settings.png" width="300em" %}}

Project files are essentially just [XML(ish) input files](http://msdn.microsoft.com/en-us/library/5dy88c2e.aspx) for a tool called [MSBuild](http://msdn.microsoft.com/en-us/library/wea2sca5%28v=vs.90%29.aspx). It is Microsoft's build tool, logically very similar to [NAnt](http://nant.sourceforge.net/) and [the likes](http://en.wikipedia.org/wiki/Build_automation). As a matter of fact, [Visual Studio uses MSBuild behind the scenes](http://msdn.microsoft.com/en-us/library/ms171468%28v=VS.100%29.aspx) whenever you hit "build" in the IDE. 

If you open a project file in your favorite text editor you will find a list of [`PropertyGroup`](http://msdn.microsoft.com/en-us/library/t4w159bs.aspx) elements representing your project's build configurations. Each has an attribute [`Condition`](http://msdn.microsoft.com/en-us/library/7szfhaft.aspx) that serves as an identifier for a group of project-related settings. The unique key used as a condition usually consists of two values: *configuration* and *platform*, e.g. `Debug|x86`. In that PropertyGroup element you may find a child called `PlatformTarget`.

    <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Release|AnyCPU'">
        <DebugType>pdbonly</DebugType>
        <Optimize>true</Optimize>
        <OutputPath>bin\release</OutputPath>
        <DefineConstants>TRACE</DefineConstants>
        <ErrorReport>prompt</ErrorReport>
        <WarningLevel>4</WarningLevel> 
    </PropertyGroup>
    <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|x86'">
        <DebugSymbols>true</DebugSymbols>
        <OutputPath>bin\x86\debug\</OutputPath>
        <DefineConstants>DEBUG;TRACE</DefineConstants>
        <DebugType>full</DebugType>
        <PlatformTarget>x86</PlatformTarget>
        <ErrorReport>prompt</ErrorReport>
    </PropertyGroup>

The value in `PlatformTarget` is what the compiler *actually* uses to determine which platform your assembly will be generated for. This gives us the simplest and most direct part of the configuration chain:

    PROJ platform target => Binary

The condition on the `PropertyGroup` element has to evaluate to `true` in order for that `PlatformTarget` value to be used. They are simple string parameters that get passed into MSBuild as parameters. In the configuration chain, it looks like this:

    PROJ config + PROJ platform => PROJ platform target => Binary
	
You can build a project file with MSBuild using the [Visual Studio command prompt](http://msdn.microsoft.com/en-us/library/ms229859.aspx). Alternatively you can call MSBuild directly (for .NET 4 typically `C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe`). MSBuild takes parameters to determine which configuration and platform it will use, eventually reading one of those PropertyGroup elements and then doing it's magic. 

    $> MSBuild "MyProject.csproj" /p:Configuration="Release" /p:Platform="Any CPU"

# Solution configurations
Solution configurations are a different story. While projects are directly related to binaries of your generated application, a solution is not. It is a mere container for projects. And yet, it too has a "configuration" and a "platform" setting. You can use MSBuild with the same parameters to build a solution, like you would do with a project. How does this make sense?

A solution is a "meta-project", and it's configuration and platform settings can be described as "meta-settings". Visual Studio uses them to tell MSBuild which parameters to use when building each *project* within it. The solution holds a list of projects' `Active Configuration` for each possible combination of solution configuration and solution platform (there's other stuf in there as well, but let's ignore that for now). Whatever combination of *solution* configuration and platform you set, that becomes the active configuration, and MSBuild needs to know which *project* configuration and solution those map to - for each and every project. That gives us A x B x C active configurations where A: number of projects, B: number of solution configurations and C: number or solution platforms.

    {74482536-2654-4B15-B457-9425A05341E6}.Debug|Any CPU.ActiveCfg = Debug|Any CPU 
    {74482536-2654-4B15-B457-9425A05341E6}.Debug|Mixed Platforms.ActiveCfg = Debug|Any CPU 
    {74482536-2654-4B15-B457-9425A05341E6}.Debug|x86.ActiveCfg = Debug|Any CPU 
    {74482536-2654-4B15-B457-9425A05341E6}.Release|Any CPU.ActiveCfg = Release|Any CPU 
    {74482536-2654-4B15-B457-9425A05341E6}.Release|Mixed Platforms.ActiveCfg = Release|Any CPU 
    {74482536-2654-4B15-B457-9425A05341E6}.Release|x86.ActiveCfg = Release|Any CPU

That completes our configuration chain from earlier, which for the record now looks like this again:

    SLN config + SLN platform => PROJ config + PROJ platform => PROJ platform platform => Binary

# The Scary Part
It is important to understand that the relationship between solution settings and project settings is not as direct as it may seem. Setting the solution to `Release|x64` does not necessarily mean you are switching each project to exactly that setting. Visual Studio will constantly keep track of how you configure the project settings and associate them with the currently selected solution settings. VS will update the active configuration accordingly whenever a project's configuration or target platform is modified. Whenever you switch your active configuration, and then make a change to a project's settings, VS stores those as that project's active configuration in the solution file. It is easy to forget that and to unintentionally submit the change into source control.

Now picture a team of developers, unaware of all this, working in the same solution. Adding new projects, modifying project settings - every once in a while switching platforms. After some time, maybe many months (and many VCS submits) that list of active configurations in the solution file will grow into a mess. The end result is a random mix of assemblies with different architectures. 

If someone builds the solution as `Release|Any` CPU she might end up having a wild mix of *x86*, *x64* and other types of assemblies in the resulting binaries. The user's intention of building a solution as **Any** CPU is not "I don't care what comes out on the other end". It means "I want all assemblies to be compiled as `Any CPU`, with all advantages and disadvantages". A very big difference!

It might not show right away when you have a "friendly" mix of compatible architectures and a little bit of luck, e.g. `AnyCPU` and `x86` running on a 32bit machine - intended or not, that might go unnoticed most of the time. But as soon as you start mixing incompatible assemblies, you app will go boom at run-time. But sudden death is not the worst thing that can happen; Depending on your code and dependencies, more subtle side-effects can creep in - posing a much bigger threat, since you then have production code running in an unpredictable state. 

    BadImageFormatException: An attempt was made to load a program with an incorrect format.

# The Principle of Least Surprise
Have a look at your project's solution file. You might discover that some active configurations are not consistent. In some rare special cases you might have good reasons to do things differently, but usually it is best to keep things simple: The solution settings should represent it's projects' configurations as directly as possible. Compiling a solution with certain settings should be directly reflected in the generated binaries. I recently heard someone mention "the principle of least surprise". That's what this is about. Surprises are for birthday parties and Oprah. What we developers want is control.

## Inconsistency in a solution:
    {74482536-2654-4B15-B457-9425A05341E6}.Debug|x86.ActiveCfg = Debug|x64 

## Inconsistency in a project:
    <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|x86'">
      <PlatformTarget>x64</PlatformTarget>
    </PropertyGroup> 

In order to regain control of your solution build, you will have check the active configuration of every project for each possible combination of solution configuration and platform. Keep in mind that you might want to get rid of unused or unwanted options before doing so, reducing the reconfiguration work that has to be done. If you have many projects, this might take a few hours to get right. You need to make conscious decisions as to how you want which project to build. Knowledge of the project is therefor required and it might mean you have to discuss these decisions with your team.

The following is my recommended strategy for straightening out your solution and project configurations. I want to emphasize that **this is my personal preference** and that there may be good reasons to do it differently (e.g. when developing for funky platforms such as Windows Phone or Xbox). I believe this strategy is good for most (if not all) projects, being that it restores predictability and forces you to make decisions on how you want your project to be deployed. Here goes.

# Regaining Control
Open the Configuration Manager. By switching `Configuration` and `Platform` you will be able to view and modify what project configurations/platforms will be targeted when building the solution in that mode. The general rule of thumb I recommend is to always keep solutions and project settings in sync. If the solution is set to `Debug|Any CPU`, then all projects should be as well.

When setting to a more specific platform such as `x86`, you should switch as many projects' configurations as possible to that, too - otherwise to `Any CPU`. In an ideal world you would set all projects to `x86`, and if you can, do so. If you need to leave some `Any CPU` projects in that mode (because you are probably just too lazy to do otherwise), at least make sure they are not your apps "entry points", i.e. executable projects. The reason is if you build as `x86` but your executable is `Any CPU`, running the app on a 64bit machine will make your whole app domain run as x64, which is not always desirable and - much worse - not expected. So try to use the exact same config as in the solution whenever possible. Even if it means (some seconds of) extra work adding configurations to projects.

{{% pic src="/img/blogger/configmanager.png" caption="The Configuration Manager window" link="/img/blogger/configmanager.png" width="300em" %}}

This topic is harder to explain than it should be, and much harder to describe than it actually is to do. Even if I am beating a dead horse here, I would like to describe the process using an example walk-through. My example app needs special treatment on 64bit platforms, meaning you have to run it explicitly as 32bit in order to support some third-party libraries that will die horribly if in x64 mode. The goal is to have an `Any CPU` mode for any machine and an `x86` mode in case you need to build an explicit 32bit app for a 64bit environment. Later on you could ditch the `x86` mode if the incompatibility is out of the way. Note that if you don't have issues running on 64bit machines, you can do the following while only keeping `Any CPU` and can delete every other platform - making things much easier.

## Solution
1. In the Configuration Manager, remove any solution configuration other than `Debug` and `Release`. Also remove any solution platform other than `Any CPU` and `x86` (the latter only if you need a build that is never, ever supposed to run in a 64bit context).
1. Select Debug and Any CPU in Visual Studio's toolbar menus
 1. Below, change *every* project's configuration to Debug
 1. Change *every* project's platform to `Any CPU`
 1. Check *every* project's *build* check-box. That will ensure they recompile properly whenever you switch configurations. Otherwise, switching and then building could result in mixed-platform assemblies (= bad)
1. Select `Release` and `Any CPU`
 1. Below, change *every* project's configuration to `Release`
 1. same as 2.2
 1. same as 2.3
1. select `Debug` and `x86`
 1. same as 2.1
 1. Change *every* project's target platform to `x86`. If x86 is not an available platform for some projects, create them. At the very minimum, *every executable project must be x86*; others usually can be `Any CPU` if they really need to be, but for the sake of predictability, try to avoid that.
 1. same as 2.3
1. Select `Release` and `x86`
 1. same as 2.1
 1. Change *every* project's platform to `x86`. As explained in 4.2, try to avoid anything else, even `Any CPU`
 1. same as 2.3

## *Every* project
1. Open the project designer window ("project settings") and go to the [build page](http://msdn.microsoft.com/en-us/library/kb4wyys2.aspx)
1. Remove any configurations and platforms that [you do not need](http://www.xprogramming.com/Practices/PracNotNeed.html) to avoid accidentally using the (now) deprecated settings in the future
1. Select `Debug` and `Any CPU` project settings at the top of the window
 1. Set the *platform target* in the middle of the window to be `Any CPU`
1. Select `Debug` and `x86`
 1. Set the platform target to `x86`
1. Select `Release` and `Any CPU`
 1. Set the platform target to `Any CPU`
1. Select `Release` and `x86`
 1. Set the platform target to `x86`

... I think you get the idea. Rinse and repeat for any other combination of solution configuration and platform. The general purpose is to take out some of the variables in the configuration chain and (pretend) it looks like what you would expect:

    SLN config + SLN platform => PROJ config + PROJ platform => PROJ platform platform => Binary

# Conclusion
Before I wrap this up you should know why I wrote this (probably too long) post in the first place. Recently I was running into those `BadImageFormatExceptions` on a CI build server. It turned out that some of the projects compiled to x64, despite passing in explicit `Release|x86` into the solution build. The CI servers are 32bit machines, and they crashed when a unit test attempted to load a 64bit assembly. Did I mention that I *really* like unit tests?

One nice effect of cleaning this up was that it reduced the solution's file size enormously. From a whopping 4500 lines to less than 1500 lines - just by dumping unused configurations. I have not verified this yet, but I expect loading the solution and switching configurations to be (at least slightly) faster now. After all, VS loads that file into memory and works with it every time you switch.

For what it's worth, I think this is way too hard to control in Visual Studio. There is much flexibility here that is usually not required and only gets abused, consciously or not. The only thing a developer should have to worry about are the toolbar menus for solution configuration and platform. I find that the latter seems to disappear on some machines after a while. It would be wise to [re-activate](http://blogs.msdn.com/b/nicgrave/archive/2010/06/19/platform-and-configuration-selection-in-visual-studio-2010-express-for-windows-phone.aspx) it, so you are constantly aware of  which platform you have selected. That will help avoid producing absurd active configuration constellations in the solution. Another best practice would be: always diff on your solution and project files before submitting them to source control. Understand what has changed and make sure it does not conflict with the intended configurations for your project.

I apologize if this post seemed repetitive at times. The terminology around these "configurations" and "platforms" is redundant and confusing, but once you got a grasp of these settings and the importance for your app (and your sanity!) you should have a much better understanding of how VS produces your application - and have much more control over the process.

# Resources
* [MSDN on solution and project configuration](http://msdn.microsoft.com/en-us/library/kkz9kefa%28v=VS.100%29.aspx)
* [MSBuild command line reference](http://msdn.microsoft.com/en-us/library/ms164311.aspx)
* [Project file schema reference](http://msdn.microsoft.com/en-us/library/5dy88c2e.aspx)
* [How to: Enable the solution platform selector](http://blogs.msdn.com/b/nicgrave/archive/2010/06/19/platform-and-configuration-selection-in-visual-studio-2010-express-for-windows-phone.aspx)
* [How to: Create and Edit Configurations](http://msdn.microsoft.com/en-us/library/kwybya3w.aspx)
