// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract5 {
    uint256[] public data;
    mapping(address => uint256) public balances;
    uint256 public totalSum;
    uint256 public lastProcessedIndex;

    constructor(uint256 initialSize) {
        // Initialize the data array with some values
        for (uint256 i = 0; i < initialSize; i++) {
            data.push(i);
        }
    }

    // Function to process data array and update totalSum
    function processData() public {
        uint256 sum = 0;
        for (uint256 i = 0; i < data.length; i++) {
            sum += data[i];
            data[i] = data[i] * 2; // State mutation
        }
        totalSum = sum;
    }

    // Function to update balances with a complex nested loop
    function updateBalances(uint256 times) public {
        for (uint256 i = 0; i < data.length; i++) {
            for (uint256 j = 0; j < times; j++) {
                balances[msg.sender] += data[i];
            }
        }
    }

    // Function to manipulate array data with a recursive pattern
    function recursiveArrayManipulation(uint256 index) public returns (uint256) {
        if (index >= data.length) {
            return 0;
        }

        data[index] = data[index] + 1; // State mutation
        return data[index] + recursiveArrayManipulation(index + 1);
    }

    // Function to perform a heavy computation with nested loops
    function computeHeavy(uint256 depth) public {
        uint256 counter = 0;
        for (uint256 i = 0; i < data.length; i++) {
            for (uint256 j = 0; j < depth; j++) {
                counter += i * j;
            }
        }
        totalSum = counter; // Update state variable
    }

    // Function to reset data array for a certain range
    function resetData(uint256 from, uint256 to) public {
        require(from < to && to <= data.length, "Invalid range");

        for (uint256 i = from; i < to; i++) {
            data[i] = 0; // Reset the value, state mutation
        }
    }
}