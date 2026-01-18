// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract1 {
    string[] public dataStrings;
    mapping(uint256 => string) public concatenatedStrings;
    uint256[] public numberArray;
    uint256 public counter = 0;
    
    constructor() {
        // Initialize the contract with some data
        for (uint256 i = 0; i < 10; i++) {
            dataStrings.push("InitialString");
            numberArray.push(i);
        }
    }
    
    // Function to perform heavy string concatenation
    function concatenateStrings(uint256 times, string memory baseString) public {
        string memory result = "";
        for (uint256 i = 0; i < times; i++) {
            result = string(abi.encodePacked(result, baseString, uint2str(i)));
        }
        concatenatedStrings[counter] = result;
        counter++;
    }
    
    // Function to perform heavy computation on numberArray
    function complexNumberComputation(uint256 multiplier) public {
        for (uint256 i = 0; i < numberArray.length; i++) {
            for (uint256 j = 0; j < multiplier; j++) {
                numberArray[i] = numberArray[i] * 2 / (j + 1); // Inefficient calculation
            }
        }
    }
    
    // Function to process data in a recursive manner
    function recursiveComputation(uint256 n) public returns (uint256) {
        return fibonacci(n);
    }
    
    // Helper for recursive computation
    function fibonacci(uint256 n) internal pure returns (uint256) {
        if (n <= 1) return n;
        return fibonacci(n - 1) + fibonacci(n - 2);
    }
    
    // Function to update data strings with nested loops
    function updateDataStrings(uint256 iterations, string memory newString) public {
        for (uint256 i = 0; i < iterations; i++) {
            for (uint256 j = 0; j < dataStrings.length; j++) {
                dataStrings[j] = string(abi.encodePacked(dataStrings[j], newString));
            }
        }
    }

    // Function to fuzz test with various parameters
    function fuzzTest(uint256 loops, uint256 modValue) public {
        uint256 sum = 0;
        for (uint256 i = 0; i < loops; i++) {
            sum += (i ** 2) % modValue;
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
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bStr[k] = b1;
            _i /= 10;
        }
        return string(bStr);
    }
}