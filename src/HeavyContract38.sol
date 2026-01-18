// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract38 {
    struct Record {
        uint256 id;
        uint256 value;
        address owner;
    }

    mapping(address => Record[]) private records;
    uint256 public totalRecords;
    uint256 public computationCount;
    uint256 private constant FACTOR = 1234567;

    // Add a new record with heavy computation
    function addRecord(uint256 id, uint256 value) public {
        uint256 heavyResult = performHeavyComputation(id, value);
        
        records[msg.sender].push(Record({
            id: id,
            value: heavyResult,
            owner: msg.sender
        }));
        
        totalRecords++;
    }

    // Perform a heavy computation with loops and storage operations
    function performHeavyComputation(uint256 id, uint256 value) internal returns (uint256) {
        uint256 result = 0;
        for (uint256 i = 0; i < 100; i++) {
            result = complexCalculation(id, value);
            value = result % 100000;
        }
        computationCount++;
        return result;
    }

    // Complex calculation using nested loops
    function complexCalculation(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 20; i++) {
            for (uint256 j = 0; j < 15; j++) {
                sum += (a * FACTOR + b) / FACTOR;
            }
        }
        return sum;
    }

    // Searches records and performs heavy operation
    function searchAndModify(uint256 searchId) public {
        for (uint256 i = 0; i < records[msg.sender].length; i++) {
            if (records[msg.sender][i].id == searchId) {
                records[msg.sender][i].value = performHeavyComputation(searchId, records[msg.sender][i].value);
            }
        }
    }

    // Recursive function to increase gas usage
    function recursiveComputation(uint256 steps, uint256 value) public returns (uint256) {
        if (steps == 0) return value;
        return recursiveComputation(steps - 1, complexCalculation(value, steps));
    }

    // Compute factorial in a very inefficient manner
    function inefficientFactorial(uint256 n) public pure returns (uint256) {
        if (n == 0) return 1;
        uint256 result = 1;
        for (uint256 i = 1; i <= n; i++) {
            result *= i;
        }
        return result;
    }

    // Returns the number of records for a specific address
    function getRecordCount(address user) public view returns (uint256) {
        return records[user].length;
    }

    // Clear all records for the caller (heavy due to iteration)
    function clearAllRecords() public {
        while (records[msg.sender].length > 0) {
            records[msg.sender].pop();
        }
        totalRecords -= records[msg.sender].length;
    }
}