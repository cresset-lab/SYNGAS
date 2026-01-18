// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract23Opt {
    struct Record {
        uint256 id;
        string data;
        uint256[] numbers;
    }

    mapping(uint256 => Record) private records;
    uint256 private recordCounter;
    uint256[] private recordIds;
    
    // State variables for recursive operations
    uint256 private calculationResult;
    mapping(uint256 => uint256) private computationCache;

    constructor() {
        recordCounter = 0;
        calculationResult = 0;
    }

    // Add a new record with computationally intensive setup
    function addRecord(uint256 id, string calldata data, uint256[] calldata numbers) public {
        require(id > 0, "Invalid ID");
        require(records[id].id == 0, "Record already exists");

        // Intensive initialization
        uint256 sum = 0;
        uint256 numbersLen = numbers.length;
        for (uint256 i = 0; i < numbersLen; ++i) {
            sum += numbers[i];
        }
        
        records[id] = Record(id, data, numbers);
        recordIds.push(id);
        recordCounter++;

        // Save the calculated sum in the state for future operations
        computationCache[id] = sum;
    }

    // Recursive Fibonacci calculation to simulate gas-heavy computation
    function recursiveFibonacci(uint256 n) public returns (uint256) {
        if (n <= 1) {
            return n;
        } else {
            return recursiveFibonacci(n - 1) + recursiveFibonacci(n - 2);
        }
    }

    // Public function to compute factorial using recursion and store results
    function computeAndStoreFactorial(uint256 number) public {
        calculationResult = factorial(number);
    }

    // Helper function for factorial calculation
    function factorial(uint256 n) private returns (uint256 result) {
        if (n == 0) {
            return 1;
        } else {
            result = n * factorial(n - 1);
            computationCache[n] = result; // Store intermediate result
        }
    }

    // Heavy search function over records
    function searchRecord(uint256 id) public view returns (string memory, uint256[] memory) {
        uint256 recordIdsLen = recordIds.length;
        for (uint256 i = 0; i < recordIdsLen; ++i) {
            if (recordIds[i] == id) {
                Record storage record = records[id];
                return (record.data, record.numbers);
            }
        }
        revert("Record not found");
    }

    // Function to iterate over records and perform a nested loop calculation
    function calculateSumOfAllNumbers() public {
        uint256 totalSum = 0;
        uint256 recordIdsLen = recordIds.length;
        for (uint256 i = 0; i < recordIdsLen; ++i) {
            Record storage record = records[recordIds[i]];
            uint256 numbersLen = record.numbers.length;
            for (uint256 j = 0; j < numbersLen; ++j) {
                totalSum += record.numbers[j];
            }
        }
        calculationResult = totalSum;
    }
}