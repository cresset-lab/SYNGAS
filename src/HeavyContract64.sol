// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract64 {
    uint256 public constant MAX_ARRAY_SIZE = 100;
    uint256 public totalSum;
    uint256 public heavyCounter;
    uint256[] public largeArray;
    
    mapping(uint256 => uint256) public indexSumMapping;

    constructor() {
        // Initialize the large array with default values
        for (uint256 i = 0; i < MAX_ARRAY_SIZE; i++) {
            largeArray.push(i + 1);
        }
    }

    // Performs a heavy computation by calculating sum of elements with nested loops
    function computeHeavySum() public {
        uint256 sum = 0;
        for (uint256 i = 0; i < MAX_ARRAY_SIZE; i++) {
            for (uint256 j = 0; j < MAX_ARRAY_SIZE; j++) {
                sum += largeArray[i] * largeArray[j];
            }
        }
        totalSum = sum;
    }

    // Increases the elements of the array by the given factor using nested loops
    function multiplyArrayElements(uint256 factor) public {
        for (uint256 i = 0; i < MAX_ARRAY_SIZE; i++) {
            for (uint256 j = 0; j <= i; j++) {
                largeArray[i] *= factor;
            }
        }
    }

    // Updates the `indexSumMapping` with the sum of elements up to the given index
    function updateIndexSumMapping(uint256 index) public {
        require(index < MAX_ARRAY_SIZE, "Index out of bounds");
        uint256 sum = 0;
        for (uint256 i = 0; i <= index; i++) {
            sum += largeArray[i];
        }
        indexSumMapping[index] = sum;
    }

    // Complex calculation altering the state based on input parameters
    function complexCalculation(uint256 iterations, uint256 multiplier) public {
        for (uint256 i = 0; i < iterations; i++) {
            for (uint256 j = 0; j < MAX_ARRAY_SIZE; j++) {
                largeArray[j] = (largeArray[j] * multiplier) % (2**256 - 1);
            }
        }
        heavyCounter += iterations;
    }

    // A recursive-like function pattern by using iterative approach to avoid stack depth issues
    function iterativeCalculation(uint256 depth) public {
        uint256 temp = 1;
        for (uint256 i = 0; i < depth; i++) {
            temp = (temp * largeArray[i % MAX_ARRAY_SIZE]) % (2**256 - 1);
        }
        heavyCounter += temp;
    }
}