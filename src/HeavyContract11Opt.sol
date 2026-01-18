// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract11Opt {

    uint256[] public largeArray;
    mapping(uint256 => uint256) public dataMap;
    uint256 public constant MAX_ITERATIONS = 100;
    uint256 public stateCounter;
    uint256 public lastUpdate;

    constructor() {
        // Initialize with some data
        for (uint256 i = 0; i < MAX_ITERATIONS; ) {
            largeArray.push(i);
            dataMap[i] = i * 2;
            unchecked { ++i; }
        }
    }

    // Function that performs a heavy computation on the array
    function processArray(uint256 factor) public {
        uint256 largeArrayLength = largeArray.length;
        uint256 newStateCounter = stateCounter;
        for (uint256 i = 0; i < largeArrayLength; ) {
            uint256 temp = largeArray[i] * factor;
            largeArray[i] = temp / (factor + 1);
            newStateCounter += temp % 3;
            unchecked { ++i; }
        }
        stateCounter = newStateCounter;
    }

    // Function that modifies the mapping heavily
    function updateMapping(uint256 start, uint256 end, uint256 increment) public {
        require(start < end && end <= MAX_ITERATIONS, "Invalid range");
        uint256 newStateCounter = stateCounter;
        for (uint256 i = start; i < end; ) {
            uint256 newData = (dataMap[i] + increment) % (MAX_ITERATIONS * 2);
            dataMap[i] = newData;
            newStateCounter += newData % 5;
            unchecked { ++i; }
        }
        stateCounter = newStateCounter;
    }

    // Nested loops for more intensive computation
    function nestedComputation(uint256 depth) public {
        uint256 largeArrayLength = largeArray.length;
        uint256 newStateCounter = stateCounter;
        for (uint256 i = 0; i < depth; ) {
            for (uint256 j = 0; j < largeArrayLength; ) {
                uint256 val = largeArray[j];
                for (uint256 k = 0; k < 5; ) {
                    val = (val * 3 + j - k) % (i + 1);
                    unchecked { ++k; }
                }
                largeArray[j] = val;
                unchecked { ++j; }
            }
            unchecked { ++newStateCounter; ++i; }
        }
        stateCounter = newStateCounter;
    }

    // Recursive function adding to the gas cost
    function recursiveSum(uint256 n) public returns (uint256) {
        if (n == 0) {
            return 0;
        }
        unchecked { stateCounter += 1; }
        return n + recursiveSum(n - 1);
    }

    // Function that updates state variables extensively
    function updateStateVariables(uint256 newValue) public {
        uint256 temp = newValue;
        uint256 largeArrayLength = largeArray.length;
        for (uint256 i = 0; i < largeArrayLength; ) {
            temp = (temp + largeArray[i] * i) % (largeArrayLength + 1);
            unchecked { ++i; }
        }
        stateCounter = temp;
        lastUpdate = block.timestamp;
    }
}