// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract47 {
    uint256 public constant MAX_ITERATIONS = 100;
    uint256 public stateCounter;
    mapping(uint256 => uint256) public data;

    constructor() {
        stateCounter = 1;
    }

    // Function to compute factorial recursively with storage operations
    function recursiveFactorial(uint256 n) public returns (uint256) {
        // Store and update stateCounter to induce SSTORE operations
        stateCounter++;
        if (n == 0) {
            data[stateCounter] = 1;
            return 1;
        } else {
            data[stateCounter] = n * recursiveFactorial(n - 1);
            return data[stateCounter];
        }
    }

    // Function to perform power calculations with a loop
    function powerCalculation(uint256 base, uint256 exponent) public returns (uint256) {
        uint256 result = 1;
        for (uint256 i = 0; i < exponent; i++) {
            result *= base;
            // Store intermediate results
            data[stateCounter] = result;
            stateCounter++;
        }
        return result;
    }

    // Function for complex validation through nested loops
    function complexValidation(uint256[] memory numbers) public returns (bool) {
        for (uint256 i = 0; i < numbers.length; i++) {
            for (uint256 j = i + 1; j < numbers.length; j++) {
                if (numbers[i] == numbers[j]) {
                    data[stateCounter] = 0; // Invalidate state
                    stateCounter++;
                    return false;
                }
                // Store intermediate states
                data[stateCounter] = numbers[i] + numbers[j];
                stateCounter++;
            }
        }
        data[stateCounter] = 1; // Validation success
        stateCounter++;
        return true;
    }

    // Function that uses a nested loop and multiple storage updates
    function intensiveComputation(uint256 start, uint256 end) public returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = start; i < end; i++) {
            for (uint256 j = 0; j < MAX_ITERATIONS; j++) {
                sum += i * j; // Complex calculation
                data[stateCounter] = sum; // Store each result
                stateCounter++;
            }
        }
        return sum;
    }

    // Recursive function with state updates
    function recursiveSum(uint256[] memory numbers, uint256 index) public returns (uint256) {
        if (index >= numbers.length) {
            return 0;
        }
        // Store the index and value
        data[stateCounter] = numbers[index];
        stateCounter++;
        return numbers[index] + recursiveSum(numbers, index + 1);
    }
}