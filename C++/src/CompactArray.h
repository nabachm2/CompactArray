//
//  CompactArray.h
//  CompactArray
//
//  Created by Nicholas Bachmann on 1/29/14.
//  Copyright (c) 2014 Nicholas Bachmann. All rights reserved.
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

#ifndef __CompactArray__CompactArray__
#define __CompactArray__CompactArray__

#include <cstddef>

template <int bitCount, bool isSigned>
class CompactArray {
    
    //array of values
	unsigned long* array_;
    
	//the size in elements
    size_t max_size_;
    
	//a bit mask of bitCount 1's
    unsigned long bit_mask_;
    unsigned long sign_mask_;
    unsigned long negative_mask_;
    
private:
    inline int GetBit() const { return isSigned ? 1 : 0; }
    
public:
    CompactArray(size_t max_size);
    
    void Set(int index, long element);
    long Get(int index) const;
    
    inline size_t GetSize() { return max_size_; }
    
};

#include "CompactArray.hpp"

#endif /* defined(__CompactArray__CompactArray__) */
