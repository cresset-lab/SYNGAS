// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract35 {
    uint256[][] public multiArray;
    uint256 public lastComputedValue;
    mapping(uint256 => uint256) public computationResults;
    uint256 public computationCounter;
    
    constructor() {
        computationCounter = 0;
    }

    // Initialize a multi-dimensional array with arbitrary values
    function initializeMultiArray(uint256 size) public {
        delete multiArray;
        for (uint256 i = 0; i < size; i++) {
            uint256[] memory innerArray = new uint256[](size);
            for (uint256 j = 0; j < size; j++) {
                innerArray[j] = (i + 1) * (j + 1);
            }
            multiArray.push(innerArray);
        }
    }
    
    // Perform a complex computation on the multi-dimensional array elements
    function computeProductSum() public {
        uint256 sum = 0;
        for (uint256 i = 0; i < multiArray.length; i++) {
            for (uint256 j = 0; j < multiArray[i].length; j++) {
                sum += (multiArray[i][j] * (i + 1) * (j + 1));
            }
        }
        lastComputedValue = sum;
        computationResults[computationCounter] = sum;
        computationCounter++;
    }

    // A recursive function to perform an arbitrary heavy calculation
    function recursiveCalculation(uint256 n) public returns (uint256) {
        if (n == 0) {
            return 1;
        }
        uint256 result = n + recursiveCalculation(n - 1);
        lastComputedValue = result;
        computationResults[computationCounter] = result;
        computationCounter++;
        return result;
    }

    // Function to compute the factorial of a number using heavy looping
    function computeFactorial(uint256 n) public {
        uint256 factorial = 1;
        for (uint256 i = 1; i <= n; i++) {
            factorial *= i;
        }
        lastComputedValue = factorial;
        computationResults[computationCounter] = factorial;
        computationCounter++;
    }

    // Function to find the maximum value in the multi-dimensional array
    function findMaxValue() public {
        uint256 maxValue = 0;
        for (uint256 i = 0; i < multiArray.length; i++) {
            for (uint256 j = 0; j < multiArray[i].length; j++) {
                if (multiArray[i][j] > maxValue) {
                    maxValue = multiArray[i][j];
                }
            }
        }
        lastComputedValue = maxValue;
        computationResults[computationCounter] = maxValue;
        computationCounter++;
    }
}