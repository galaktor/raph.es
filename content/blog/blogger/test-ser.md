+++
author = "raph"
date = "2011-02-21T21:29:00+01:00"
draft = false
tags = [ "software", "dotnet", "testing" ]
projects = []
title = "Testing serializability"
wasblogger = true
aliases = [ "/2011/02/testing-serializability.html" ]
+++
Serialization in .NET is pretty straightforward. It is most commonly used to (de)serialize XML or to send byte streams over [teh interwebs](http://www.urbandictionary.com/define.php?term=interwebs). The latter is an important part of how the [Windows Communication Foundation (WCF)](http://msdn.microsoft.com/en-us/netframework/aa663324) works - as well as it's predecessor, .NET Remoting.

In order to (de)serialize a type in .NET you have to decorate it with the [SerializableAttribute](http://msdn.microsoft.com/en-us/library/system.serializableattribute.aspx). This will tell the runtime to take an object of a specific type and all of it's data, flatten it into a series of bytes (hence the term "serialized"), which then can be written as text into an XML file or chopped into packets and sent over the wire.

To do this, the runtime must know how to handle each and every member of the class. [Value types](http://msdn.microsoft.com/en-us/library/s1ax56ch.aspx) such as int, double or enums as well as (special-case [reference types](http://msdn.microsoft.com/en-us/library/490f96s2.aspx)) strings can be taken care of out-of-the-box since the size of their data is known to the runtime. In case of fields for custom classes, however, you need to do a little more work. Those are expected to be decorated with the SerializableAttribute as well. Means that as soon as you start serializing complex object graphs, every one of those complex types needs to be marked with said attribute.

    using System.Runtime.Serialization;

    // must mark this serializable, even if it would implement ISerializable
    [Serializable]
    public class MySerializableClass
    {
        private double someDouble;
    }

This is where stuff can get hairy. Say you have a main class that happens to be the "root" of that object graph. And someone on your team makes a modification to it, e.g. [refactors some of it into new classes](http://www.refactoring.com/catalog/replaceDataValueWithObject.html) that are added as fields. Then those new classes must have the SerializableAttribute, otherwise you will end up getting exceptions. At runtime. No line of defense at compile time! What a mess. I would have expected Visual Studio to offer some help here, or at least have a nice feature in ReSharper to make all affected types [Serializable] recursively.

    using System.Runtime.Serialization;

    [Serializable]
    public class MySerializableClass
    {
        private double someDouble;
         
        // if not set to be ignored, will be expected to be serializable at runtime
        private ThatOtherSerializableClass complexObject;
    }
    
    // now this guy has to be marked serializable, too!
    [Serializable]
    public class ThatOtherSerializableClass
    {
        private string SomeString { get; set; }
    }

At some point I got fed up with debugging cryptic exceptions in log files for hours just to find that someone made a change to that (way to complex) class and had forgotten to mark a new component serializable. In order to move the debugging closer to compile time I wrote a very simple test that is now executed for every change in the source control repository. Here it is:

    using NUnit.Framework;
    
    [TestFixture]
    public class MySerializableClassTest
    {
        [Test]
        public void Serialize_BinaryDeserialize_ThrowsNoSerializationException()
        {
            var serializer  = new MySerializableClass();
            var stream = new MemoryStream();
            var formatter = new BinaryFormatter();
     
            try
            {
                Assert.DoesNotThrow(() => formatter.Serialize(stream, serializer),
                "Class and all of it's components must be [Serializable]");
            }
            finally
            {
                // close even if test fails
                stream.Close();
            }
        }
    }

What it does should be quite obvious to those of you who actually looked through it. For those who just skimmed to the explanation (boo!), here goes. MySerializableClass is some type that is marked serializable and consists of other members that should be serializable. This is usually the root of your object graph that you will be serializing. It uses [NUnit's Assert.DoesNotThrow assertion method](http://www.nunit.org/index.php?p=exceptionAsserts&r=2.5.9) to make sure the deserialization process does not cause any SerializationExceptions to be thrown.

You might notice the [try/finally block](http://msdn.microsoft.com/en-us/library/zwc8s4fz%28v=vs.80%29.aspx) in there. Yes, I am aware of the fact that handling exceptions in tests is usually a [bad smell](http://en.wikipedia.org/wiki/Code_smell). It usually indicates that you are catching exceptions, making it less readable, more complicated to comprehend (=maintain!) and could even falsify the test by catching one of NUnit's exceptions. In this case I am just going the extra mile and ensuring that the MemoryStream used to serialize the object for this test into memory is closed, even if the test fails. In that case, NUnit will throw an exception and without the finally that stream would not be closed. 

You can probably omit the try/finally block and the call to Close(), since those resources will be cleaned up by the runtime sooner or later. That part does hurt readability alot. It is your call which one you prefer, I usually go for readability in tests. So, for the sake of completeness, here is a version without that try/finally - much better readable.

    using NUnit.Framework;
    
    [TestFixture]
    public class MySerializableClassTest
    {
        [Test]
        public void Serialize_BinaryDeserialize_ThrowsNoSerializationException()
        {
             var serializer  = new MySerializableClass();
             var stream = new MemoryStream();
             var formatter = new BinaryFormatter();
     
             Assert.DoesNotThrow(() => formatter.Serialize(stream, serializer),
             "Class and all of it's components must be [Serializable]");
        }
    }

That's it, simple test that can save lots of time. Now we know about that issue almost at compile time, if you run tests before you check-in code (and you should!), you will find this before any damage is done. At the very latest it should show up on your continuous integration server (assuming you have one; and you probably should!), which is still much better than at runtime.

One more thing. I consider this test to be an integration test, not a unit test. It all runs in-memory, which could [classify it as a unit test](http://www.osherove.com/blog/2009/9/28/unit-test-definition-20.html) - but depending on the size and complexity of the serialized graph it can be a time consuming test (serveral seconds!) and involve many other classes (the members that should be marked serializable). Therefor, if you have a place (i.e. project) dedicated to integration tests, I recommend to put it in there.

For details on how serialization works in .NET, check out the [ubiquitious MSDN documentation](http://msdn.microsoft.com/en-us/library/system.runtime.serialization.aspx).

(Update: It's worth mentioning that this approach will only tell you if the class and it's explicit member types are serializable. It will not, however, cover the fact that the references in the serialized class could hold derived types at run-time. Since the `SerializableAttribute` is not inheritable, you could still end up with run-time exceptions when the actual types are not serializable.)
