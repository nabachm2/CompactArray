//
//  SCompactArray_Tests.m
//  SCompactArray Tests
//
//  Created by Nicholas Bachmann on 5/19/14.
//  Copyright (c) 2014 banana.inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#include "compact_array_s.h"
#include <time.h>
#include <sys/time.h>
#include <stdlib.h>
#include <stdio.h>
#include <iostream>

@interface SCompactArray_Tests : XCTestCase

@end

@implementation SCompactArray_Tests

/**
 * Tests basic get and set operations, setting increasing
 * values
 */

-(void)testBasicSetGet {
    const int bitNum = 7;
    int maxValue = (int) (pow(2, bitNum) - 1);
    int size = 100000;
    SCompactArray<bitNum, false>* array = new SCompactArray<bitNum, false>(size);
    for (int i = 0;i < size;i ++)
        array->Set(i, i % maxValue);
    
    for (int i = 0;i < size;i ++)
        XCTAssertEqual(i % maxValue, (int) array->Get(i));
    
    delete array;
}

/**
 * Tests basic get and set operations using random
 * values.
 */

-(void)testRandomSetGet {
    srand((int) time(NULL));
    int seedVal = rand();
    
    const int bitNum = 7;
    long maxValue = (long) (pow(2, bitNum) - 1);
    int size = 100000;
    SCompactArray<bitNum, false>* array = new SCompactArray<bitNum, false>(size);
    
    srand(seedVal);
    for (int i = 0;i < size;i ++)
        array->Set(i, rand() % maxValue);
    
    srand(seedVal);
    for (int i = 0;i < size;i ++)
        XCTAssertTrue(rand() % maxValue == array->Get(i));
    
    delete array;
}

/**
 * Tests basic get and set operations using random
 * indices and values, with possible overwrite
 *
 */

-(void)testRandomIndexSetGet {
    srand((int) time(NULL));
    int seedVal = rand();
    
    const int bitNum = 7;
    int maxValue = (int) (pow(2, bitNum) - 1);
    int size = 100000;
    SCompactArray<bitNum, false>* array = new SCompactArray<bitNum, false>(size);
    long arrayHolder[size];
    for (int i = 0;i < size;i ++)
        arrayHolder[i] = 0;
    
    srand(seedVal);
    for (int i = 0;i < 4000;i ++) {
        int index = rand() % size;
        long value = rand() % maxValue;
        array->Set(index, value);
        arrayHolder[index] = value;
    }
    
    for (int i = 0;i < size;i ++)
        XCTAssertTrue(arrayHolder[i] == array->Get(i));
    
    delete array;
}

template <int bitNum>
void testDifferentBitSizeHelper() {
    long maxValue = (long) (pow(2, bitNum) - 1);
    int size = 100000;
    SCompactArray<bitNum, false>* array = new SCompactArray<bitNum, false>(size);
    
    srand((int) time(NULL));
    long seedVal = rand();
    
    srand((int)seedVal);
    for (int i = 0;i < size;i ++)
        array->Set(i, rand() % maxValue);
    
    srand((int)seedVal);
    for (int i = 0;i < size;i ++)
        assert((rand() % maxValue) == array->Get(i));
}

/**
 * Tests random values with different bit sizes
 * from 2 to 44 */
-(void)testDifferentBitSize {
    testDifferentBitSizeHelper<2>();
    testDifferentBitSizeHelper<3>();
    testDifferentBitSizeHelper<5>();
    testDifferentBitSizeHelper<6>();
    testDifferentBitSizeHelper<7>();
    testDifferentBitSizeHelper<11>();
    testDifferentBitSizeHelper<13>();
    testDifferentBitSizeHelper<16>();
    testDifferentBitSizeHelper<18>();
    testDifferentBitSizeHelper<19>();
    testDifferentBitSizeHelper<21>();
    testDifferentBitSizeHelper<25>();
    testDifferentBitSizeHelper<30>();
    testDifferentBitSizeHelper<31>();
    testDifferentBitSizeHelper<39>();
    testDifferentBitSizeHelper<40>();
    testDifferentBitSizeHelper<32>();
    testDifferentBitSizeHelper<49>();
    testDifferentBitSizeHelper<50>();
    testDifferentBitSizeHelper<52>();
    testDifferentBitSizeHelper<56>();
}


/**
 * Tests overwrite of values to make sure old data was scrubbed
 * appropriately
 */

-(void)testOverwrite {
    const int bitNum = 23;
    int maxValue = (int) (pow(2, bitNum) - 1);
    int size = 100000;
    SCompactArray<bitNum, false>* array = new SCompactArray<bitNum, false>(size);
    for (int k = 0;k < 40;k ++) {
        srand((int) time(NULL));
        int seedVal = rand();;
        
        srand(seedVal);
        for (int i = 0;i < size;i ++)
            array->Set(i, rand() % maxValue);
        
        srand(seedVal);
        for (int i = 0;i < size;i ++)
            XCTAssertTrue(rand() % maxValue == array->Get(i));
    }
    
    delete array;
}

long getTime() {
    struct timeval start;
    gettimeofday(&start, NULL);
    return start.tv_sec * 1000000 + start.tv_usec;
}

