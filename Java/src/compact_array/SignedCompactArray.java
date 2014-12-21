package compact_array;

import java.util.Arrays;
import java.util.Iterator;

/**
 * @author Nicholas
 *
 * An fixed size array for compacting signed numbers into an array. This 
 * class allows you to specify the size of the array (in elements) and
 * the max amount of bits that a number will have. For example if you only need
 * to store 20 bit numbers, an array of ints would be a bit wasteful. By using this
 * array you could achieve the optimal space usage, without sacrificing too much speed.
 * 
 * This implementation is different than UnsignedCompactArray in that it
 * provides an extra bit to determine the size. This also leads the implementation 
 * to be significantly slower than the unsigned version, because the possibility of required
 * negation (an extra conditional statement)
 * 
 * This class also implements the Iterable interface (allowing it to be used in
 * the "new" for loop) however this can be a bit slow, since the value
 * needs to be autoboxed into a Long object: THEREFOR IT IS MUCH MORE EFFICIENT
 * TO LOOP THROUGH AN ARRAY USING AN int COUNTER: for (int i = 0;...;i++) array.get(i)
 * 
 * I have provided a file with fairly comprehensive test cases if you wish to fiddle
 * around with the code, as well as an overall speed test to compare with an array 
 * of longs. After some basic profiling on my machine (Macbook Pro 2012 (?)) running
 * java 7, I found assignment to range from 5 to 15% slower than normal arrays (fairly negligible),
 *  while accessing can be anywhere from 10 to 18 times slower (depending on bit size). However,
 * depending on the needs, the saved space can outweigh, the time delay for access.
 * ALSO NOTE: Array lookups are extremely fast, so even 10 to 18 times slower is still
 * very fast and that statistic can be misleading.
 *
 */
public class SignedCompactArray implements Iterable<Long> {

	//our array of values
	private long[] array;
	//the size in elements
	private long size;
	
	//the max bits per element spot
	private int bitCount;
	//a bit mask of bitCount 1's
	private long bitMask;
	
	private long signMask;
	private long negativeMask;
	
	/**
	 * Utility method to calculate the amount of bits for a given value. Note
	 * that worst case for max values is powers of 2 since that will require 1 
	 * extra bit
	 * 
	 * @param max_value the max value
	 * @return the amount of bits to represent the value (doesn't include the sign bit)
	 */
	public static int calcuateBitsNeeded(int max_value) {
		return (int) (Math.log(max_value) / Math.log(2)) + ((max_value & (max_value - 1)) == 0 ? 0 : 1);
	}
	
	/**
	 * Constructs an array of that can hold max_size elements
	 * with each element only requiring max_bits.
	 * 
	 * @param max_size the amount of elements
	 * @param max_bits the amount of bits per element
	 */
	public SignedCompactArray(long max_size, int max_bits) {
		bitCount = max_bits + 1;
		assert(bitCount < Long.SIZE);
		for (int i = 0;i < bitCount;i ++)
			bitMask |= 1L << i;
		
		signMask = 1L << (bitCount - 1);
		negativeMask = ~0 & ~bitMask; 
		
		size = max_size;
		array = new long[(int) (max_size * bitCount / Long.SIZE + 1)];
	}

	/**
	 * Sets the value in the array at the given index to 
	 * the value of element. Note, element must not be negative
	 * and must be less than 2^maxBits
	 * 
	 * @param index the element position
	 * @param element the value
	 */
	public void set(int index, long element) {
		assert(index < size);
		assert(element < (bitCount << bitCount));
		
		int adj_index = (index * bitCount) / Long.SIZE; //get array position
		int mod_index = (index * bitCount) % Long.SIZE; //get bit offset
		int left_over = mod_index + bitCount - Long.SIZE; //overflow into next array spot
		if (left_over <= 0) { //no overflow, just set within the one array spot
			array[adj_index] &= ~((bitMask) << mod_index); //clear spot
			array[adj_index] |= (element & bitMask) << mod_index; //set value
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
			array[adj_index] &= ~(((bitMask) >>> left_over) << mod_index);
			//extract the upper half from element and store it
			array[adj_index] |= ((element & bitMask) >>> left_over) << mod_index;
			
			//extract lower half of element which is currently shifted completly left
			long left_over_val = (element & bitMask) << (Long.SIZE - left_over);
			//clear our spot
			array[adj_index + 1] &= ~(bitMask >>> (bitCount - left_over));
			//shift it left to store
			array[adj_index + 1] |= left_over_val >>> (Long.SIZE - left_over);
		}
	}
	
	/**
	 * Given an index, this method returns the element
	 * at that index. Note this will always return a value < 2^maxBits
	 * 
	 * @param index position of element
	 * @return the value at index
	 */
	public long get(int index) {
		assert(index < size);
		
		//see set(...) for implementation details of how the storing of
		//of values works, this is just the opposite.
		int adj_index = (index * bitCount) / Long.SIZE;
		int mod_index = (index * bitCount) % Long.SIZE;
		int left_over = mod_index + bitCount - Long.SIZE;
		if (left_over <= 0) {
			long retVal = (array[adj_index] >> mod_index) & bitMask;
			if ((retVal & signMask) != 0) return retVal | negativeMask;
			
			return retVal;
		} else {
			long retVal = 0;
			retVal |= (array[adj_index] >>> mod_index) << left_over;
			retVal |= (array[adj_index + 1] << (Long.SIZE - left_over)) >>> (Long.SIZE - left_over);
			if ((retVal & signMask) != 0) return retVal | negativeMask;
			
			return retVal;
		}
	}
	
	/**
	 * 
	 * @return the size of elements in the array, will always be the same
	 */
	public long size() { 
		return size;
	}
	
	@Override
	public Iterator<Long> iterator() {
		Iterator<Long> it = new Iterator<Long>() {

            private int currentIndex = 0;

            @Override
            public boolean hasNext() {
                return currentIndex < size();
            }

            @Override
            public Long next() {
                return get(currentIndex ++);
            }

            @Override
            public void remove() { }
        };
        return it;
	}
	
}
