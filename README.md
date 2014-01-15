CompactArray
============

This in an implementation for a fixed size array for compacting unsigned numbers into an array. This class allows you to specify the size of the array (in elements) and the max amount of bits that a number will have. For example if you only need to store 20 bit numbers, an array of ints would be a bit wasteful. By using this array you could achieve the optimal space usage, without sacrificing too much speed. Usage is simple, with only 3 methods provides (the same as a normal arrays in java), set(), get(), and size().  

  This array also implements the Iterable interface (allowing it to be used in the "new" for loop) however, this can be a bit slow, since the value needs to be autoboxed into a Long object: THEREFOR IT IS MUCH MORE EFFICIENT TO LOOP THROUGH AN ARRAY USING AN int COUNTER i.e.: for (int i = 0;...;i++) array.get(i)
  
  I have provided a file with fairly comprehensive test cases if you wish to fiddle around with the code, as well as an overall speed test to compare with an array of longs. After some basic profiling on my machine (Macbook Pro 2012 (?)) running java 7, I found the speed to assign an element ranges from 5 to 15% slower than normal arrays (fairly negligible), while accessing can be anywhere from 4 to 8 times slower (depending on bit size). However, depending on the needs, the saved space can outweigh the time delay for access. ALSO NOTE: Array lookups are extremely fast, so even 4 to 8 times slower is still very fast and that statistic can be misleading.

Further I have included a file with the test speeds of the array on my machine.
