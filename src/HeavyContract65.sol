// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract65 {
    uint256[][] public multiDimArray;
    mapping(address => uint256) public calculations;
    uint256 public stateCounter;

    constructor(uint256 initialSize) {
        for (uint256 i = 0; i < initialSize; i++) {
            uint256[] storage newRow = multiDimArray.push();
            for (uint256 j = 0; j < initialSize; j++) {
                newRow.push(i * j);
            }
        }
        stateCounter = 1;
    }

    // Function to perform heavy computation on a multi-dimensional array
    function computeArraySum(uint256 iterations) public returns (uint256) {
        uint256 sum = 0;
        for (uint256 k = 0; k < iterations; k++) {
            for (uint256 i = 0; i < multiDimArray.length; i++) {
                for (uint256 j = 0; j < multiDimArray[i].length; j++) {
                    sum += multiDimArray[i][j] * (k + 1);
                }
            }
        }
        stateCounter += sum;
        return sum;
    }

    // Recursive function that performs factorial in a gas-inefficient manner
    function recursiveFactorial(uint256 n) public returns (uint256) {
        if (n <= 1) {
            return 1;
        } else {
            uint256 result = n * recursiveFactorial(n - 1);
            stateCounter += result;
            return result;
        }
    }

    // Function to update multi-dimensional array with complex calculations
    function updateArrayValues(uint256 multiplier) public {
        for (uint256 i = 0; i < multiDimArray.length; i++) {
            for (uint256 j = 0; j < multiDimArray[i].length; j++) {
                multiDimArray[i][j] = (multiDimArray[i][j] + multiplier) * stateCounter;
            }
        }
        stateCounter++;
    }
    
    // Function that uses heavy loops and mapping updates
    function calculateAndStore(uint256[] memory data) public {
        uint256 localCounter = 0;
        for (uint256 i = 0; i < data.length; i++) {
            for (uint256 j = i; j < data.length; j++) {
                localCounter += data[j] * (i + 1);
            }
        }
        calculations[msg.sender] = localCounter;
        stateCounter += localCounter;
    }

    // Function to reset the contract's state variables
    function resetState(uint256 newSize) public {
        delete multiDimArray;
        stateCounter = 1;
        for (uint256 i = 0; i < newSize; i++) {
            uint256[] storage newRow = multiDimArray.push();
            for (uint256 j = 0; j < newSize; j++) {
                newRow.push(i + j);
            }
        }
    }
}