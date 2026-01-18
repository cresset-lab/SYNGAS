// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract30 {
    uint256[] public dataArray;
    mapping(uint256 => uint256) public dataMap;
    uint256 public dataCounter;
    uint256 public constant MAX_ITERATIONS = 100;

    constructor(uint256 initialSize) {
        // Initialize the dataArray with some values
        for (uint256 i = 0; i < initialSize; i++) {
            dataArray.push(i);
        }
    }

    // Function to fill the array with a sequence of numbers
    function fillArray(uint256 newSize) public {
        for (uint256 i = dataArray.length; i < newSize; i++) {
            dataArray.push(i * 2);
        }
    }

    // Function to perform nested loop calculations and store results
    function intensiveCalculation(uint256 multiplier) public {
        for (uint256 i = 0; i < dataArray.length; i++) {
            for (uint256 j = 0; j < MAX_ITERATIONS; j++) {
                dataMap[i] = dataMap[i] + ((dataArray[i] * multiplier + j) % MAX_ITERATIONS);
            }
        }
    }

    // Function to simulate recursive-like pattern using loops
    function recursivePattern(uint256 depth) public {
        for (uint256 i = 0; i < depth; i++) {
            for (uint256 j = 0; j < dataArray.length; j++) {
                dataMap[j] = recursiveSum(j, depth);
            }
        }
    }

    // Helper function to perform a pseudo-recursive sum
    function recursiveSum(uint256 index, uint256 count) internal returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < count; i++) {
            sum += (dataArray[index] + i) % MAX_ITERATIONS;
        }
        return sum;
    }

    // Function to update dataCounter and dataArray based on calculations
    function updateDataCounter(uint256 increment) public {
        for (uint256 i = 0; i < dataArray.length; i++) {
            dataCounter += (dataArray[i] + increment) % MAX_ITERATIONS;
        }
        for (uint256 j = 0; j < MAX_ITERATIONS; j++) {
            dataCounter = (dataCounter * j) % MAX_ITERATIONS;
        }
    }

    // Function to manipulate dataMap with complex operations
    function complexDataManipulation(uint256 times) public {
        for (uint256 i = 0; i < times; i++) {
            for (uint256 j = 0; j < dataArray.length; j++) {
                dataMap[j] = (dataMap[j] * i + dataArray[j]) % MAX_ITERATIONS;
            }
        }
    }
}