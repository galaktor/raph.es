+++
author = "raph"
date = "2011-05-05T08:42:00+01:00"
draft = false
tags = [ "dotnet", "visual studio", "software", "builds" ]
projects = []
series = []
title = "Conditional References in Visual Studio projects"
wasblogger = true
aliases = [ "/2011/05/conditional-references-in-visual-studio.html" ]
+++
Visual Studio does a good job in hiding the MSBuild configurations from it's users. MSBuild is quite flexible and powerful - but the VS user interface only gives you control over a tiny piece of it. One handy feature I believe deserves more attention in the IDE is *conditional references*. When you add a reference to one of your projects, by default it will be static. No matter how you [modify your solution configuration or platform settings](/2011/04/targeting-platforms-in-visual-studio.html).

But some libraries are platform dependent. If you build your solution as 64bit, you will not want to use a version of a library that is restricted to 32bit platforms. Visual Studio does not give you a way to put conditions on your references. Fortunately, MSBuild does. When referencing an assembly in VS, a `Reference` (or `ProjectReference`) element is added to your project file's XML containing details of the assembly and a `HintPath` to it's (supposed) location.

    <Reference Include="MyAssembly, processorArchitecture=MSIL">
        <SpecificVersion>False</SpecificVersion>
        <HintPath>path\to\MyAssembly.dll</HintPath>
    </Reference>

# Setting the conditions
Using your favorite text editor, you can add a `Condition` attribute to any reference in your project file, telling MSBuild when to use it (or not). This allows you to reference assemblies of different architecture and make sure they are used according to which platform you are targeting. In this case, a reference could look like the following in your project file: 

    <Reference Include="MyAssembly, processorArchitecture=MSIL"
               Condition="'$(Platform)' == 'x86'">
        <SpecificVersion>False</SpecificVersion>
        <HintPath>path\to\32bit\MyAssembly.dll</HintPath>
    </Reference>
    <Reference Include="MyAssembly, processorArchitecture=MSIL" 
               Condition="'$(Platform)' == 'x64'">
        <SpecificVersion>False</SpecificVersion>
        <HintPath>path\to\64bit\MyAssembly.dll</HintPath>
    </Reference>

This works because in MSBuild the reference elements are [`Item` elements](http://msdn.microsoft.com/en-us/library/ms164283%28v=VS.100%29.aspx). Many element types can have condition attributes. If you look at other parts of your project file you will probably see that the project configuration and platform sections also use conditions similar to the above example. There are [other ways to define conditional logic in MSBuild](http://msdn.microsoft.com/en-us/library/ms164307.aspx), but this is probably the quickest and most understandable. If you plan to do more funky stuff, have a look at [`<Choose>` and `<Otherwise>`](http://msdn.microsoft.com/en-us/library/ms164282.aspx).

{{% fig caption="Condition evaluates to *False*" %}}
{{% img src="/img/blogger/reference-warning.jpeg" link="/img/blogger/reference-warning.jpeg" width="200px" %}}
{{% /fig %}}

# The `Platform` variable
Note that in my example I am querying the `Platform` variable - *not* `Configuration`. I have noticed a practice [on teh webz](http://dev.monogram.sk/websvn/filedetails.php?repname=graphstudio&path=%2Ftrunk%2Fgraphstudio.sln) that suggests you create new configurations named *Debug64* and *Release64*, then switch references based on the `Configuration` variable. While this technically works the same way, it is logically incorrect. `Configuration` and `Platform` settings are two different concerns in Visual Studio and it is unwise to mix them. It's messy, redundant and generates loads of unnecessary lines in your solution and project files.

Assuming that your project has nicely [separated concerns](http://en.wikipedia.org/wiki/Separation_of_concerns) you should not have to make this change in more than one or [three](http://en.wikipedia.org/wiki/Rule_of_three_%28programming%29) places. If you *are* facing a large number of projects that need this additional logic, this XML operation can easily be automated via a script or macro.
