
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract1Opt {
    string[] public dataStrings;
    mapping(uint256 => string) public concatenatedStrings;
    uint256[] public numberArray;
    uint256 public counter = 0;
    
    constructor() {
        // Initialize the contract with some data
        for (uint256 i = 0; i < 10; ) {
            dataStrings.push("InitialString");
            numberArray.push(i);
            unchecked { i++; }
        }
    }
    
    // Function to perform heavy string concatenation
    function concatenateStrings(uint256 times, string calldata baseString) public {
        bytes memory result;
        for (uint256 i = 0; i < times; ) {
            result = abi.encodePacked(result, baseString, uint2str(i));
            unchecked { i++; }
        }
        concatenatedStrings[counter] = string(result);
        unchecked { counter++; }
    }
    
    // Function to perform heavy computation on numberArray
    function complexNumberComputation(uint256 multiplier) public {
        uint256 numberArray_len = numberArray.length;
        for (uint256 i = 0; i < numberArray_len; ) {
            uint256 num = numberArray[i];
            for (uint256 j = 0; j < multiplier; ) {
                num = num * 2 / (j + 1);
                unchecked { j++; }
            }
            numberArray[i] = num;
            unchecked { i++; }
        }
    }
    
    // Function to process data in a recursive manner
    function recursiveComputation(uint256 n) public returns (uint256) {
        return fibonacci(n);
    }
    
    // Helper for recursive computation
    function fibonacci(uint256 n) internal pure returns (uint256) {
        if (n <= 1) return n;
        uint256 a = 0;
        uint256 b = 1;
        for (uint256 i = 2; i <= n; ) {
            (a, b) = (b, a + b);
            unchecked { i++; }
        }
        return b;
    }
    
    // Function to update data strings with nested loops
    function updateDataStrings(uint256 iterations, string calldata newString) public {
        uint256 dataStrings_len = dataStrings.length;
        for (uint256 i = 0; i < iterations; ) {
            for (uint256 j = 0; j < dataStrings_len; ) {
                dataStrings[j] = string(abi.encodePacked(dataStrings[j], newString));
                unchecked { j++; }
            }
            unchecked { i++; }
        }
    }

    // Function to fuzz test with various parameters
    function fuzzTest(uint256 loops, uint256 modValue) public {
        uint256 sum = 0;
        for (uint256 i = 0; i < loops; ) {
            unchecked { sum += (i * i) % modValue; }
            unchecked { i++; }
        }
        numberArray.push(sum);
    }
    
    // Utility function to convert uint to string
    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bStr = new bytes(length);
        uint256 k = length;
        while (_i != 0) {
            k = k-1;
            bStr[k] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bStr);
    }
}
