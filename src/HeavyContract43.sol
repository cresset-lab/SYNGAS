// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract43 {
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
        for (uint i = 0; i < 10; i++) {
            for (uint j = 0; j < 10; j++) {
                computedValue += (value * i * j) / (i + j + 1);
            }
        }
        
        registryMap[id] = RegistryEntry(msg.sender, computedValue, true, block.timestamp);
        entryCount++;
        activeIndices.push(id);
    }

    // Compute and update entries based on complex conditions
    function updateEntries() public {
        for (uint i = 0; i < activeIndices.length; i++) {
            uint256 id = activeIndices[i];
            RegistryEntry storage entry = registryMap[id];
            
            if (entry.isActive) {
                uint256 updatedValue = entry.value;
                
                for (uint j = 0; j < 5; j++) {
                    updatedValue += (block.timestamp % (j + 1)) * entry.timestamp;
                }
                
                entry.value = updatedValue;
                entry.timestamp = block.timestamp;
            }
        }
    }
    
    // Recursive function to find a prime value
    function findPrime(uint256 n) public pure returns (uint256) {
        if (isPrime(n)) {
            return n;
        }
        return findPrime(n + 1);
    }

    function isPrime(uint256 number) internal pure returns (bool) {
        if (number <= 1) return false;
        for (uint i = 2; i < number; i++) {
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
        
        for (uint i = 0; i < entryCount; i++) {
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
        
        for (uint i = 0; i < 10; i++) {
            for (uint j = 0; j < 10; j++) {
                entry.value -= (entry.value / (i + j + 1)) * j;
            }
        }
        
        entry.isActive = false;
        
        // Remove from activeIndices array
        for (uint i = 0; i < activeIndices.length; i++) {
            if (activeIndices[i] == id) {
                activeIndices[i] = activeIndices[activeIndices.length - 1];
                activeIndices.pop();
                break;
            }
        }
    }
}