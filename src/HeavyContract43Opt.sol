// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract43Opt {
    struct RegistryEntry {
        address owner;
        uint256 value;
        bool isActive;
        uint256 timestamp;
    }
    
    mapping(uint256 => RegistryEntry) public registryMap;
    uint256 public entryCount;
    uint256[] public activeIndices;

    // Add a new entry to the registry with heavy computation
    function addEntry(uint256 id, uint256 value) public {
        require(registryMap[id].owner == address(0), "Entry already exists");

        uint256 computedValue = value;
        // Nested loops with intensive computation
        for (uint i = 0; i < 10; ++i) {
            uint256 iValue = value * i; // Precompute i * value
            for (uint j = 0; j < 10; ++j) {
                computedValue += (iValue * j) / (i + j + 1);
            }
        }
        
        registryMap[id] = RegistryEntry(msg.sender, computedValue, true, block.timestamp);
        entryCount++;
        activeIndices.push(id);
    }

    // Compute and update entries based on complex conditions
    function updateEntries() public {
        uint256 currentTime = block.timestamp;
        uint256 len = activeIndices.length; // Cache length
        for (uint i = 0; i < len; ++i) {
            uint256 id = activeIndices[i];
            RegistryEntry storage entry = registryMap[id];
            
            if (entry.isActive) {
                uint256 updatedValue = entry.value;
                uint256 entryTimestamp = entry.timestamp; // Cache entry.timestamp
                
                for (uint j = 0; j < 5; ++j) {
                    updatedValue += (currentTime % (j + 1)) * entryTimestamp;
                }
                
                entry.value = updatedValue;
                entry.timestamp = currentTime;
            }
        }
    }
    
    // Recursive function to find a prime value
    function findPrime(uint256 n) public pure returns (uint256) {
        while (!isPrime(n)) {
            n++;
        }
        return n;
    }

    function isPrime(uint256 number) internal pure returns (bool) {
        if (number <= 1) return false;
        for (uint i = 2; i * i <= number; ++i) {
            if (number % i == 0) {
                return false;
            }
        }
        return true;
    }

    // Search for an entry with specific criteria
    function searchEntry(uint256 minValue) public view returns (uint256 id, uint256 value) {
        uint256 minValueFound = type(uint256).max;
        uint256 foundId = 0;
        
        for (uint i = 0; i < entryCount; ++i) {
            RegistryEntry memory entry = registryMap[activeIndices[i]];
            if (entry.isActive && entry.value > minValue && entry.value < minValueFound) {
                minValueFound = entry.value;
                foundId = activeIndices[i];
            }
        }
        
        return (foundId, minValueFound);
    }

    // Deactivate an entry with intensive checks and updates
    function deactivateEntry(uint256 id) public {
        require(registryMap[id].owner == msg.sender, "Not the owner");

        RegistryEntry storage entry = registryMap[id];
        require(entry.isActive, "Entry already inactive");

        uint256 entryValue = entry.value; // Cache entry.value

        for (uint i = 0; i < 10; ++i) {
            for (uint j = 0; j < 10; ++j) {
                entryValue -= (entryValue / (i + j + 1)) * j;
            }
        }

        entry.value = entryValue;
        entry.isActive = false;

        // Remove from activeIndices array
        uint256 len = activeIndices.length; // Cache length
        for (uint i = 0; i < len; ++i) {
            if (activeIndices[i] == id) {
                activeIndices[i] = activeIndices[len - 1];
                activeIndices.pop();
                break;
            }
        }
    }
}