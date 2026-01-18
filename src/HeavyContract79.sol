// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract79 {
    
    uint256 public result;
    uint256[] public data;
    mapping(uint256 => uint256) public factorialResults;

    constructor() {
        result = 0;
    }

    // Function to simulate heavy computation by calculating factorials
    function computeFactorial(uint256 n) public {
        uint256 fact = 1;
        for (uint256 i = 1; i <= n; i++) {
            fact *= i;
            factorialResults[i] = fact; // Store intermediate results
        }
        result = fact;
    }

    // Function to perform operations on an array and update a state variable
    function processArray(uint256[] memory inputArray) public {
        uint256 sum = 0;
        for (uint256 i = 0; i < inputArray.length; i++) {
            for (uint256 j = 0; j < inputArray.length; j++) {
                if (i != j) {
                    sum += inputArray[i] * inputArray[j];
                }
            }
        }
        data = inputArray;
        result = sum;
    }

    // Function with nested loops and complex math operations
    function complexCalculation(uint256 limit) public {
        uint256 total = 0;
        for (uint256 i = 1; i <= limit; i++) {
            for (uint256 j = 1; j <= i; j++) {
                total += (i ** 2 + j ** 2) % (i + j);
            }
        }
        result = total;
    }

    // Recursive function to create a computationally heavy task
    function recursiveFib(uint256 n) public returns (uint256) {
        if (n <= 1) {
            return n;
        }
        uint256 fibResult = recursiveFib(n - 1) + recursiveFib(n - 2);
        result = fibResult;
        return fibResult;
    }

    // Function with a while loop and updates state variables
    function heavyWhileLoop(uint256 iterations) public {
        uint256 i = 0;
        uint256 total = 0;
        while (i < iterations) {
            total += i * i;
            i++;
        }
        result = total;
    }
}