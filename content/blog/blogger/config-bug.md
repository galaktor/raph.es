+++
author = "raph"
date = "2011-05-27T08:42:00+01:00"
draft = false
tags = [ "dotnet", "software" ]
title = "Manually caching configuration sections to avoid the .NET 4 bug"
wasblogger = true
aliases = [ "/2011/05/workaround-net4-bug-configurationmanage.html" ]
+++
There is a [bug in the .NET 4 ConfigurationManager](http://social.msdn.microsoft.com/Forums/en/clr/thread/1e14f665-10a3-426b-a75d-4e66354c5522) that has been causing me some headache. If you are trying to run .NET 4 code from a network drive and are getting SecurityExceptions, you might be facing it. When you want to read a section from your App.config - I'll creatively call it *MySection* - you typically do this:

    MySection mySection = ConfigurationManager.GetSection("MySection") as MySection;

In your XML configuration, that section is registered with a type - often referred to as the section handler, e.g. *MySectionHandler*, which is implemented in *SomeAssembly*.

    <?xml version="1.0" encoding="utf-8" ?>
    <configuration>
        <configSections>
            <section name="MySection" type="MySectionHandler, MyAssembly"/>
        </configSections>
        <MySection>
            <!-- some custom configuration here -->
        </MySection>
    </configuration>

That type is what glues the XML to your original call to [`ConfigurationManager`](http://msdn.microsoft.com/en-us/library/system.configuration.configurationmanager.aspx). It tells the .NET framework how to transform the configuration text into .NET objects - that process is called [deserialization](http://msdn.microsoft.com/en-us/library/ms731073.aspx). The "serial" text is transformed into a higher-level, non-serial data structure. Let's have a look at a common section handler implementation:

    public class MySectionHandler: IConfigurationSectionHandler
    {
        public object Create(object parent, object configContext, XmlNode section)
        {
            MySection result = // deserialize instance of MySection
            return result;
        }
    }
    
    [XmlRoot("MySection")]
    public class MySection
    {
        // some custom configuration here
    }

In this scenario, your call to [ConfigurationManager.`GetSection()`](http://msdn.microsoft.com/en-us/library/system.configuration.configurationmanager.getsection.aspx) causes the run-time to read in the App.config XML as text, pass it in to *MySectionHandler*, which in turn returns the deserialized object to the original caller. Now, the problem is that in .NET 4, ConfigurationManager.GetSection() has a bug. When you are running you application from a network location, it seems to consider the configuration files "unsafe" and will give you security exceptions when attempting to read the configuration. Microsoft support recommends a [workaround](http://msdn.microsoft.com/en-us/library/ms134265.aspx):

    MySection mySection = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None).GetSection("MySection"); 

While this alternative call seems very much the same, there are two fundamental differences:
1. It only works for sections that are derived from `ConfigurationSection`
1. `OpenExeConfiguration` does not cache deserialized sections

# `ConfigurationSection` vs. `IConfigurationSectionHandler`
The *first* turns out to be a problem for those who create section handlers by implementing the [`IConfigurationSectionHandler`](http://msdn.microsoft.com/en-us/library/system.configuration.iconfigurationsectionhandler.aspx) interface (as I did in the above example). This pattern roots in the early days of the .NET framework and is obsolete since .NET 2.0. Nevertheless, it is very convenient. All you need to do is have a class implement the [`Create()`](http://msdn.microsoft.com/en-us/library/system.configuration.iconfigurationsectionhandler.create.aspx) method and return an object. How it creates the object is secondary, but typically you will use an [`XmlSerializer`](http://msdn.microsoft.com/en-us/library/system.xml.serialization.xmlserializer.aspx) with the [`XmlNode`](http://msdn.microsoft.com/en-us/library/system.xml.xmlnode.aspx) parameter for deserialization. Also, since this is just an interface, you have complete freedom regarding your class design. 

In order to make use of the recommended workaround you have to derive your section implementation from [`ConfigurationSection`](http://msdn.microsoft.com/en-us/library/system.configuration.configurationsection.aspx). Using the [.NET configuration API](http://msdn.microsoft.com/en-us/library/ms228060.aspx) you can define your section with a bit more power and flexibility than using the [XML serialization API](http://msdn.microsoft.com/en-us/library/system.xml.serialization.aspx). You can have the run-time validate that the values in your configuration are of a certain numerical range or default to specific strings - handy stuff. The downside is, though, that it's usage is quite verbose. You need to implement new classes with lots of abstract methods, which gets quite bloated once you are working with complex XML, especially when you compare it with the much leaner `IConfigurationSectionHandler` pattern.

# Manual vs. automatic caching
While using the Configuration API might be a bit clunky, it's something you can get used to. The *second* issue you will encounter when using the above workaround is a bigger problem. `OpenExeConfiguration()` is designed to allow modifications to the underlying configuration. Therefor, by design, it cannot cache the sections it deserializes. If you take code that expects the caching of `ConfigurationManager.GetSection()` and just replace it with calls to `OpenExeConfiguration().GetSection()`, you can end up repeating the file I/O and deserialization process over and over again - which can lead to a serious performance impact.

Given the scenario of my above example, you could verify the caching with the following pseudo-test:

    object first  = ConfigurationManager.GetSection("MySection");
    object second = ConfigurationManager.GetSection("MySection");
    // first == second will give 'true'
    
    first =  ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None).GetSection("MySection"));
    second = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None).GetSection("MySection"));
    // first == second will give 'false'

