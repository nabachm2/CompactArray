CompactArray
============

This in an implementation for a fixed size array for compacting unsigned numbers into an array. This class allows you to specify the size of the array (in elements) and the max amount of bits that a number will have. For example if you only need to store 20 bit numbers, an array of ints would be a bit wasteful. By using this array you could achieve the optimal space usage, without sacrificing too much speed. Usage is simple, with only 3 methods provides (the same as a normal arrays in java), set(), get(), and size(). I have included code for both a C++ and Java implementation (the C++ version supports signed numbers, where the type and bit size are resolved at compile time. The C++ version is considerably faster SO LONG AS YOU RUN AT LEAST O1 OPTIMIZATION ON IT.

  I have provided a file with fairly comprehensive test cases if you wish to fiddle around with the code, as well as an overall speed test to compare with an array of longs. After some basic profiling on my machine (Macbook Pro 2011 (?)) running java 7, I found the speed to assign an element ranges from 5 to 15% slower than normal arrays (fairly negligible), while accessing can be anywhere from 4 to 8 times slower (depending on bit size). However, depending on the needs, the saved space can outweigh the time delay for access. ALSO NOTE: Array lookups are extremely fast, so even 4 to 8 times slower is still very fast and that statistic can be misleading.

Further I have included a file with the test speeds of the array on my machine for the java and C++ implemenations.
