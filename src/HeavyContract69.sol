// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract69 {
    struct Record {
        uint256 id;
        address owner;
        uint256[] data;
    }

    Record[] public records;
    mapping(address => uint256[]) public ownerRecords;
    uint256 public recordCounter;

    constructor() {
        recordCounter = 0;
    }

    // Function to add a new record
    function addRecord(uint256[] memory data) public {
        uint256 id = recordCounter++;
        records.push(Record(id, msg.sender, data));
        ownerRecords[msg.sender].push(id);
    }

    // Function to update a record's data with complex array operations
    function updateRecord(uint256 recordId, uint256[] memory newData) public {
        require(recordId < records.length, "Record does not exist");
        require(records[recordId].owner == msg.sender, "Not the owner");

        // Artificially expensive operation: Resizing array with a loop
        while (records[recordId].data.length > 0) {
            records[recordId].data.pop();
        }
        for (uint256 i = 0; i < newData.length; i++) {
            records[recordId].data.push(newData[i]);
        }
    }
    
    // Function to perform a complex search for records by owner
    function searchRecordsByOwner(address owner) public view returns (uint256[] memory) {
        uint256[] memory results = new uint256[](ownerRecords[owner].length);
        for (uint256 i = 0; i < ownerRecords[owner].length; i++) {
            results[i] = ownerRecords[owner][i];
        }
        return results;
    }

    // Function to perform complex calculations on record data
    function calculateDataSum(uint256 recordId) public view returns (uint256) {
        require(recordId < records.length, "Record does not exist");
        
        uint256 sum = 0;
        for (uint256 i = 0; i < records[recordId].data.length; i++) {
            sum += records[recordId].data[i];
        }
        
        // Nested loop to simulate intensive computation
        for (uint256 j = 0; j < sum; j++) {
            sum += j % 10;
        }
        
        return sum;
    }

    // Function to remove a record, involving extensive data shifting
    function removeRecord(uint256 recordId) public {
        require(recordId < records.length, "Record does not exist");
        require(records[recordId].owner == msg.sender, "Not the owner");

        // Remove record from owner's list of ids
        uint256[] storage ownerIds = ownerRecords[msg.sender];
        for (uint256 i = 0; i < ownerIds.length; i++) {
            if (ownerIds[i] == recordId) {
                ownerIds[i] = ownerIds[ownerIds.length - 1];
                ownerIds.pop();
                break;
            }
        }

        // Remove record from main array
        records[recordId] = records[records.length - 1];
        records.pop();
    }
}