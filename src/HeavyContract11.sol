// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract11 {

    uint256[] public largeArray;
    mapping(uint256 => uint256) public dataMap;
    uint256 public constant MAX_ITERATIONS = 100;
    uint256 public stateCounter;
    uint256 public lastUpdate;

    constructor() {
        // Initialize with some data
        for (uint256 i = 0; i < MAX_ITERATIONS; i++) {
            largeArray.push(i);
            dataMap[i] = i * 2;
        }
    }

    // Function that performs a heavy computation on the array
    function processArray(uint256 factor) public {
        for (uint256 i = 0; i < largeArray.length; i++) {
            uint256 temp = largeArray[i] * factor;
            largeArray[i] = temp / (factor + 1);
            stateCounter += temp % 3;
        }
    }

    // Function that modifies the mapping heavily
    function updateMapping(uint256 start, uint256 end, uint256 increment) public {
        require(start < end && end <= MAX_ITERATIONS, "Invalid range");
        for (uint256 i = start; i < end; i++) {
            dataMap[i] = (dataMap[i] + increment) % (MAX_ITERATIONS * 2);
            stateCounter += dataMap[i] % 5;
        }
    }

    // Nested loops for more intensive computation
    function nestedComputation(uint256 depth) public {
        for (uint256 i = 0; i < depth; i++) {
            for (uint256 j = 0; j < largeArray.length; j++) {
                uint256 val = largeArray[j];
                for (uint256 k = 0; k < 5; k++) {
                    val = (val * 3 + j - k) % (i + 1);
                }
                largeArray[j] = val;
            }
            stateCounter += 1;
        }
    }

    // Recursive function adding to the gas cost
    function recursiveSum(uint256 n) public returns (uint256) {
        if (n == 0) {
            return 0;
        }
        stateCounter += 1;
        return n + recursiveSum(n - 1);
    }

    // Function that updates state variables extensively
    function updateStateVariables(uint256 newValue) public {
        uint256 temp = newValue;
        for (uint256 i = 0; i < largeArray.length; i++) {
            temp = (temp + largeArray[i] * i) % (largeArray.length + 1);
        }
        stateCounter = temp;
        lastUpdate = block.timestamp;
    }
}