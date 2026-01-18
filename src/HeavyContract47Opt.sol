// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract47Opt {
    uint256 public constant MAX_ITERATIONS = 100;
    uint256 public stateCounter;
    mapping(uint256 => uint256) public data;

    constructor() {
        stateCounter = 1;
    }

    // Function to compute factorial recursively with storage operations
    function recursiveFactorial(uint256 n) public returns (uint256) {
        uint256 result;
        if (n == 0) {
            result = 1;
        } else {
            result = n * recursiveFactorial(n - 1);
        }
        data[stateCounter] = result;
        stateCounter++;
        return result;
    }

    // Function to perform power calculations with a loop
    function powerCalculation(uint256 base, uint256 exponent) public returns (uint256) {
        uint256 result = 1;
        for (uint256 i = 0; i < exponent; i++) {
            result *= base;
            data[stateCounter] = result;
            stateCounter++;
        }
        return result;
    }

    // Function for complex validation through nested loops
    function complexValidation(uint256[] calldata numbers) public returns (bool) {
        uint256 length = numbers.length; // cache array length
        for (uint256 i = 0; i < length; i++) {
            for (uint256 j = i + 1; j < length; j++) {
                if (numbers[i] == numbers[j]) {
                    data[stateCounter] = 0;
                    stateCounter++;
                    return false;
                }
                data[stateCounter] = numbers[i] + numbers[j];
                stateCounter++;
            }
        }
        data[stateCounter] = 1;
        stateCounter++;
        return true;
    }

    // Function that uses a nested loop and multiple storage updates
    function intensiveComputation(uint256 start, uint256 end) public returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = start; i < end; i++) {
            for (uint256 j = 0; j < MAX_ITERATIONS; j++) {
                sum += i * j;
                data[stateCounter] = sum;
                stateCounter++;
            }
        }
        return sum;
    }

    // Recursive function with state updates
    function recursiveSum(uint256[] calldata numbers, uint256 index) public returns (uint256) {
        if (index >= numbers.length) {
            return 0;
        }
        uint256 currentValue = numbers[index];
        data[stateCounter] = currentValue;
        stateCounter++;
        return currentValue + recursiveSum(numbers, index + 1);
    }
}