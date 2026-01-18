// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract57Opt {

    struct Entry {
        address owner;
        uint256 data;
        uint256 timestamp;
    }

    mapping(uint256 => Entry) public registry;
    uint256 public registrySize;
    
    // State variables for hash calculations
    mapping(address => uint256) public hashResult;
    uint256[] public dynamicArray;
    uint256 public constant MAX_ITERATIONS = 1000;

    event EntryAdded(uint256 indexed id, address indexed owner, uint256 data);

    constructor() {
        registrySize = 0;
    }

    function addEntry(uint256 data) public {
        require(data > 0, "Data must be positive");

        // Create new entry in the registry
        registry[registrySize] = Entry({
            owner: msg.sender,
            data: data,
            timestamp: block.timestamp
        });

        emit EntryAdded(registrySize, msg.sender, data);
        registrySize++;
    }

    function calculateHashes(uint256 iterations) public {
        require(iterations > 0 && iterations <= MAX_ITERATIONS, "Invalid iterations");

        uint256 hashValue = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
        for (uint256 i = 0; i < iterations; i++) {
            hashValue = uint256(keccak256(abi.encodePacked(hashValue, i)));
        }
        hashResult[msg.sender] = hashValue; // SSTORE moved outside of loop
    }

    function searchEntryByOwner(address owner) public view returns (uint256[] memory) {
        uint256 count;
        for (uint256 i = 0; i < registrySize; i++) {
            if (registry[i].owner == owner) {
                count++;
            }
        }

        uint256[] memory trimmedResults = new uint256[](count);
        uint256 index;
        for (uint256 i = 0; i < registrySize; i++) {
            if (registry[i].owner == owner) {
                trimmedResults[index] = i;
                index++;
            }
        }
        return trimmedResults;
    }

    function intensiveArrayOperation(uint256 elements) public {
        require(elements > 0, "Elements must be positive");
        delete dynamicArray;
        dynamicArray = new uint256[](elements);
        uint256 sum = 0;

        for (uint256 i = 0; i < elements; i++) {
            dynamicArray[i] = i;
            sum += i;
        }

        for (uint256 i = 0; i < elements; i++) {
            dynamicArray[i] = sum; // SSTORE optimized to only store precomputed sum
        }
    }

    function recursiveHashCalculation(uint256 input) public returns (uint256) {
        return internalRecursiveHash(input, 0);
    }

    function internalRecursiveHash(uint256 input, uint256 depth) internal returns (uint256) {
        if (depth == 5) {
            return input;
        }
        uint256 hashValue = uint256(keccak256(abi.encodePacked(input, depth)));
        return internalRecursiveHash(hashValue, depth + 1);
    }
}