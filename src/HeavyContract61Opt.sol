// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract61Opt {
    
    struct Record {
        uint256 id;
        bytes32 dataHash;
        uint256[] dataPoints;
    }
    
    mapping(uint256 => Record) private records;
    uint256 private recordCount;
    uint256[] private ids;
    uint256 private constant HASH_ITERATIONS = 100;

    // Store new record
    function storeRecord(uint256 id, bytes32 data) public {
        require(records[id].id == 0, "Record already exists");

        uint256[] memory dataPoints = new uint256[](HASH_ITERATIONS);
        bytes32 currentHash = data;
        for (uint256 i = 0; i < HASH_ITERATIONS; ) {
            currentHash = keccak256(abi.encodePacked(currentHash, i));
            dataPoints[i] = uint256(currentHash);
            unchecked { i++; }
        }
        
        records[id] = Record({
            id: id,
            dataHash: currentHash,
            dataPoints: dataPoints
        });
        
        ids.push(id);
        recordCount++;
    }
    
    // Retrieve data hash by id
    function getDataHash(uint256 id) public view returns (bytes32) {
        require(records[id].id != 0, "Record does not exist");
        return records[id].dataHash;
    }
    
    // Iteratively search for the record containing a specific hash
    function findRecordByHash(bytes32 hash) public view returns (uint256) {
        // Cache length for efficiency
        uint256 len = ids.length;
        for (uint256 i = 0; i < len; ) {
            uint256 id = ids[i];
            if (records[id].dataHash == hash) {
                return id;
            }
            unchecked { i++; }
        }
        revert("Record not found");
    }
    
    // Perform heavy hash calculations and update state
    function heavyUpdate(uint256 id, bytes32 newData) public {
        require(records[id].id != 0, "Record does not exist");
        
        uint256[] storage dataPoints = records[id].dataPoints;
        bytes32 currentHash = newData;
        for (uint256 i = 0; i < HASH_ITERATIONS; ) {
            currentHash = keccak256(abi.encodePacked(currentHash, i));
            dataPoints[i] = uint256(currentHash);
            unchecked { i++; }
        }
        
        records[id].dataHash = currentHash;
    }
    
    // Complex and inefficient function to demonstrate gas usage
    function inefficientComputation(uint256 multiplier) public view returns (uint256 result) {
        require(multiplier > 0, "Multiplier must be greater than zero");
        result = 1;
        uint256 len = recordCount;
        for (uint256 i = 0; i < len; ) {
            uint256 id = ids[i];
            uint256 pointsLength = records[id].dataPoints.length;
            for (uint256 j = 0; j < pointsLength; ) {
                result += (records[id].dataPoints[j] * multiplier) % (i + 1);
                unchecked { j++; }
            }
            unchecked { i++; }
        }
    }
    
    // Recursively calculate factorial of a number (inefficient for large numbers)
    function recursiveFactorial(uint256 n) public pure returns (uint256) {
        if (n == 0) {
            return 1;
        }
        return n * recursiveFactorial(n - 1);
    }
}