+++
author = "raph"
date = "2012-10-02T16:47:00+01:00"
draft = false
tags = [ "foss", "dotnet", "software" ]
title = "autofHACK - forcing activation of a service and dynamic resolution of it's dependencies"
projects = []
series = []
wasblogger = true
aliases = [ "/2012/10/autofhack-forcing-activation-of-service.html" ]
+++
Sorry, I just couldn't resist the "autofHack" pun.

In case you don't know [Autofac](http://code.google.com/p/autofac/), this post won't make much sense to you. Go read about it NOW. In the meantime us cool kids will play without you.

Autofac can find the right constructor on your service and resolve it's dependencies automagically using reflection when you do so:

    builder.RegisterType<MyClass>();

And you can give it a precreated instance directly like so:

    var m = new MyClass();
    builder.RegisterInstance(m);

The first is lazy and will only activate your service if somebody actually depends on it.

The latter can come in handy if you want to make sure that the service is actually instantiated and running, no matter if others depend on it or not.

The problem with `RegisterInstance()` is that there is no way for you to resolve the constructor dependencies through the IoC container.

What you can do is implement the [`IStartable`](http://code.google.com/p/autofac/wiki/Startable) interface, and it's method `Start()` will be called by the container once it's configured.

    public class MyClass: IStartable
    {
        public void Start()
        {
            // do stuff
        }
    }

That's not nice for two reasons: first, it forces me to use `Start()`, which can seem a bit forced in a model that has no need for that. Second, it requires your model to reference the Autofac library in order to use the interface, and I really don't want my whole system to be aware of the IoC framework - it should glue them together without them knowing how it happens, and referencing the library goes against that idea.

So I wrote up a few extension methods to hide the IStartable interface and integrate it into the Autofac syntax.

    builder.RegisterAndActivate<MyClass>();

This will register the type as when using `RegisterType<T>`, but also register a bootstrapper service which in it's `Start()` method will resolve your service once, hence bringing it to life even if nobody else actively requests it.

The code is here:
https://github.com/galaktor/autofac-extensions

Keep in mind (as stated on the autofac page about `IStartable`) that this only makes sense when you're service has a *Singleton* lifetime (because otherwise you'll only have activated one lonely instance that will die shortly after).

I suggested this be included in the official Autofac code in this issue:
http://code.google.com/p/autofac/issues/detail?id=388
