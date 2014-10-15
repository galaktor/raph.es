+++
author = "raph"
date = "2011-12-19T06:58:00+01:00"
draft = false
tags = [ "teamcity", "windows", "software", "builds", "powershell" ]
projects = []
title = "Revisited: Mapping network drives for TeamCity build agents"
wasblogger = true
aliases = [ "/2011/12/revisited-mapping-network-drives-for.html" ]
+++
In an older [post](/2011/06/mapping-network-drives-for-teamcity.html) I mentioned how hard it is to have TeamCity agents have access to mapped drives. Unfortunately, Windows only maps network drives during a user's login process. But you do not want to log in for every build agent - ideally they will run as daemons and, for instance, start automatically when the system boots without a user having to get involved.

So what I did before was an ugly hack - I used [psexec](http://technet.microsoft.com/en-us/sysinternals/bb897553) to map the drives I want agents to see to the root user ("SYSTEM"). I never really understood why it worked, but I never liked the solution. Plus, it still did not give you a real Windows service, only a scheduled task that sort of behaved the same way.

I recently did some reworking of my agents and decided to get rid of the psexec hack. What I did this time is much simpler: I gave up. Yep, I gave up trying to map the drives for the agents. If I want agents to be services, and services cannot map drives, so be it.

{{% fig %}}
{{% img src="/img/blogger/troll-mappings.png" link="/img/blogger/troll-mappings.png" width="400em" %}}
{{% /fig %}}

# Work with it, not against it
The alternative is to not need drive mappings in the first place. It crossed my mind that I might want to force all reference paths in the VS projects to be UNC paths. Problem is when you add a new file or reference, VS defaults to the drive letter and not the UNC path. Builds would regularly break because somebody forgot to manually change it into a UNC path...not cool.

The simple way around this is have a build step run before each VS compile that "unmaps" the project files automagically. Devs can still use drive mappings which work for them and don't have to worry about these build server specifics. 

At the end of this post is a simple Powershell script that does the job. It's quite simple in that it does a find/replace using regular expressions. Turns out this works quite nicely and performs well, too - just a few seconds to process several hundreds of project files. Adding in target file types or drive mappings should be straight-forward. Feel free to use, but *please read and respect the [license](/license)*.

# Running it as a pre-build step
On TeamCity 6+ you can configure an arbitrary chain of build steps. Just have TeamCity run this script on before your projects are compiled. Simplest is to just pass in the builds working directory as a paramter (`%system.teamcity.build.workingDir%`). That way you can replace the drive mappings in all files that were checked out of source control for the running build. You can, of course, use more specific paths instead of this shotgun approach. If that's how you roll.

Keep in mind that your build machines will by default have a [PowerShell execution policy](http://technet.microsoft.com/en-us/library/dd347628.aspx) of `Restricted`. You'll have to change it to run the scripts. `Set-ExecutionPolicy RemoteSigned` will do. If you TC process runs with administrator privileges you can also pass in a parameter to powershell.exe that will bypass the execution policy (use at your own risk):

    powershell.exe .\myscript.ps1 <path> -executionPolicy Bypass. 

{{% fig %}}
{{% img src="/img/blogger/tc-unmap-drives-step-highlight.png" link="/img/blogger/tc-unmap-drives-step-highlight.png" width="400em" %}}
{{% /fig %}}

# Example script (PowerShell)
    # licensed under The MIT license: http://www.opensource.org/licenses/mit-license.php
    # Copyright (c) Raphael Estrada
    # Author URL: http://www.galaktor.net
    PARAM([parameter(Mandatory = $true)]
          [string]$root=$(throw "Must give a root path."))
    
    $exitCode = 0
    
    try
    {
      $stopWatch = New-Object "System.Diagnostics.Stopwatch"
      $stopWatch.Start()
      # works on C# an VC++ project files
      $targetFiles = Get-ChildItem $root -recurse -include @("*.csproj","*.vcxproj")
      $stopWatch.Stop()
    
      Write-Host "Finding" $targetFiles.Length "files took" $stopWatch.ElapsedMilliseconds "ms"
    
      $mappings = @(
              ('X', '\\path\to\x'),
              ('Y', '\\path\to\y'),
              ('Z', '\\path\to\z')
            )
    
      $stopWatch.Reset()
      $stopWatch.Start()
      $modifiedCounter = 0
      foreach($file in $targetFiles)
      {
        # project file XML is usually UTF8
        $content = (Get-Content $file -Encoding UTF8)
    
        foreach($mapping in $mappings)
        {
          $pathRegex = [System.String]::Format("{0}:\\", $mapping[0])
          $replacement = $mapping[1]
          if(!$replacement.EndsWith("\"))
          {
            $replacement += "\"
          }
          if($content -match $pathRegex)
          {
            Write-Host "Found references to" $mapping[0] "drive in" $file.FullName "- Replacing with" $mapping[1]
            $content = $content -replace $pathRegex, $replacement
            $modifiedCounter++
          }
        }
        
        # write result back to file; again UTF8
        Set-Content -Encoding UTF8 $file $content -Force
      }
      $stopWatch.Stop()
    
      Write-Host "Processing" $targetFiles.Length "files took" $stopWatch.ElapsedMilliseconds "ms"
      Write-Host "Files modified:" $modifiedCounter
    }
    catch [System.Exception]
    {
      Write-Host "ERROR!" $_ -ForegroundColor Red
      $exitCode = 1
    }