template <int bitNum>
void testSpeedComparisionHelper() {
    long maxValue = (int) (pow(2, bitNum) - 1);
    long size = 1000000;
    
    double ca_put = 0, ca_get = 0;
    double na_put = 0, na_get = 0;
    SCompactArray<bitNum, false>* array = new SCompactArray<bitNum, false>(size);
    unsigned long normalArray[size];
    for (int i = 0;i < size;i ++)
        normalArray[i] = 0;
    
    long checksum1 = 0, checksum2 = 0;
    for (int k = 0;k < 40;k ++) {
        srand((int) time(NULL));
        int seedVal = rand();
        
        NSDate* start = [NSDate date];
        srand(seedVal);
        for (int i = 0;i < size;i ++)
            array->Set(i, rand() % maxValue);
        
        ca_put += fabs([start timeIntervalSinceNow]);
        
        start = [NSDate date];
        srand(seedVal);
        for (long i = 0;i < size;i ++)
            normalArray[i] =rand() % maxValue;
        
        na_put += fabs([start timeIntervalSinceNow]);
        
        start = [NSDate date];
        for (int i = 0;i < size;i ++)
            checksum1 += (*array)[i];
        
        ca_get += fabs([start timeIntervalSinceNow]);
        
        start = [NSDate date];
        for (long i = 0;i < size;i ++)
            checksum2 += normalArray[i];
        
        na_get += fabs([start timeIntervalSinceNow]);
    }
    double diff_put = (ca_put) / (double) na_put;
    double diff_get = (ca_get) / (double) na_get;
    
    long size_na = size * 64;
    long size_ca = size * bitNum;
    std::cout << "STATS FOR BITSIZE:" << bitNum << " RATIOS OF COMPACT ARRAY TO NORMAL ARRAY OF LONGS" << std::endl;
    std::cout << "MEMORY RATIO:" << (size_ca / (double) size_na) << std::endl;
    std::cout << "RATIO BETWEEN ASSIGNMENT TIMES:" << diff_put << " (" << (ca_put / 40) << " to " << (na_put / 40) << ") secs per 1000000 iterations"  << std::endl;
    std::cout << "RATIO BETWEEN GET TIMES:" << diff_get << " (" << (ca_get / 40) << " to " << (na_get / 40) << ") secs per 1000000 iterations"  << std::endl;
    assert(checksum1 == checksum2);
    printf("\n");
    
    delete array;
}

/**
 * This method runs through most bit sizes and
 * tests random values with both a array of longs
 * and the compact array. It them prints out the respective
 * ratios for memory usage, assignment time and access time
 */
-(void)testSpeedComparision {
    testSpeedComparisionHelper<2>();
    testSpeedComparisionHelper<3>();
    testSpeedComparisionHelper<4>();
    testSpeedComparisionHelper<5>();
    testSpeedComparisionHelper<6>();
    testSpeedComparisionHelper<7>();
    testSpeedComparisionHelper<8>();
    testSpeedComparisionHelper<9>();
    testSpeedComparisionHelper<10>();
    testSpeedComparisionHelper<11>();
    testSpeedComparisionHelper<12>();
    testSpeedComparisionHelper<13>();
    testSpeedComparisionHelper<14>();
    testSpeedComparisionHelper<15>();
    testSpeedComparisionHelper<16>();
    testSpeedComparisionHelper<17>();
    testSpeedComparisionHelper<18>();
    testSpeedComparisionHelper<19>();
    testSpeedComparisionHelper<20>();
    testSpeedComparisionHelper<21>();
    testSpeedComparisionHelper<22>();
    testSpeedComparisionHelper<23>();
    testSpeedComparisionHelper<24>();
    testSpeedComparisionHelper<25>();
    testSpeedComparisionHelper<26>();
    testSpeedComparisionHelper<27>();
    testSpeedComparisionHelper<28>();
    testSpeedComparisionHelper<29>();
    testSpeedComparisionHelper<30>();
    testSpeedComparisionHelper<31>();
    testSpeedComparisionHelper<32>();
    testSpeedComparisionHelper<33>();
    testSpeedComparisionHelper<34>();
    testSpeedComparisionHelper<35>();
    testSpeedComparisionHelper<36>();
    testSpeedComparisionHelper<37>();
    testSpeedComparisionHelper<38>();
    testSpeedComparisionHelper<39>();
    testSpeedComparisionHelper<40>();
    testSpeedComparisionHelper<41>();
    testSpeedComparisionHelper<42>();
    testSpeedComparisionHelper<43>();
    testSpeedComparisionHelper<44>();
    testSpeedComparisionHelper<45>();
    testSpeedComparisionHelper<46>();
    testSpeedComparisionHelper<47>();
    testSpeedComparisionHelper<48>();
    testSpeedComparisionHelper<49>();
    testSpeedComparisionHelper<50>();
    testSpeedComparisionHelper<51>();
    testSpeedComparisionHelper<52>();
    testSpeedComparisionHelper<53>();
    testSpeedComparisionHelper<54>();
    testSpeedComparisionHelper<55>();
    testSpeedComparisionHelper<56>();
    testSpeedComparisionHelper<57>();
    
    
}

@end
