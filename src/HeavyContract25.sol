// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract25 {
    uint256[] private data;
    mapping(uint256 => uint256) private dataMap;
    uint256 public processedCount;
    uint256 public operationFactor;
    
    constructor() {
        processedCount = 0;
        operationFactor = 1;
    }

    // Function to populate data array with numbers from 1 to n
    function populateData(uint256 n) public {
        // Clear data before populating
        delete data;

        for (uint256 i = 1; i <= n; i++) {
            data.push(i);
        }
    }

    // Heavy computation: Increase each element by its index, and map it
    function processData() public {
        for (uint256 i = 0; i < data.length; i++) {
            uint256 val = data[i] + i * operationFactor;
            data[i] = val;
            dataMap[val] = i;
            processedCount++;
        }
    }

    // Recursive function to calculate Fibonacci sequence up to n
    function calculateFibonacci(uint256 n) public returns (uint256) {
        if (n <= 1) {
            return n;
        } else {
            return calculateFibonacci(n - 1) + calculateFibonacci(n - 2);
        }
    }

    // Function to perform insertion operations to resize data array
    function resizeData(uint256 newSize) public {
        if (newSize > data.length) {
            while (data.length < newSize) {
                data.push(data.length);
                operationFactor++;
            }
        } else if (newSize < data.length) {
            while (data.length > newSize) {
                data.pop();
                operationFactor--;
            }
        }
    }

    // Complex nested loop for intensive computation
    function complexComputation(uint256 iterations) public {
        for (uint256 i = 0; i < iterations; i++) {
            for (uint256 j = 0; j < data.length; j++) {
                data[j] = data[j] * (i + 1) + j * operationFactor;
                dataMap[data[j]] = j;
                processedCount += data[j];
            }
        }
    }

    // Function to clear the data map
    function clearDataMap() public {
        for (uint256 i = 0; i < data.length; i++) {
            delete dataMap[data[i]];
        }
    }
}