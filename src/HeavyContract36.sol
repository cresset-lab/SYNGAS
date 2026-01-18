// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract36 {
    uint256[] public dataArray;
    mapping(uint256 => uint256) public dataMap;
    uint256 public constant MAX_ITERATIONS = 100;
    uint256 public result;
    uint256 public sum;
    
    constructor() {
        // Initialize dataArray with some values for testing
        for (uint256 i = 0; i < MAX_ITERATIONS; i++) {
            dataArray.push(i);
            dataMap[i] = i * 2;
        }
    }

    // Function to perform intensive array iteration and summation
    function computeSum() public {
        sum = 0;
        for (uint256 i = 0; i < dataArray.length; i++) {
            for (uint256 j = 0; j < i; j++) {
                sum += dataArray[j] * (dataArray[i] + dataMap[j]);
            }
        }
    }

    // Recursive function to calculate factorial, inherently gas-intensive
    function factorial(uint256 n) public returns (uint256) {
        if (n == 0) {
            return 1;
        } else {
            uint256 fact = factorial(n - 1);
            result = n * fact;
            return result;
        }
    }

    // Function that performs nested looping with state mutation
    function nestedLoopModification(uint256 multiplier, uint256 adder) public {
        for (uint256 i = 0; i < dataArray.length; i++) {
            for (uint256 j = i; j < dataArray.length; j++) {
                dataMap[j] = (dataArray[j] * multiplier) + adder;
            }
        }
    }

    // Function to simulate complex mathematical operation with array
    function complexMathOperation(uint256 base, uint256 exponent) public {
        for (uint256 i = 0; i < dataArray.length; i++) {
            uint256 powerResult = 1;
            for (uint256 j = 0; j < exponent; j++) {
                powerResult *= base;
            }
            dataArray[i] = powerResult + dataMap[i];
        }
    }

    // Public function to perform large number of state variable updates
    function intensiveStateUpdates(uint256 iterations) public {
        for (uint256 i = 0; i < iterations; i++) {
            dataMap[i % MAX_ITERATIONS] = (dataMap[i % MAX_ITERATIONS] + i) % MAX_ITERATIONS;
            dataArray[i % MAX_ITERATIONS] = (dataArray[i % MAX_ITERATIONS] * i) % MAX_ITERATIONS;
            result = (result + dataArray[i % MAX_ITERATIONS]) % MAX_ITERATIONS;
        }
    }
}