//
//  compact_array_d.cpp
//  CompactArray
//
//  Created by Nicholas Bachmann on 12/20/14.
//  Copyright (c) 2014 banana.inc. All rights reserved.
//


#include "compact_array_d.h"

DCompactArray::DCompactArray(size_t max_size, int bit_count, bool is_signed) {
    is_signed_ = is_signed;
    bit_count_ = bit_count;
    
    bit_mask_ = 0;
    for (int i = 0;i < bit_count_ + GetSignBit();i ++)
        bit_mask_ |= 1L << i;
    
    sign_mask_ = 1L << (bit_count_ + GetSignBit() - 1);
    negative_mask_ = ~0 & ~bit_mask_;
    
    max_size_ = max_size;
    int array_size = (int) (max_size * (bit_count_ + GetSignBit()) / (sizeof(unsigned long) * 8) + 1);
    array_.resize(array_size);
    for (int i = 0;i < array_size;i ++)
        array_[i] = 0;
}

void DCompactArray::Set(int index, long element) {
    int adj_index = (int) ((index * (bit_count_ + GetSignBit())) / (int) (sizeof(unsigned long) * 8)); //get array position
    int mod_index = (index * (bit_count_ + GetSignBit())) % (sizeof(unsigned long) * 8); //get bit offset
    int left_over = mod_index + (bit_count_ + GetSignBit()) - (sizeof(unsigned long) * 8); //overflow into next array spot
    if (left_over <= 0) { //no overflow, just set within the one array spot
        array_[adj_index] &= ~((bit_mask_) << mod_index); //clear spot
        array_[adj_index] |= (element & bit_mask_) << mod_index; //set value
    } else {
        /*
         *  more complicated, we have to split our value
         *  The way this works is by storing the upper half of element in
         *  the upperhalf of array[adj_index]
         *
         *  while the lower half of element is stored in the lowest bit position
         *  of array[adj_index]
         */
        
        //clear our spot
        array_[adj_index] &= ~(((bit_mask_) >> left_over) << mod_index);
        //extract the upper half from element and store it
        array_[adj_index] |= (((unsigned long) (element & bit_mask_)) >> left_over) << mod_index;
        
        //extract lower half of element which is currently shifted completly left
        long left_over_val = (element & bit_mask_) << ((sizeof(unsigned long) * 8) - left_over);
        //clear our spot
        array_[adj_index + 1] &= ~(bit_mask_ >> ((bit_count_ + GetSignBit()) - left_over));
        //shift it left to store
        array_[adj_index + 1] |= ((unsigned long) left_over_val) >> ((sizeof(unsigned long) * 8) - left_over);
    }
}

const long DCompactArray::operator[](int index) const {
    return Get(index);
}

long DCompactArray::Get(int index) const {
    //see set(...) for implementation details of how the storing of
    //of values works, this is just the opposite.
    int adj_index = (index * (bit_count_ + GetSignBit())) / (int) (sizeof(unsigned long) * 8);
    int mod_index = (index * (bit_count_ + GetSignBit())) % (sizeof(unsigned long) * 8);
    int left_over = mod_index + (bit_count_ + GetSignBit()) - (sizeof(unsigned long) * 8);
    if (left_over <= 0) {
        if (is_signed_) {
            long retVal = (array_[adj_index] >> mod_index) & bit_mask_;
            if ((retVal & sign_mask_) != 0) return retVal | negative_mask_;
            else return retVal;
        } else {
            return (array_[adj_index] >> mod_index) & bit_mask_;
        }
    } else {
        unsigned long retVal = 0;
        retVal |= (array_[adj_index] >> mod_index) << left_over;
        retVal |= array_[adj_index + 1] & ((1L << left_over) - 1L);
        if(is_signed_) {
            if ((retVal & sign_mask_) != 0) return retVal | negative_mask_;
        }
        
        return retVal;
    }
}