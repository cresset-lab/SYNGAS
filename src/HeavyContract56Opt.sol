// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract56Opt {
    uint256[] public dataStorage;
    mapping(uint256 => uint256) public dataMap;
    uint256 public constant MAX_ITERATIONS = 100;
    uint256 public result;
    
    constructor(uint256 initialSize) {
        // Initialize the data storage with a given size
        for (uint256 i = 0; i < initialSize; i++) {
            dataStorage.push(i);
            dataMap[i] = i;
        }
    }

    // Function to perform heavy computation and update state variables
    function computeHeavyMath(uint256 iterations) public {
        uint256 localResult = result;
        uint256 dataStorageLen = dataStorage.length;
        for (uint256 i = 0; i < iterations; i++) {
            for (uint256 j = 0; j < dataStorageLen; j++) {
                uint256 value = dataStorage[j];
                value = (value + j * i) % (iterations + 1);
                dataStorage[j] = value;
                localResult = (localResult + value * i) % (iterations + 1);
            }
        }
        result = localResult;
    }

    // Function to perform a nested loop calculation
    function nestedLoopCalculation() public {
        uint256 tempResult = result;
        uint256 dataStorageLen = dataStorage.length;
        for (uint256 i = 0; i < MAX_ITERATIONS; i++) {
            for (uint256 j = 0; j < dataStorageLen; j++) {
                uint256 valueJ = dataStorage[j];
                for (uint256 k = 0; k < dataStorageLen; k++) {
                    uint256 valueK = dataStorage[k];
                    tempResult = (tempResult + valueJ * valueK) % (MAX_ITERATIONS + 1);
                }
            }
        }
        result = tempResult;
    }

    // Function to calculate with recursion
    function recursiveCalculation(uint256 depth, uint256 number) public {
        require(depth > 0, "Depth must be greater than 0");
        result = recursiveHelper(depth, number);
    }

    function recursiveHelper(uint256 depth, uint256 number) internal returns (uint256) {
        if (depth == 0) return number;
        uint256 newNumber = (number * depth + number / (depth + 1)) % (depth + 1);
        return recursiveHelper(depth - 1, newNumber);
    }

    // Function to perform a mapping intensive computation
    function mappingComputation(uint256 multiplier, uint256 divisor) public {
        uint256 dataStorageLen = dataStorage.length;
        for (uint256 i = 0; i < dataStorageLen; i++) {
            uint256 value = dataMap[i];
            value = (value * multiplier / (divisor + 1)) % (multiplier + 1);
            dataMap[i] = value;
        }
    }

    // Function to update dataStorage with complex operations
    function updateDataStorage(uint256 factor, uint256 increment) public {
        uint256 dataStorageLen = dataStorage.length;
        for (uint256 i = 0; i < dataStorageLen; i++) {
            uint256 newValue = (dataStorage[i] * factor + increment) % (factor + 1);
            dataStorage[i] = newValue;
        }
    }
}