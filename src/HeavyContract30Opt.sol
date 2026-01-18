
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract30Opt {
    uint256[] public dataArray;
    mapping(uint256 => uint256) public dataMap;
    uint256 public dataCounter;
    uint256 public constant MAX_ITERATIONS = 100;

    constructor(uint256 initialSize) {
        // Initialize the dataArray with some values
        unchecked {
            for (uint256 i = 0; i < initialSize; i++) {
                dataArray.push(i);
            }
        }
    }

    // Function to fill the array with a sequence of numbers
    function fillArray(uint256 newSize) public {
        uint256 length = dataArray.length;
        unchecked {
            for (uint256 i = length; i < newSize; i++) {
                dataArray.push(i * 2);
            }
        }
    }

    // Function to perform nested loop calculations and store results
    function intensiveCalculation(uint256 multiplier) public {
        unchecked {
            for (uint256 i = 0; i < dataArray.length; i++) {
                for (uint256 j = 0; j < MAX_ITERATIONS; j++) {
                    dataMap[i] += (dataArray[i] * multiplier + j) % MAX_ITERATIONS;
                }
            }
        }
    }

    // Function to simulate recursive-like pattern using loops
    function recursivePattern(uint256 depth) public {
        uint256 length = dataArray.length;
        for (uint256 i = 0; i < depth; i++) {
            for (uint256 j = 0; j < length; j++) {
                dataMap[j] = recursiveSum(j, depth);
            }
        }
    }

    // Helper function to perform a pseudo-recursive sum
    function recursiveSum(uint256 index, uint256 count) internal view returns (uint256) {
        uint256 sum = 0;
        unchecked {
            for (uint256 i = 0; i < count; i++) {
                sum += (dataArray[index] + i) % MAX_ITERATIONS;
            }
        }
        return sum;
    }

    // Function to update dataCounter and dataArray based on calculations
    function updateDataCounter(uint256 increment) public {
        uint256 length = dataArray.length;
        unchecked {
            for (uint256 i = 0; i < length; i++) {
                dataCounter += (dataArray[i] + increment) % MAX_ITERATIONS;
            }
            for (uint256 j = 0; j < MAX_ITERATIONS; j++) {
                dataCounter = (dataCounter * j) % MAX_ITERATIONS;
            }
        }
    }

    // Function to manipulate dataMap with complex operations
    function complexDataManipulation(uint256 times) public {
        uint256 length = dataArray.length;
        unchecked {
            for (uint256 i = 0; i < times; i++) {
                for (uint256 j = 0; j < length; j++) {
                    dataMap[j] = (dataMap[j] * i + dataArray[j]) % MAX_ITERATIONS;
                }
            }
        }
    }
}
