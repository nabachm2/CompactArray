//
//  compact_array_d.h
//  CompactArray
//
//  Created by Nicholas Bachmann on 12/20/14.
//  Copyright (c) 2014 banana.inc. All rights reserved.
//

/**
 * @author Nicholas
 *
 * An fixed size array for compacting unsigned numbers into an array. This
 * class allows you to specify the size of the array (in elements) and
 * the max amount of bits that a number will have. For example if you only need
 * to store 20 bit numbers, an array of ints would be a bit wasteful. By using this
 * array you could achieve the optimal space usage, without sacrificing too much
 *
 * This version is dynamic, meaning that you can pass in the bit count and specify if numbers
 * should be signed at runtime
 *
 * For this implementation I have allowed the user to specify size at compile time
 * as well as allowing the user to use signed numbers. This allows very quick speeds
 * compared with the java version. IF YOU WANT TO SEE A DIFFERENCE COMPILE AT LEAST
 * -O1 OPTIMIZATION LEVEL, since that takes out all the unnessary if statements, and
 * allows all the cool tricks for bit shifting with power of 2 bit sizes.
 *
 * I have provided a file with fairly comprehensive test cases if you wish to fiddle
 * around with the code, as well as an overall speed test to compare with an array
 * of longs. After some basic profiling on my machine (Macbook Pro 2012 (?)) running
 * java 7, I found assignment to range from 5 to 15% slower than normal arrays (fairly negligible),
 *  while accessing can be anywhere from 4 to 8 times slower (depending on bit size). However,
 * depending on the needs, the saved space can outweigh, the time delay for access.
 * ALSO NOTE: Array lookups are extremely fast, so even 4 to 8 times slower is still
 * very fast and that statistic can be misleading.
 */

#ifndef __CompactArray__compact_array_d__
#define __CompactArray__compact_array_d__

#include <stdio.h>

#include <cstddef>
#include <vector>

class DCompactArray {
    
    int bit_count_;
    bool is_signed_;
    
    //array of values
    std::vector<unsigned long> array_;
    
    //the size in elements
    size_t max_size_;
    
    //a bit mask of bitCount 1's
    unsigned long bit_mask_;
    unsigned long sign_mask_;
    unsigned long negative_mask_;
    
private:
    inline int GetSignBit() const { return is_signed_ ? 1 : 0; }
    
public:
    DCompactArray(size_t max_size, int bit_count, bool is_signed=true);
    
    void Set(int index, long element);
    long Get(int index) const;
    
    const long operator[](const int index) const;
    
    inline size_t GetSize() { return max_size_; }
    
};


#endif /* defined(__CompactArray__compact_array_d__) */
