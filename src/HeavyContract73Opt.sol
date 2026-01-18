// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract73Opt {
    // State variables
    uint256[] public dataArray;
    mapping(address => uint256) public results;
    uint256 public recursionLimit;
    uint256 public constant BASE_MULTIPLIER = 3;
    
    // Constructor to initialize recursion limit
    constructor(uint256 _recursionLimit) {
        recursionLimit = _recursionLimit;
    }

    // Function to fill the data array with sequential numbers
    function fillDataArray(uint256 size) public {
        uint256[] storage _dataArray = dataArray;
        for (uint256 i = 0; i < size; i++) {
            _dataArray.push(i);
        }
    }

    // Function to calculate factorial using recursion - very gas intensive
    function recursiveFactorial(uint256 n) public returns (uint256) {
        uint256 result = _recursiveFactorial(n);
        results[msg.sender] = result;
        return result;
    }

    function _recursiveFactorial(uint256 n) internal returns (uint256) {
        if (n == 0) {
            return 1;
        } else {
            return n * _recursiveFactorial(n - 1);
        }
    }

    // Function to perform nested looping over dataArray and update results
    function nestedLoopSum(uint256 iterations) public returns (uint256) {
        uint256 sum = 0;
        uint256 len = dataArray.length;
        uint256[] storage _dataArray = dataArray;
        uint256 _baseMultiplier = BASE_MULTIPLIER;

        for (uint256 i = 0; i < iterations; i++) {
            for (uint256 j = 0; j < len; j++) {
                sum += _dataArray[j] * _baseMultiplier;
            }
        }
        
        results[msg.sender] = sum;
        return sum;
    }

    // Function with a while loop to simulate heavy data processing
    function processDataWithWhile(uint256 start, uint256 end) public returns (uint256) {
        require(start < end, "Invalid range");
        uint256 sum = 0;
        uint256[] storage _dataArray = dataArray;
        
        while (start < end) {
            sum += _complexCalculation(_dataArray[start]);
            start++;
        }
        
        results[msg.sender] = sum;
        return sum;
    }

    function _complexCalculation(uint256 value) internal pure returns (uint256) {
        return (value * value + value) / BASE_MULTIPLIER;
    }

    // Function to trigger heavy computations based on recursion limit
    function recursiveComputation(uint256 value) public returns (uint256) {
        uint256 result = _recursiveComputation(value, recursionLimit);
        results[msg.sender] = result;
        return result;
    }

    function _recursiveComputation(uint256 value, uint256 depth) internal returns (uint256) {
        if (depth == 0) {
            return value;
        }
        return _recursiveComputation(value * BASE_MULTIPLIER, depth - 1);
    }
}