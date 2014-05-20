//
//  CompactArray.h
//  CompactArray
//
//  Created by Nicholas Bachmann on 1/29/14.
//  Copyright (c) 2014 Nicholas Bachmann. All rights reserved.
//

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
