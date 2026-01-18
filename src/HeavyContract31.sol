// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract31 {
    uint256[] public data;
    mapping(uint256 => uint256) public hashResults;
    uint256 public lastComputedHash;
    uint256 public computationCounter;

    constructor() {
        // Initialize with some data
        for (uint256 i = 0; i < 100; i++) {
            data.push(i);
        }
    }

    // Function to perform heavy hash calculations on an array
    function computeHashes(uint256 iterations) public {
        for (uint256 i = 0; i < iterations; i++) {
            for (uint256 j = 0; j < data.length; j++) {
                uint256 hashValue = uint256(keccak256(abi.encodePacked(data[j], j)));
                hashResults[j] = hashValue;
            }
        }
        computationCounter += iterations;
    }

    // Function to perform a complex calculation with nested loops
    function nestedLoopCalculation(uint256 depth, uint256 multiplier) public {
        for (uint256 i = 0; i < depth; i++) {
            for (uint256 j = 0; j < data.length; j++) {
                data[j] = (data[j] * multiplier) % (j + 1 + depth);
            }
        }
        computationCounter += depth;
    }

    // Recursive function to sum even indexed elements in the array
    function recursiveSum(uint256 index) public returns (uint256 sum) {
        if (index >= data.length) {
            return 0;
        }
        if (index % 2 == 0) {
            sum = data[index];
        }
        sum += recursiveSum(index + 1);
    }

    // Function to execute a gas-heavy process with state updates
    function gasHeavyProcess(uint256 limit) public {
        for (uint256 i = 0; i < limit; i++) {
            for (uint256 j = 0; j < data.length; j++) {
                data[j] = (data[j] + i + j) % (j + 1);
                if (j % 5 == 0) {
                    lastComputedHash = uint256(keccak256(abi.encodePacked(lastComputedHash, data[j])));
                }
            }
        }
        computationCounter += limit;
    }

    // Optimized yet intentionally gas-heavy processing function
    function optimizedProcess(uint256 factor) public {
        for (uint256 i = 0; i < data.length; i++) {
            uint256 localHash = 0;
            for (uint256 j = 0; j < factor; j++) {
                localHash = uint256(keccak256(abi.encodePacked(localHash, i, j)));
                if (localHash % 3 == 0) {
                    data[i] = localHash % (j + 1);
                }
            }
            hashResults[i] = localHash;
        }
        computationCounter += factor;
    }
}