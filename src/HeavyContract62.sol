// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract62 {
    uint256 public result;
    mapping(uint256 => uint256) public computedValues;
    uint256[] private heavyArray;
    uint256 public counter;

    constructor() {
        result = 1;
        counter = 1;
        // Initialize heavyArray with some values
        for (uint256 i = 0; i < 50; i++) {
            heavyArray.push(i);
        }
    }

    // Compute factorial in a recursive manner and store intermediate results
    function computeFactorial(uint256 n) public returns (uint256) {
        if (n == 0) {
            return 1;
        }
        if (computedValues[n] != 0) {
            return computedValues[n];
        }
        uint256 value = n * computeFactorial(n - 1);
        computedValues[n] = value; // Store in mapping
        return value;
    }

    // A recursive function that updates a state variable in each call
    function recursiveSum(uint256 n) public returns (uint256) {
        if (n == 0) {
            return result;
        }
        result += n;
        return recursiveSum(n - 1);
    }

    // A function with nested loops that modifies storage variables
    function complexModifier(uint256 iterations) public {
        for (uint256 i = 0; i < iterations; i++) {
            for (uint256 j = 0; j < heavyArray.length; j++) {
                heavyArray[j] += i + j;
                counter += heavyArray[j];
            }
        }
    }

    // A function that computes Fibonacci numbers recursively and stores results
    function computeFibonacci(uint256 n) public returns (uint256) {
        if (n <= 1) {
            return n;
        }
        if (computedValues[n] != 0) {
            return computedValues[n];
        }
        uint256 value = computeFibonacci(n - 1) + computeFibonacci(n - 2);
        computedValues[n] = value; // Store in mapping
        return value;
    }

    // A function that iterates over the array and performs complex operations
    function arrayProcessor(uint256 multiplier) public {
        for (uint256 i = 0; i < heavyArray.length; i++) {
            heavyArray[i] = (heavyArray[i] ** 2) * multiplier;
            result += heavyArray[i];
        }
    }
}