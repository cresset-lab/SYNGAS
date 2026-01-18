// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract24 {
    mapping(uint256 => uint256) public dataMapping;
    uint256[] public dataArray;
    uint256 public constant LIMIT = 100;

    // Populate the dataMapping with dummy operations
    function populateMapping(uint256 iterations) public {
        for (uint256 i = 0; i < iterations; i++) {
            dataMapping[i] = i;
        }
    }

    // Function to perform nested operations that are gas heavy
    function complexComputation(uint256[] calldata input) public {
        for (uint256 i = 0; i < input.length; i++) {
            uint256 value = input[i];
            for (uint256 j = 0; j < LIMIT; j++) {
                value = (value * value + j) % LIMIT;
            }
            dataMapping[i] = value;
        }
    }

    // Function to manipulate dataArray with nested computations
    function manipulateArray(uint256 iterations) public {
        for (uint256 i = 0; i < iterations; i++) {
            dataArray.push(i);
            for (uint256 j = 0; j < dataArray.length; j++) {
                dataArray[j] = (dataArray[j] + i) % LIMIT;
            }
        }
    }

    // Recursive function that heavily utilizes storage
    function recursiveStore(uint256 depth, uint256 value) public {
        if (depth == 0) {
            return;
        }
        dataMapping[depth] = value;
        recursiveStore(depth - 1, value * 2);
    }

    // Function that combines nested loops with mapping updates
    function mappingArrayInteraction(uint256 size) public {
        for (uint256 i = 0; i < size; i++) {
            for (uint256 j = 0; j < size; j++) {
                dataMapping[i] = j;
                dataArray.push(j);
            }
        }
    }
}