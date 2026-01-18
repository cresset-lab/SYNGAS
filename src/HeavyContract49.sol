// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract49 {
    mapping(uint256 => uint256) public validationResults;
    uint256[] public data;
    uint256 public resultCounter;
    uint256 public constant MAX_ITERATIONS = 1000;

    constructor() {
        // Initialize the data array with some values
        for (uint256 i = 0; i < 100; i++) {
            data.push(i);
        }
    }

    // Basic function to simulate heavy computation with nested loops
    function heavyComputation(uint256 input) public returns (uint256) {
        uint256 localResult = 0;
        for (uint256 i = 0; i < MAX_ITERATIONS; i++) {
            for (uint256 j = 0; j < data.length; j++) {
                localResult += (data[j] + input) * (i + j);
            }
        }
        validationResults[resultCounter++] = localResult;
        return localResult;
    }

    // Function with complex checks and nested storage operations
    function validateData(uint256 threshold) public returns (bool) {
        bool isValid = true;
        for (uint256 i = 0; i < data.length; i++) {
            for (uint256 j = i; j < data.length; j++) {
                if (data[i] + data[j] > threshold) {
                    isValid = false;
                }
            }
        }
        if (isValid) {
            validationResults[resultCounter++] = 1;
        } else {
            validationResults[resultCounter++] = 0;
        }
        return isValid;
    }

    // Recursive function for demonstration purposes
    function factorial(uint256 n) public pure returns (uint256) {
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    }

    // External function calling a recursive function to create a heavy computation
    function computeFactorials(uint256 maxFactorial) public returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 1; i <= maxFactorial; i++) {
            total += factorial(i);
        }
        validationResults[resultCounter++] = total;
        return total;
    }

    // A complex state-updating function with storage-intensive operations
    function complexUpdate(uint256 multiplier) public {
        for (uint256 i = 0; i < data.length; i++) {
            for (uint256 j = 0; j < i; j++) {
                data[i] = (data[i] + data[j]) * multiplier;
            }
        }
    }
}