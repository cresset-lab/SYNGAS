
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract25Opt {
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
        data = new uint256[](n);

        for (uint256 i = 0; i < n; i++) {
            data[i] = i + 1;
        }
    }

    // Heavy computation: Increase each element by its index, and map it
    function processData() public {
        uint256 length = data.length;
        uint256 currentOperationFactor = operationFactor;
        for (uint256 i = 0; i < length; i++) {
            uint256 val = data[i] + i * currentOperationFactor;
            data[i] = val;
            dataMap[val] = i;
            processedCount++;
        }
    }

    // Recursive function to calculate Fibonacci sequence up to n
    function calculateFibonacci(uint256 n) public pure returns (uint256) {
        if (n <= 1) {
            return n;
        }
        uint256 a = 0;
        uint256 b = 1;
        for (uint256 i = 2; i <= n; i++) {
            (a, b) = (b, a + b);
        }
        return b;
    }

    // Function to perform insertion operations to resize data array
    function resizeData(uint256 newSize) public {
        uint256 currentLength = data.length;
        if (newSize > currentLength) {
            for (uint256 i = currentLength; i < newSize; i++) {
                data.push(i);
                operationFactor++;
            }
        } else if (newSize < currentLength) {
            while (data.length > newSize) {
                data.pop();
                operationFactor--;
            }
        }
    }

    // Complex nested loop for intensive computation
    function complexComputation(uint256 iterations) public {
        uint256 length = data.length;
        uint256 currentOperationFactor = operationFactor;
        for (uint256 i = 0; i < iterations; i++) {
            for (uint256 j = 0; j < length; j++) {
                uint256 currentValue = data[j] * (i + 1) + j * currentOperationFactor;
                data[j] = currentValue;
                dataMap[currentValue] = j;
                processedCount += currentValue;
            }
        }
    }

    // Function to clear the data map
    function clearDataMap() public {
        uint256 length = data.length;
        for (uint256 i = 0; i < length; i++) {
            delete dataMap[data[i]];
        }
    }
}
