// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract86 {

    struct Record {
        uint256 id;
        string data;
        uint256[] values;
    }

    mapping(uint256 => Record) private records;
    uint256 private recordCount;
    uint256[] private indices;

    event RecordAdded(uint256 indexed id, string data);

    constructor() {
        recordCount = 0;
    }

    // Add a new record with extensive dynamic array operations
    function addRecord(string memory data, uint256 initialSize) public {
        recordCount++;
        Record storage newRecord = records[recordCount];
        newRecord.id = recordCount;
        newRecord.data = data;

        // Simulating heavy array operations
        for (uint256 i = 0; i < initialSize; i++) {
            newRecord.values.push(i);
        }

        // Resize the array with more elements
        for (uint256 i = 0; i < initialSize; i++) {
            newRecord.values.push(initialSize - i);
        }

        indices.push(recordCount);
        emit RecordAdded(recordCount, data);
    }

    // Update an existing record with nested loop calculations
    function updateRecord(uint256 id, uint256 repeat) public {
        Record storage record = records[id];
        require(record.id != 0, "Record does not exist");

        // Nested loop with complex calculations
        for (uint256 i = 0; i < record.values.length; i++) {
            uint256 result = 0;
            for (uint256 j = 0; j < repeat; j++) {
                result += (record.values[i] + j) * (j + 1);
            }
            record.values[i] = result;
        }
    }

    // Search operation with heavy computation (intentionally inefficient)
    function searchRecord(string calldata searchData) public view returns (uint256) {
        uint256 foundId = 0;
        for (uint256 i = 0; i < indices.length; i++) {
            Record storage record = records[indices[i]];
            bytes memory b1 = bytes(record.data);
            bytes memory b2 = bytes(searchData);
            if (compareStrings(b1, b2)) {
                foundId = record.id;
                break;
            }
        }
        return foundId;
    }

    // Delete a record and perform expensive cleanup
    function deleteRecord(uint256 id) public {
        require(records[id].id != 0, "Record does not exist");

        // Expensive cleanup operation
        for (uint256 i = 0; i < records[id].values.length; i++) {
            records[id].values[i] = 0;
        }

        delete records[id];
        for (uint256 i = 0; i < indices.length; i++) {
            if (indices[i] == id) {
                indices[i] = indices[indices.length - 1];
                indices.pop();
                break;
            }
        }
    }

    // Helper function to compare strings
    function compareStrings(bytes memory a, bytes memory b) internal pure returns (bool) {
        if (a.length != b.length) return false;
        for (uint256 i = 0; i < a.length; i++)
            if (a[i] != b[i])
                return false;
        return true;
    }
}