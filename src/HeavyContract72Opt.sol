
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract72Opt {

    uint256[] public numbers;
    mapping(uint256 => uint256) public results;
    uint256 public constant LIMIT = 10;
    uint256 public recursionDepth;
    uint256 public loopIterations;

    constructor() {
        recursionDepth = 0;
        loopIterations = 0;
    }
    
    // Adds numbers to the storage array
    function addNumbers(uint256[] calldata newNumbers) public {
        uint256 length = newNumbers.length;
        for (uint256 i = 0; i < length; i++) {
            numbers.push(newNumbers[i]);
            unchecked { loopIterations++; }
        }
    }
    
    // Computes factorial recursively and stores the result
    function calculateFactorial(uint256 n) public returns (uint256) {
        require(n <= LIMIT, "Exceeds limit");
        uint256 result = factorial(n);
        results[n] = result;
        return result;
    }
    
    // Internal recursive function to calculate factorial
    function factorial(uint256 n) internal returns (uint256) {
        unchecked { recursionDepth++; }
        if (n == 0) {
            return 1;
        }
        return n * factorial(n - 1);
    }

    // Function with a nested loop that updates state variables
    function heavyComputation(uint256 param) public {
        uint256[] memory localNumbers = numbers;
        for (uint256 i = 0; i < localNumbers.length; i++) {
            uint256 num = localNumbers[i];
            for (uint256 j = 0; j < param; j++) {
                results[num] += i * j;
                unchecked { loopIterations++; }
            }
        }
    }

    // Computes the sum of elements recursively
    function recursiveSum(uint256 index) public returns (uint256) {
        if (index >= numbers.length) {
            return 0;
        }
        return numbers[index] + recursiveSum(index + 1);
    }

    // Performs computation-intensive array modifications
    function modifyArray(uint256 factor) public {
        uint256 length = numbers.length;
        for (uint256 i = 0; i < length; i++) {
            numbers[i] *= factor;
            unchecked { loopIterations++; }
        }
    }
}
