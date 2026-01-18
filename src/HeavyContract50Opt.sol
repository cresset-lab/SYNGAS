// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract50Opt {
    string[] public dataStrings;
    uint256[] public numbers;
    mapping(uint256 => string) public indexedStrings;
    mapping(address => uint256) public userBalances;
    
    uint256 public constant MAX_ITERATIONS = 100;
    
    event ConcatenationResult(string result);
    event ComputationResult(uint256 result);
    
    // Function to initialize strings and numbers with some data
    function initializeData(uint256 arraySize) public {
        string memory initialValue = "initial";
        // Resize array by pushing or popping
        while (numbers.length < arraySize) {
            numbers.push(0);
        }
        while (numbers.length > arraySize) {
            numbers.pop();
        }
        for (uint256 i = 0; i < arraySize; i++) {
            dataStrings.push(initialValue);
            numbers[i] = i * 2;
        }
    }
    
    // Function to concatenate strings multiple times
    function stringConcatenationLoop(uint256 times) public {
        string memory base = "BaseString";
        uint256 dataStringsLen = dataStrings.length;
        for (uint256 i = 0; i < times; i++) {
            for (uint256 j = 0; j < dataStringsLen; j++) {
                string memory newString = string(abi.encodePacked(base, dataStrings[j], uint2str(j)));
                indexedStrings[j] = newString;
                emit ConcatenationResult(newString);
            }
        }
    }
    
    // Function to simulate a complex calculation with nested loops
    function complexCalculation(uint256 multiplier) public {
        uint256 result = 0;
        uint256 numbersLen = numbers.length;
        for (uint256 i = 0; i < numbersLen; i++) {
            uint256 num = numbers[i] * multiplier;
            for (uint256 j = 0; j < MAX_ITERATIONS; j++) {
                result += num / (j + 1);
            }
        }
        emit ComputationResult(result);
    }
    
    // Function to perform array manipulation and update balances
    function manipulateAndBalance(uint256 factor) public {
        uint256 userBalance = userBalances[msg.sender];
        uint256 numbersLen = numbers.length;
        for (uint256 i = 0; i < numbersLen; i++) {
            numbers[i] *= factor;
            userBalance += numbers[i];
        }
        userBalances[msg.sender] = userBalance;
    }
    
    // Recursive function to calculate factorial, intentionally gas-heavy
    function factorial(uint256 n) public pure returns (uint256) {
        if (n == 0) {
            return 1;
        }
        return n * factorial(n - 1);
    }
    
    // Helper function to convert uint to string
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
        bytes memory bstr = new bytes(length);
        uint256 k = length - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}