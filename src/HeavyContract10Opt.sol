// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract10Opt {

    uint256[] public data;
    mapping(uint256 => uint256) public indexData;
    uint256 public constant MAX_RECURSION = 10;
    uint256 public computationResult;

    // Initialize the contract with some data
    constructor() {
        unchecked {
            for (uint256 i = 0; i < 50; i++) {
                data.push(i + 1);
                indexData[i] = i + 1;
            }
        }
    }

    // Recursive function to accumulate a value
    function recursiveSum(uint256 startIndex, uint256 count) public returns (uint256) {
        if (count == 0 || startIndex >= data.length) {
            return 0;
        }
        uint256 val = data[startIndex] + recursiveSum(startIndex + 1, count - 1);
        computationResult = val; // Store the result into a state variable
        return val;
    }

    // Perform complex nested loop calculation
    function complexCalculation() public returns (uint256) {
        uint256 sum = 0;
        uint256 dLen = data.length;
        for (uint256 i = 0; i < dLen; i++) {
            uint256 indexDataTemp = indexData[i];
            for (uint256 j = i; j < dLen; j++) {
                sum += data[j] * indexDataTemp;
            }
            indexData[i] = sum; // Reduced write to storage
        }
        computationResult = sum;
        return sum;
    }

    // Simulates a heavy computation by doing unnecessary operations
    function heavyComputation(uint256 n) public returns (uint256) {
        uint256 result = 0;
        uint256 dLen = data.length;
        for (uint256 i = 0; i < n; i++) {
            for (uint256 j = i; j < n; j++) {
                result += j % 3 == 0 ? j * 2 : j;
            }
            data[i % dLen] = result; // Update storage based on computation
        }
        computationResult = result;
        return result;
    }

    // Perform a recursive and iterative operation
    function recursiveIterative(uint256 n) public returns (uint256) {
        uint256 result = 0;
        for (uint256 i = 0; i < n; i++) {
            result += recursiveSum(i, MAX_RECURSION);
        }
        computationResult = result;
        return result;
    }

    // Adds numbers from the data array, heavily using storage
    function addDataNumbers(uint256 limit) public returns (uint256) {
        uint256 sum = 0;
        uint256 dLen = data.length;
        uint256 len = dLen <= limit ? dLen : limit;
        for (uint256 i = 0; i < len; i++) {
            sum += data[i];
            data[i] = sum; // Overwrite data with running sum
        }
        computationResult = sum;
        return sum;
    }
}