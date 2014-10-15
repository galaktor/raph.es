+++
author = "raph"
date = "2011-06-12T20:18:00+01:00"
draft = false
tags = [ "teamcity", "windows", "software", "builds" ]
projects = []
series = []
title = "Mapping network drives for TeamCity build agents"
wasblogger = true
aliases = [ "/2011/06/mapping-network-drives-for-teamcity.html" ]
+++
*Update*: I recently changed my solution to the below problem. Go [check out](/2011/12/revisited-mapping-network-drives-for.html) my new, revolutionary approach to drive mappings on TeamCity agents!

[TeamCity](http://www.jetbrains.com/teamcity/ is a sophisticated and, above all, easy-to-use [CI server](http://en.wikipedia.org/wiki/Continuous_integration). It works equally well on different platforms, and despite it being implemented in Java, has surprisingly good support for Windows and .NET development.

When you install TeamCity, aside from the central (web) server, you will be running at least one build agent. On Windows, it is very convenient to install agents as [NT services](http://en.wikipedia.org/wiki/Windows_service). That way they can run [daemon-like](http://en.wikipedia.org/wiki/Daemon_%28computer_software%29) in the background, unattended, and without having to log on as an actual user of the build machine. Especially when your machines can be restarted frequently (e.g. for updates), it comes in handy that the service will simply start up again after the reboot.

There is one annoying fact about Windows services, though: they will not see [network drive mappings](http://en.wikipedia.org/wiki/Network_share). If your code base happens to have references to shared libraries on the network, and you use mapped drive letters to point your code to those (as opposed to, say, UNC paths), your builds will fail when running the build agent as a service. It will not see mapped drives, and therefor not find your dependencies.

I am no hardcore Windows administrator, but it appears that the network drive mapping is bound to a user and to his security context. That allows windows to decide, for example, if the mapped drive can be accessed by whatever user is currently logged on. No user, no security context, no mapped drives. What is particularly weird is that this still happens when you tell Windows to run the service as a particular user (instead of the default SYSTEM user).

Anyhoo, feel free to google the hell out of this topic and please leave a comment if you find a way to legally tell a service to map some drives. Until then, I have come up with a similar approach that will give you the benefits of a service without actually using it. It is hacky, I admit that much, and I do not understand every geeky detail of why it works while the service can't see the network drives...but I feel I should dump my hack here in case anyone finds himself in a similar situation and just wants it to *work*.

# Mapping drives to the root
I have done the following on Windows Server 2008 R2 machines - it goes without saying (but I'll still say it) that these steps might differ or not work at all on other versions of Windows. Again, if you know a better way, I'm all ears.

First of all, we need a script that contains the commands to map the drives you need during your builds. As an example, I will assume you want a drive X: to point to a location on your network, \\someserver\some\directory:

    REM content of "map_network_drives.cmd"
    
    REM delete existing mapping first
    net use x: /delete
    
    REM map drive; "persistent" just in case
    net use x: \\someserver\some\directory /persistent:yes

Now, using the almighty [PsExec](http://technet.microsoft.com/en-us/sysinternals/bb897553), part of the [Sysinternals Suite](http://technet.microsoft.com/en-us/sysinternals/bb842062), we create another script that will call our previous network map script with as the "root" user of your windows machine, the SYSTEM account. Note that screwing around with the root account can be a dangerous thing to do - don't say I did not warn you.

    REM content of "system_map_network_drives.cmd"
    
    REM configure locations to dependencies 
    set psexecPath=C:\tools\PsTools\PsExec.exe
    set mapNetworkDrives=C:\tools\map_network_drives.cmd 
    
    REM map network drives to SYSTEM user 
    %psexecPath% -s %mapNetworkDrives%

Next, in order to imitate a service's behavior, we need a scheduled task that will execute our `system_map_network_drives.cmd` script on *system startup*. Make sure the task is setup to run as an administrator. For details on how to schedule a task in windows, check out this [radical new website that will answer virtually all of your questions](http://en.lmgtfy.com/?q=scheduled+task+windows). For each of your TeamCity agents, set up a task the same way at system start-up that will execute `agent.bat start` (located in your build agent's `bin` directory).

What will happen now is whenever your machine boots up, your agents will start up, and in parallel, your SYSTEM account will have the expected drive mappings. When your agents start building, they will be able to resolve the mapped drive paths in your code at compile time.

Now you might be wondering why I don't just do the same and start the agents as services instead of tasks. That did not work - for *me* at least. Although tasks seem to have the same limitations regarding drive mappings as the services do, for some reason, giving the SYSTEM user those drive mappings works for the tasks, but not the services. As I said, I'm no Windows guru, and to be honest I was just plain happy this worked eventually.

# Verifying the mapped drives
When you call PsExec for the first time, you will need an elevated command prompt so it can install the PsExec service. And you'll need to accept the terms and conditions at first run as well. You can verify this by using PsExec to get a console and checking if the drives are mapped, as shown below. Before running the above tasks, the call to `net use` will inform you that `"There are no entries in the list."`

    C:\tools\PsTools>PsExec.exe -s cmd.exe
    PsExec v1.98 - Execute processes remotely
    Copyright (C) 2001-2010 Mark Russinovich
    Sysinternals - www.sysinternals.com
    
    
    Microsoft Windows [Version 6.1.7600]
    Copyright (c) 2009 Microsoft Corporation.  All rights reserved.
    
    C:\Windows\system32>whoami
    nt authority\system
    
    C:\Windows\system32>net use
    New connections will be remembered.

    Status       Local     Remote                       Network
    
    ----------------------------------------------------------------------------------
    OK           X:        \\someserver\some\directory  Microsoft Windows Network
    The command completed successfully.

It's worth mentioning that this approach might cause problems when the mapped network location requires specific permissions - adding the "SYSTEM" for every build machine to permission lists is not very scalable, especially when you have lots of build boxes in a farm.
