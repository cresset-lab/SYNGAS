// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract88Opt {
    struct Record {
        uint256 id;
        address owner;
        uint256[] hashValues;
    }

    mapping(address => Record[]) public records;
    mapping(uint256 => address) public idToOwner;
    uint256 public recordCount = 0;

    // Complex function to add a record
    function addRecord(uint256 id, uint256 initialHash) public {
        require(idToOwner[id] == address(0), "ID already exists");
        
        uint256[] memory hashes = new uint256[](10);
        
        uint256 hash;
        for (uint256 i = 0; i < hashes.length; ) {
            hash = generateHashes(initialHash, i);
            hashes[i] = hash;
            unchecked { i++; }
            initialHash = hash;
        }
        
        records[msg.sender].push(Record({
            id: id,
            owner: msg.sender,
            hashValues: hashes
        }));
        
        idToOwner[id] = msg.sender;
        unchecked { recordCount++; }
    }

    // Computationally heavy function to generate hash values
    function generateHashes(uint256 seed, uint256 complexity) private pure returns (uint256) {
        for (uint256 i = 0; i < complexity * 100; ) {
            seed = uint256(keccak256(abi.encodePacked(seed, i)));
            unchecked { i++; }
        }
        return seed;
    }

    // Complex search function that iterates multiple times
    function searchByOwnerAndCalculate(address owner) public view returns (uint256) {
        uint256 total = 0;
        Record[] memory ownerRecords = records[owner];
        
        for (uint256 i = 0; i < ownerRecords.length; ) {
            uint256[] memory hashValues = ownerRecords[i].hashValues;
            for (uint256 j = 0; j < hashValues.length; ) {
                total += complexCalculation(hashValues[j]);
                unchecked { j++; }
            }
            unchecked { i++; }
        }
        return total;
    }

    // Computationally heavy recursive calculation
    function complexCalculation(uint256 value) private pure returns (uint256) {
        if (value < 10) return value * value;
        uint256 halfValue = value / 2;
        uint256 thirdValue = value / 3;
        return complexCalculation(halfValue) + complexCalculation(thirdValue);
    }

    // Update records with computational intensity
    function updateRecordHash(uint256 id, uint256 newInitialHash) public {
        require(idToOwner[id] == msg.sender, "Unauthorized");
        
        Record[] storage userRecords = records[msg.sender];
        for (uint256 i = 0; i < userRecords.length; ) {
            if (userRecords[i].id == id) {
                uint256[] storage hashValues = userRecords[i].hashValues;
                for (uint256 j = 0; j < hashValues.length; ) {
                    hashValues[j] = generateHashes(newInitialHash, j);
                    newInitialHash = hashValues[j];
                    unchecked { j++; }
                }
            }
            unchecked { i++; }
        }
    }

    // Function to trigger a heavy loop without purpose
    function pointlessLoop(uint256 iterations) public pure returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < iterations; ) {
            count += i;
            for (uint256 j = 0; j < iterations / 2; ) {
                count -= j;
                unchecked { j++; }
            }
            unchecked { i++; }
        }
        return count;
    }
}