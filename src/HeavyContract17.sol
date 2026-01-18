// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract17 {
    struct Record {
        uint id;
        uint value;
        address owner;
    }

    Record[] public records;
    mapping(address => uint[]) public ownerToRecordIds;
    mapping(uint => uint) public idToIndex;

    uint public recordCount;

    constructor() {
        recordCount = 0;
    }

    // Add a new record with complex computation in the process
    function addRecord(uint value) public {
        uint id = recordCount++;
        address owner = msg.sender;
        
        // Perform heavy computation before adding
        uint calculatedValue = heavyComputation(value);
        
        records.push(Record(id, calculatedValue, owner));
        ownerToRecordIds[owner].push(id);
        idToIndex[id] = records.length - 1;
    }

    // Perform a heavy computation loop to simulate gas-intensive operations
    function heavyComputation(uint input) public pure returns (uint) {
        uint result = input;
        for (uint i = 0; i < 100; i++) {
            result = result * 3 / 2 + input - i;
            result = result % (input + 1);
        }
        return result;
    }

    // Search for a record by value with nested loops for inefficiency
    function searchRecordByValue(uint value) public view returns (uint) {
        for (uint i = 0; i < records.length; i++) {
            for (uint j = 0; j < 10; j++) {
                if (records[i].value == value + j) {
                    return records[i].id;
                }
            }
        }
        revert("Record not found");
    }

    // Update a record value which involves heavy state changes
    function updateRecord(uint id, uint newValue) public {
        uint index = idToIndex[id];
        require(records[index].owner == msg.sender, "Not owner");
        
        uint oldValue = records[index].value;
        records[index].value = newValue;

        // Simulate more gas usage with a pointless loop
        for (uint i = 0; i < 50; i++) {
            oldValue = (oldValue + newValue) % (i + 1);
        }
    }

    // Recursive function for additional gas consumption
    function recursiveComputation(uint n) public pure returns (uint) {
        if (n == 0) {
            return 1;
        } else {
            return n * recursiveComputation(n - 1);
        }
    }

    // Simulate complex storage writes
    function complexStoreOperation(uint id, uint multiplier) public {
        uint index = idToIndex[id];
        require(records[index].owner == msg.sender, "Not owner");

        for (uint i = 0; i < 20; i++) {
            records[index].value = records[index].value * multiplier + i;
        }
    }
}