The obvious way to get around that is to hold on to a reference to your Configuration object. But that's not applicable all the time and feels a bit dirty - you end up with references to the same object all over the place. Also, since this is just a bug in the .NET framework that is supposed to be fixed with SP1, you would be making lots of modifications to your code that will be useless as soon as SP1 is released. Instead, you could write an [extension method](http://msdn.microsoft.com/en-us/library/bb383977.aspx) that will use the recommended workaround call, but include simple "manual" caching.

# A workaround for the workaround
First, we create a simple extension method that will be available on [Configuration](http://msdn.microsoft.com/en-us/library/system.configuration.configuration.aspx) instances.

    public static class ConfigurationExtensions
    {
        private static readonly CachedConfigurationSectionLoader cachedSections = new CachedConfigurationSectionLoader();
    
        public static ConfigurationSection GetSectionCached(this Configuration configuration, string sectionName)
        {
            return cachedSections.GetSection(sectionName);
        }
    }

The extension method makes use of a class called `CachedConfigurationSectionLoader`. It simply maintains a [`ConcurrentDictionary`](http://msdn.microsoft.com/en-us/library/dd287191.aspx) to store the deserialized objects in a clean and thread-safe manner.

    using System.Configuration;
    using System.Collections.Concurrent;
    
    public class CachedConfigurationSectionLoader
    {
        private readonly Configuration exeConfiguration;
        private readonly ConcurrentDictionary<string, ConfigurationSection> configurationSectionCache = new ConcurrentDictionary<string, ConfigurationSection>();
    
        public CachedConfigurationSectionLoader()
            : this(ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None))
        { }
    
        // use this for custom configuration objects
        public CachedConfigurationSectionLoader(Configuration configuration)
        {
            this.exeConfiguration = configuration;
        }
    
        public void ClearCache()
        {
            this.configurationSectionCache.Clear();
        }
    
        public ConfigurationSection GetSection(string sectionName)
        {
            return this.GetSection(sectionName, this.exeConfiguration);
        }
    
        public ConfigurationSection GetSection(string sectionName, Configuration configuration)
        {
            Func<string, ConfigurationSection> configurationSectionFactory = (s) => exeConfiguration.GetSection(s);
            ConfigurationSection result = configurationSectionCache.GetOrAdd(sectionName, configurationSectionFactory);
    
            return result;
        }
    }

Usage of the extension method looks almost exactly like the suggested workaround, and is not far away from our original calls to `ConfigurationManager.GetSection()`:

    MySection mySection = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None).GetSectionCached("MySection");

Now you can change all of your existing calls to `ConfigurationManager.GetSection()` in place, without having to redesign your classes just to get around this bug. Reverting these changes after SP1 is quite simple. You could just change all the calls back to as they were before the workaround, or - if you really want to keep changes minimal - simply replace the extension method with this:

    public static class ConfigurationExtensions
    {
        public static ConfigurationSection GetSectionCached(this Configuration configuration, string sectionName)
        {
            // redirect to built-in cached function
            return ConfigurationManager.GetSection(sectionName) as ConfigurationSection;
        }
    }

# Additional resources:
* [That nasty bug in the .NET 4 ConfigurationManager.GetSection()](http://social.msdn.microsoft.com/Forums/en/clr/thread/1e14f665-10a3-426b-a75d-4e66354c5522)
* [Serialization and Deserialization in .NET](http://msdn.microsoft.com/en-us/library/ms731073.aspx)
* [Unraveling the Mysteries of .NET 2.0 Configuration](http://www.codeproject.com/KB/dotnet/mysteriesofconfiguration.aspx)
* [The awesome concurrent collections in .NET 4](http://msdn.microsoft.com/en-us/library/system.collections.concurrent.aspx)
