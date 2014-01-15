package compact_array;
import static org.junit.Assert.*;

import java.util.Random;

import org.junit.Test;


public class Tests {

	/**
	 * Tests basic get and set operations, setting increasing
	 * values
	 */
	@Test
	public void testBasicSetGet() {
		int bitNum = 7;
		int maxValue = (int) (Math.pow(2, bitNum) - 1);
		int size = 100000;
		CompactArray array = new CompactArray(size, bitNum);
		for (int i = 0;i < size;i ++) 
			array.set(i, i % maxValue);
		
		for (int i = 0;i < size;i ++) 
			assertEquals(i % maxValue, array.get(i));
	}
	
	/**
	 * Tests basic get and set operations using random
	 * values. 
	 */
	@Test
	public void testRandomSetGet() {
		Random seedGenerator = new Random();
		long seedVal = seedGenerator.nextLong();
		
		int bitNum = 7;
		long maxValue = (int) (Math.pow(2, bitNum) - 1);
		int size = 100000;
		CompactArray array = new CompactArray(size, bitNum);
		
		Random rand = new Random(seedVal);
		for (int i = 0;i < size;i ++) 
			array.set(i, Math.abs(rand.nextLong()) % maxValue);
		
		rand = new Random(seedVal);
		for (int i = 0;i < size;i ++) 
			assertEquals(Math.abs(rand.nextLong()) % maxValue, array.get(i));
	}
	
	/**
	 * Tests basic get and set operations using random 
	 * indices and values, with possible overwrite
	 * 
	 */
	@Test
	public void testRandomIndexSetGet() {
		Random seedGenerator = new Random();
		long seedVal = seedGenerator.nextLong();
		
		int bitNum = 7;
		long maxValue = (int) (Math.pow(2, bitNum) - 1);
		int size = 100000;
		CompactArray array = new CompactArray(size, bitNum);
		long[] arrayHolder = new long[size];
		
		Random rand = new Random(seedVal);
		for (int i = 0;i < 4000;i ++) {
			int index = (int) (Math.abs(rand.nextLong()) % size);
			long value = Math.abs(rand.nextLong()) % maxValue;
			array.set(index, value);
			arrayHolder[index] = value;
		}
		
		for (int i = 0;i < size;i ++) 
			assertEquals(arrayHolder[i], array.get(i));
		
	}
	
	/**
	 * Tests random values with different bit sizes
	 * from 2 to 44
	 */
	@Test
	public void testDifferentBitSize() {
		Random seedGenerator = new Random();
		long seedVal = seedGenerator.nextLong();
		for (int bitNum = 2;bitNum < 45;bitNum ++) {
			long maxValue = (long) (Math.pow(2, bitNum) - 1);
			int size = 100000;
			CompactArray array = new CompactArray(size, bitNum);
			
			Random rand = new Random(seedVal);
			for (int i = 0;i < size;i ++) 
				array.set(i, Math.abs(rand.nextLong()) % maxValue);
			
			rand = new Random(seedVal);
			for (int i = 0;i < size;i ++) 
				assertEquals(Math.abs(rand.nextLong()) % maxValue, array.get(i));
		}
	}
	
	/**
	 * Tests overwrite of values to make sure old data was scrubbed
	 * appropriately 
	 */
	@Test
	public void testOverwrite() {
		int bitNum = 23;
		long maxValue = (long) (Math.pow(2, bitNum) - 1);
		int size = 100000;
		CompactArray array = new CompactArray(size, bitNum);
		for (int k = 0;k < 40;k ++) {
			Random seedGenerator = new Random();
			long seedVal = seedGenerator.nextLong();
			
			Random rand = new Random(seedVal);
			for (int i = 0;i < size;i ++) 
				array.set(i, Math.abs(rand.nextLong()) % maxValue);
			
			rand = new Random(seedVal);
			for (int i = 0;i < size;i ++) 
				assertEquals(Math.abs(rand.nextLong()) % maxValue, array.get(i));
		}
	}
	
	/**
	 * This method runs through most bit sizes and 
	 * tests random values with both a array of longs 
	 * and the compact array. It them prints out the respective
	 * ratios for memory usage, assignment time and access time
	 */
	@Test
	public void testSpeedComparision() {
		for (int bitNum = 2;bitNum < 58;bitNum ++) {
			long maxValue = (long) (Math.pow(2, bitNum) - 1);
			int size = 1000000;
			
			long ca_put = 0, ca_get = 0;
			long na_put = 0, na_get = 0;
			CompactArray array = new CompactArray(size, bitNum);
			long[] normalArray = new long[size];
			
			long checksum1 = 0, checksum2 = 0;
			for (int k = 0;k < 40;k ++) {
				Random seedGenerator = new Random();
				long seedVal = seedGenerator.nextLong();
				
				long start = System.nanoTime();
				Random rand = new Random(seedVal);
				for (int i = 0;i < size;i ++) 
					array.set(i, Math.abs(rand.nextLong()) % maxValue);
				
				ca_put += System.nanoTime() - start;
				
				start = System.nanoTime();
				rand = new Random(seedVal);
				for (int i = 0;i < size;i ++) 
					normalArray[i] = Math.abs(rand.nextLong()) % maxValue;
				
				na_put += System.nanoTime() - start;
				
				start = System.nanoTime();
				for (int i = 0;i < size;i ++) 
					checksum1 += array.get(i);
				
				ca_get += System.nanoTime() - start;
				
				start = System.nanoTime();
				for (int i = 0;i < size;i ++) 
					 checksum2 += normalArray[i];
				
				na_get += System.nanoTime() - start;
			}
			double diff_put = (ca_put) / (double) na_put;
			double diff_get = (ca_get) / (double) na_get;
			
			long size_na = size * Long.SIZE;
			long size_ca = size * bitNum;
			System.out.println("STATS FOR BITSIZE:" + bitNum + " RATIOS OF COMPACT ARRAY TO NORMAL ARRAY OF LONGS");
			System.out.println("MEMORY RATIO:" + size_ca / (double) size_na);
			System.out.println("RATIO BETWEEN ASSIANGMENT:" + diff_put);
			System.out.println("RATIO BETWEEN GET:" + diff_get);
			assertEquals(checksum1, checksum2);
			System.out.println();
		}
	}

}
