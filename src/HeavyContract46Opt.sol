// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract46Opt {
    uint256 public constant iterations = 1000;
    mapping(uint256 => uint256) public results;
    uint256[] public data;
    uint256 public computationCount;

    constructor() {
        // Initialize the data array with some values
        uint256[] memory tempData = new uint256[](100);
        for (uint256 i = 0; i < 100; i++) {
            tempData[i] = i;
        }
        data = tempData;
    }

    // Function to calculate hash in a loop
    function hashCalculator(uint256 input) public returns (uint256) {
        uint256 hash = input;
        uint256 localIterations = iterations;
        uint256 localComputationCount = computationCount;
        for (uint256 i = 0; i < localIterations; i++) {
            hash = uint256(keccak256(abi.encodePacked(hash, i, block.timestamp)));
        }
        results[localComputationCount] = hash; // Store result in a mapping
        computationCount = localComputationCount + 1;
        return hash;
    }

    // Function to perform heavy multiplications and additions in a loop
    function heavyComputation(uint256 multiplier, uint256 adder) public returns (uint256) {
        uint256 result = 1;
        uint256 localIterations = iterations;
        uint256 localComputationCount = computationCount;
        for (uint256 i = 1; i <= localIterations; i++) {
            result = result * multiplier + adder;
            results[localComputationCount] = result; // Store result in a mapping
            localComputationCount++;
        }
        computationCount = localComputationCount;
        return result;
    }

    // Function to perform a recursive factorial calculation
    function recursiveFactorial(uint256 n) public returns (uint256) {
        uint256 result = factorial(n);
        results[computationCount++] = result; // Store result in a mapping
        return result;
    }

    function factorial(uint256 n) internal pure returns (uint256) {
        if (n <= 1) {
            return 1;
        }
        return n * factorial(n - 1);
    }

    // Function to compute the sum of data array elements with complex operations
    function computeArraySum() public returns (uint256) {
        uint256 sum = 0;
        uint256 dataLen = data.length;
        uint256 localIterations = iterations;
        uint256 localComputationCount = computationCount;
        for (uint256 i = 0; i < dataLen; i++) {
            for (uint256 j = 0; j < dataLen; j++) {
                sum += (data[i] * data[j] + i + j) % localIterations;
            }
            results[localComputationCount] = sum; // Store intermediate result
            localComputationCount++;
        }
        computationCount = localComputationCount;
        return sum;
    }

    // Function to fill the data array with hash-based sequence
    function fillDataWithHashes(uint256 seed) public {
        uint256 hash = seed;
        uint256 dataLen = data.length;
        uint256 localIterations = iterations;
        for (uint256 i = 0; i < dataLen; i++) {
            hash = uint256(keccak256(abi.encodePacked(hash, i)));
            data[i] = hash % localIterations; // Store data in the array
        }
    }
}