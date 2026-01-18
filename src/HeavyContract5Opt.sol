// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract5Opt {
    uint256[] public data;
    mapping(address => uint256) public balances;
    uint256 public totalSum;
    uint256 public lastProcessedIndex;

    constructor(uint256 initialSize) {
        // Initialize the data array with some values
        data = new uint256[](initialSize); // Preallocate size
        for (uint256 i = 0; i < initialSize; i++) {
            data[i] = i;
        }
    }

    // Function to process data array and update totalSum
    function processData() public {
        uint256 sum = 0;
        uint256 dataLength = data.length;
        for (uint256 i = 0; i < dataLength; i++) {
            uint256 val = data[i] * 2;
            sum += data[i];
            data[i] = val; // State mutation
        }
        totalSum = sum;
    }

    // Function to update balances with a complex nested loop
    function updateBalances(uint256 times) public {
        address sender = msg.sender;
        uint256 balance = balances[sender];
        uint256 dataLength = data.length;
        for (uint256 i = 0; i < dataLength; i++) {
            uint256 dataValue = data[i] * times;
            balance += dataValue;
        }
        balances[sender] = balance;
    }

    // Function to manipulate array data with a recursive pattern
    function recursiveArrayManipulation(uint256 index) public returns (uint256) {
        if (index >= data.length) {
            return 0;
        }

        uint256 newValue = data[index] + 1;
        data[index] = newValue; // State mutation
        return newValue + recursiveArrayManipulation(index + 1);
    }

    // Function to perform a heavy computation with nested loops
    function computeHeavy(uint256 depth) public {
        uint256 counter = 0;
        uint256 dataLength = data.length;
        for (uint256 i = 0; i < dataLength; i++) {
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