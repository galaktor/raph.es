+++
author = "raph"
date = "2011-09-14T05:53:00+01:00"
draft = false
tags = [ "dotnet", "tests", "software" ]
title = "Understanding and testing enum flags"
projects = []
series = []
wasblogger = true
aliases = [ "/2011/09/understanding-enum-flags-and-enforcing.html" ]
+++
For those who know all about flags and [binary arithmetics](http://en.wikipedia.org/wiki/Binary_numeral_system) and want to insult me by responding to my careful writing with ignorance, then feel free to skip over the following section.

# Some basics on flags
Flag enums are a convenient way to store multiple `boolean` flags in one value. Typically an `Integer` is ideal for this sort of thing, but other udnerlying types are allowed. In .NET, no matter if in 32-bit or 64-bit mode, an Integer has 4 bytes, equal 32bits. So we have something like this (btw, all the examples here are little endian):

    00000000 00000000 00000000 00000001  // number "1" as a 32bit binary number

When using flags, every position in a row of zeroes and ones can be considered an independent `boolean` value. The trick is how to flip and read those particular values. Since in binary, each position is a power of two, you can map enums to distinct positions as such:

    [Flags]
    public enum MyFlags
    {
        Nothing = 0, 
        StateOne = 1,
        StateTwo = 2,
        StateThree = 4
    }

"Huh, why is `StateThree` mapped to the value 4?" Because we mapped our third state to the third *bit*. If I assign that enum value to a number, like this:

    int myFlag = MyFlags.StateThree;

then `myFlag` is equal to the numerical value "4".

    00000000 00000000 00000000 00000100  // number "4" as a 32bit binary number

Notice that our third bit is flipped, thus `StateThree`. The whole point here is that you can have several of our defined states in a single number, since each state's value is a power of two and thverefor has a distinct position in the "row":

    int myFlag = 0; // initialize
    myFlag |= MyFlags.StateOne;
    myFlag |= MyFlags.StateThree;

We just used the arithmetical OR operator to combine our states.This is what happens internally:

       00000000 00000000 00000000 00000000  // initial value of "myFlag"
    OR 00000000 00000000 00000000 00000001  // "MyFlags.StateOne"
    OR 00000000 00000000 00000000 00000100  // "MyFlags.StateThree"
    ----------------------------------------------------------------------------
       00000000 00000000 00000000 00000101  // result; number "5" in 32bit binary

Now the flags for both states can co-exist within a single `Integer` value. Note how, in order to store the decimal number 5 in binary form, you require 2 "1" bits. That's because 5 is not a power of two. Typically you will want all of your flag values to be a power of two in order to set one single bit at a time. There are, however, cases in which you might really want to use numbers that are not powers of two.

I will not go into those examples too deep, but one common case is color representation. In a nutshell, your three basic colors red, green and blue could be powers of two, and each resulting combined color would be a combination of those flags. The below is a very simplified example of how that could look like. It's not necessarily correct in terms of mixing colors, but hey, I'm color blind and frankly don't really give a shit.

    000 // 0: black
    001 // 1: red
    010 // 2: green
    011 // 3: yellow
    100 // 4: blue
    101 // 5: purple
    110 // 6: blue-green (woah!)
    111 // 7: white

You can retrieve a flag "manually":

    // given the above example, will return "true"
    bool hasStateThree = (myFlag & MyFlags.StateThree) == MyFlags.StateThree

using the arithemtical AND operator, which does the opposite of what we did before with OR. This technique is often referred to as masking.

        00000000 00000000 00000000 00000101  // "myFlag"
    AND 00000000 00000000 00000000 00000100  // "MyFlags.StateThree"; the mask
    ------------------------------------------------------------------------------
        00000000 00000000 00000000 00000100  // result; equal to MyFlags.StateThree!

There's a prettier way to do this exact same thing in .NET. The static method [`Enum.HasFlag`](http://msdn.microsoft.com/en-us/library/system.enum.hasflag.aspx) does the same as above, hiding the ugly distracting binary operators:
	
    bool hasStateThree = myFlag.HasFlag(MyFlags.StateThree); //masks using AND behind the scenes

OK, let's stop our little excursion into binary arithmetics right here. Back to topic.

# Enforcing the contract
There is a problem hidden herein. We saw that in most cases it makes sense to use only underlying enum values that are powers of two. So you code up something beautiful and do exactly that. Now, what if someone (especially you) changes that code later on, adds a new value to the enum and does not know (or forgets) that the separate state flags have to be powers of two? The compiler will not prevent you from using values in that enum that are not a power of two. For example, to the compiler (and unaware readers of your code, although the comment might give it away) this looks like a valid thing to do:

    [Flags]
    public enum MyFlags
    {
        Nothing = 0,
        StateOne = 1,
        StateTwo = 2,
        StateThree = 4,
        StateFour = 8,
        StateFive = 5  // d'oh! not a power of two! 
    }

Technically this is fine and might even be something you want to do (i.e. if `StateFive` is actually supposed to include both `StateOne` and `StateThree` at the same time). If you want to keep the values all powers of two, you will have to hope that your current and future colleagues will all thoroughly read the documentation you wrote up so carefully. lol.

Automated tests to the rescue! You can write a test that checks each value of the enum and fails if it's not a power of two. That way, even if someone accidentally adds an "invalid" number, the test will fail and point out the problem. This is a perfect case for unit(ish) tests, which are supposed to uphold your code's contracts. In this case, the constraint put upon the code is that all the enum values have to be a power of two, so let's enforce that.

    using nunit.framework;
    [TestFixture]
    public class MyFlagsTest
    {
        /// <summary>
        /// Checks if all enum values are valid, i.e. powers of two.
        /// Source of the checking algorithm:
        /// http://stackoverflow.com/questions/600293/how-to-check-if-a-number-is-a-power-of-2
        /// </summary>
        [Test]
        public void MyFlags_Always_ValuesArePowerOfTwo([ValueSource("AllEnumValues")]MyFlags enumValue)
        {
            int value = (int) enumValue;
            // must exclude zero to avoid overflow
            bool isPowerOfTwo = (value != 0) && ((value & (value - 1)) == 0);
            // don't forget that zero is a valid value as well
            bool isValidEnumValue = value == 0 || isPowerOfTwo;
    
            Assert.That(isValidEnumValue, Is.True, 
                "Value " + value + " of flag " + enumValue + " is not a power of two.");
         }
    
        // will be called by NUnit to resolve test parameters
        // when referenced using ValueSourceAttribute
        private Array AllEnumValues()
        {
            return Enum.GetValues(typeof(MyFlags));
        }
    }

The test uses a quick and quite efficient way to determine if a number is a power of two. It performs an AND operation on the number and that same value minus one. For powers of two, the result will be 0. For example:

         100  // 4, power of two
    AND  011  // 4 - 1 =3
    ---------------------------------
         000  // zero! yay!
    
         101  // 5, not power of two
    AND  100  // 5 - 1 = 4
    ---------------------------------
         100  // not zero! yay!

Note the error message that clearly points out the problem. The (visual) complexity of the test alone will look scary to whoever breaks it if he or she does not have some prose explaining what's going on. Don't expect people to get this sort of test right away. I know I wouldn't. If they're scared of the test, chances are they might get rid of it just to fix the build, and your initial design and good intentions disappear together with it.
