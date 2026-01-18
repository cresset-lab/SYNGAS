// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract4 {
    
    uint256[] public dataStorage;
    mapping(uint256 => uint256) public dataMap;
    uint256 public totalSum;
    uint256 public totalProduct;

    constructor() {
        totalSum = 0;
        totalProduct = 1;
    }

    // Function to populate dataStorage and dataMap with initial values
    function initializeData(uint256 size, uint256 seed) public {
        for (uint256 i = 0; i < size; i++) {
            uint256 value = uint256(keccak256(abi.encodePacked(seed, i))) % 1000;
            dataStorage.push(value);
            dataMap[i] = value;
        }
    }

    // Function to perform nested loop computations and update state variables
    function computeHeavySum(uint256 iterations) public {
        for (uint256 i = 0; i < iterations; i++) {
            for (uint256 j = 0; j < dataStorage.length; j++) {
                totalSum += dataStorage[j] * (i + 1);
                dataMap[j] = totalSum;
            }
        }
    }

    // Function to perform nested loops with multiplication and update state variables
    function computeHeavyProduct(uint256 iterations) public {
        for (uint256 i = 1; i <= iterations; i++) {
            for (uint256 j = 0; j < dataStorage.length; j++) {
                totalProduct *= (dataStorage[j] + i) % 1000 + 1;
                dataMap[j] = totalProduct;
            }
        }
    }

    // Recursive function to perform a heavy computation
    function recursiveComputation(uint256 n, uint256 depth) public returns (uint256) {
        if (depth == 0) {
            return n;
        } else {
            uint256 result = recursiveComputation(n * depth, depth - 1);
            totalSum += result;
            totalProduct *= result;
            return result;
        }
    }

    // Function to combine looping over arrays and mappings with heavy calculations
    function complexCalculation(uint256 factor, uint256 size) public {
        initializeData(size, factor);
        for (uint256 i = 0; i < size; i++) {
            for (uint256 j = 0; j < size; j++) {
                uint256 temp = dataStorage[j] * dataMap[i];
                temp = temp ** 2;
                totalSum += temp;
                totalProduct *= (temp + 1);
            }
        }
    }
}