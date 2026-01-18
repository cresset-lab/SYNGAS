// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract12Opt {
    uint256[] public data;
    mapping(uint256 => uint256) public computedData;
    uint256 public constant MULTIPLIER = 42;
    uint256 public totalComputations;
    
    // Add data to the array for processing
    function addData(uint256[] calldata newData) public {
        uint256 newDataLength = newData.length;
        for (uint256 i = 0; i < newDataLength; ) {
            data.push(newData[i]);
            unchecked { ++i; }
        }
    }

    // Perform bitwise operations and complex calculations on data
    function processBitwiseOperations() public {
        uint256 dataLength = data.length;
        for (uint256 i = 0; i < dataLength; ) {
            uint256 value = data[i];
            for (uint256 j = 0; j < 256; ) {
                value = (value >> 1) | ((value & 1) << 255);
                unchecked { ++j; }
            }
            computedData[i] = value;
            unchecked { ++i; }
        }
    }

    // Multi-layered loop to perform heavy computations
    function performComplexCalculations(uint256 iterations) public {
        uint256 dataLength = data.length;
        for (uint256 i = 0; i < iterations; ) {
            for (uint256 j = 0; j < dataLength; ) {
                uint256 value = data[j];
                uint256 result = 0;
                for (uint256 k = 0; k < 64; ) {
                    result += (value ^ (value >> k) + MULTIPLIER * k);
                    unchecked { ++k; }
                }
                computedData[j] = result;
                unchecked {
                    ++totalComputations;
                    ++j;
                }
            }
            unchecked { ++i; }
        }
    }

    // Recursive function to compute a Fibonacci-like sequence
    function recursiveComputation(uint256 n) public returns (uint256) {
        if (n == 0) return 0;
        if (n == 1) return 1;
        uint256 result = recursiveComputation(n - 1) + recursiveComputation(n - 2);
        computedData[n] = result;
        totalComputations++;
        return result;
    }

    // Function that mixes array manipulation with bitwise operations
    function mixArrayAndBitwise(uint256 seed) public {
        uint256 dataLength = data.length;
        for (uint256 i = 0; i < dataLength; ) {
            uint256 value = data[i] * seed;
            for (uint256 j = 0; j < 32; ) {
                value ^= (value << j) | (value >> (256 - j));
                unchecked { ++j; }
            }
            computedData[i] = value;
            unchecked { ++i; }
        }
        totalComputations += dataLength;
    }
}