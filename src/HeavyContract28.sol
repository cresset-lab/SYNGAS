// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract28 {
    struct Record {
        uint256 id;
        uint256 data;
    }

    mapping(uint256 => Record) public records;
    uint256 public recordCount;

    uint256[] public ids;
    uint256 public operationCounter;

    constructor() {
        recordCount = 0;
        operationCounter = 0;
    }

    // Add a new record with computational overhead
    function addRecord(uint256 data) public {
        uint256 id = recordCount + 1;
        records[id] = Record(id, data);
        ids.push(id);
        recordCount++;
        heavyComputation(data);
    }

    // Search for a record based on a specific pattern
    function searchRecords(uint256 pattern) public view returns (uint256) {
        uint256 found = 0;
        for (uint256 i = 0; i < recordCount; i++) {
            uint256 id = ids[i];
            if ((records[id].data & pattern) == pattern) {
                found++;
            }
        }
        return found;
    }

    // Perform a heavy computation and store results
    function heavyComputation(uint256 seed) public {
        uint256 result = seed;
        for (uint256 i = 0; i < 256; i++) {
            result = (result & 0xFFFFFFFFFFFFFFFF) ^ (result << (i % 8));
            for (uint256 j = 0; j < 128; j++) {
                result = (result | (result >> j)) & 0xFFFFFFFF;
            }
            operationCounter++;
        }
        records[recordCount].data = result; // Intentionally inefficient to trigger SSTORE
    }

    // A recursive function that performs binary operations
    function recursiveComputation(uint256 depth, uint256 value) public pure returns (uint256) {
        if (depth == 0) return value;
        return recursiveComputation(depth - 1, (value ^ (value >> depth)) & 0xFFFFFFFF);
    }

    // Intentionally inefficient function that performs nested loops
    function nestedLoopOperation(uint256 iterations) public {
        for (uint256 i = 0; i < iterations; i++) {
            for (uint256 j = 0; j < iterations; j++) {
                heavyComputation(i * j);
            }
        }
    }
}