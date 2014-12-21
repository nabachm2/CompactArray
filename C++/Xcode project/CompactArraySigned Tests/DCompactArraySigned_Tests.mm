//
//  DCompactArraySigned_Tests.mm
//  CompactArray
//
//  Created by Nicholas Bachmann on 12/20/14.
//  Copyright (c) 2014 banana.inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#include "compact_array_d.h"
#include <time.h>
#include <sys/time.h>
#include <stdlib.h>
#include <stdio.h>
#include <iostream>

@interface DCompactArraySigned_Tests : XCTestCase

@end

@implementation DCompactArraySigned_Tests

/**
 * Tests basic get and set operations, setting increasing
 * values
 */

-(void)testBasicSetGet {
    for (int bitNum = 2;bitNum < 62;bitNum ++) {
        long maxValue = (int) (pow(2, bitNum - 1) - 1);
        long size = 100000;
        DCompactArray* array = new DCompactArray(size, bitNum, true);
        for (long i = 0;i < size;i ++)
            array->Set((int) i, (i % (maxValue * 2)) - maxValue);
        
        for (long i = 0;i < size;i ++)
            XCTAssertEqual((i % (maxValue * 2)) - maxValue, array->Get((int) i));
        
        delete array;
    }
}

/**
 * Tests basic get and set operations using random
 * values.
 */

-(void)testRandomSetGet {
    for (int bitNum = 2;bitNum < 62;bitNum ++) {
        srand((int) time(NULL));
        int seedVal = rand();
        
        long maxValue = (long) (pow(2, bitNum - 1) - 1);
        long size = 100000;
        DCompactArray* array = new DCompactArray(size, bitNum, true);
        
        srand(seedVal);
        for (long i = 0;i < size;i ++)
            array->Set((int) i, (rand() % (maxValue * 2)) - maxValue);
        
        srand(seedVal);
        for (long i = 0;i < size;i ++)
            XCTAssertTrue((rand() % (maxValue * 2)) - maxValue == array->Get((int) i));
        
        delete array;
    }
}

/**
 * Tests basic get and set operations using random
 * indices and values, with possible overwrite
 *
 */

-(void)testRandomIndexSetGet {
    for (int bitNum = 2;bitNum < 62;bitNum ++) {
        srand((int) time(NULL));
        int seedVal = rand();

        long maxValue = (int) (pow(2, bitNum - 1) - 1);
        long size = 100000;
        DCompactArray* array = new DCompactArray(size, bitNum, true);
        long arrayHolder[size];
        for (long i = 0;i < size;i ++)
            arrayHolder[i] = 0;
        
        srand(seedVal);
        for (long i = 0;i < 4000;i ++) {
            int index = rand() % size;
            long value = (rand() % (maxValue * 2)) - maxValue;
            array->Set(index, value);
            arrayHolder[index] = value;
        }
        
        for (int i = 0;i < size;i ++)
            XCTAssertTrue(arrayHolder[i] == array->Get(i));
        
        delete array;
    }
}

void testDifferentBitSizeHelperD(int bitNum) {
    long maxValue = (long) (pow(2, bitNum - 1) - 1);
    long size = 100000;
    DCompactArray* array = new DCompactArray(size, bitNum, true);
    
    srand((int) time(NULL));
    long seedVal = rand();
    
    srand((int)seedVal);
    for (long i = 0;i < size;i ++)
        array->Set((int) i, (rand() % (maxValue * 2)) - maxValue);
    
    srand((int)seedVal);
    for (long i = 0;i < size;i ++)
        assert(((rand() % (maxValue * 2)) - maxValue) == array->Get((int) i));
}

/**
 * Tests random values with different bit sizes
 * from 2 to 44 */
-(void)testDifferentBitSize {
    for (int i = 2;i < 60;i ++)
        testDifferentBitSizeHelperD(i);
}


/**
 * Tests overwrite of values to make sure old data was scrubbed
 * appropriately
 */

-(void)testOverwrite {
    for (int bitNum = 2;bitNum < 62;bitNum ++) {
        long maxValue = (int) (pow(2, bitNum) - 1);
        long size = 100000;
        DCompactArray* array = new DCompactArray(size, bitNum, true);
        for (long k = 0;k < 40;k ++) {
            srand((int) time(NULL));
            int seedVal = rand();;
            
            srand(seedVal);
            for (long i = 0;i < size;i ++)
                array->Set((int) i, (rand() % (maxValue * 2)) - maxValue);
            
            srand(seedVal);
            for (long i = 0;i < size;i ++)
                XCTAssertTrue((rand() % (maxValue * 2)) - maxValue == array->Get((int) i));
        }
        
        delete array;
    }
}

long getTimeD() {
    struct timeval start;
    gettimeofday(&start, NULL);
    return start.tv_sec * 1000000 + start.tv_usec;
}

void testSpeedComparisionHelperD(int bitNum) {
    long maxValue = (int) (pow(2, bitNum - 1) - 1);
    long size = 1000000;
    
    double ca_put = 0, ca_get = 0;
    double na_put = 0, na_get = 0;
    DCompactArray* array = new DCompactArray(size, bitNum, true);
    long normalArray[size];
    for (int i = 0;i < size;i ++)
        normalArray[i] = 0;
    
    long checksum1 = 0, checksum2 = 0;
    for (long k = 0;k < 40;k ++) {
        srand((int) time(NULL));
        int seedVal = rand();
        
        NSDate* start = [NSDate date];
        srand(seedVal);
        for (long i = 0;i < size;i ++)
            array->Set((int) i, (rand() % (maxValue * 2)) - maxValue);
        
        ca_put += fabs([start timeIntervalSinceNow]);
        
        start = [NSDate date];
        srand(seedVal);
        for (long i = 0;i < size;i ++)
            normalArray[i] = (rand() % (maxValue * 2)) - maxValue;
        
        na_put += fabs([start timeIntervalSinceNow]);
        
        start = [NSDate date];
        for (long i = 0;i < size;i ++)
            checksum1 += array->Get((int) i);
        
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
    for (int i = 2;i < 56;i ++)
        testSpeedComparisionHelperD(i);
    
}



@end
