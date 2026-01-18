// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract48 {
    string public mainString;
    uint256[] public numbers;
    mapping(uint256 => string) public idToString;
    uint256 public callCounter;

    constructor() {
        mainString = "InitialString";
        callCounter = 0;
    }

    // Concatenate strings in a loop, very gas-intensive
    function concatenateStrings(string memory input, uint256 times) public {
        // Reset the main string
        mainString = "";
        
        // Concatenate `input` to `mainString` `times` times
        for (uint256 i = 0; i < times; i++) {
            mainString = string(abi.encodePacked(mainString, input));
        }
    }

    // Heavy computation using nested loops
    function complexNumberProcessor(uint256[] memory inputNumbers) public {
        // Store the numbers in a state variable
        numbers = inputNumbers;

        uint256 len = numbers.length;
        for (uint256 i = 0; i < len; i++) {
            for (uint256 j = i; j < len; j++) {
                numbers[j] = numbers[j] + numbers[i];
            }
        }
    }

    // Recursive function for Fibonacci-like sequence calculation
    function fibonacci(uint256 n, uint256 a, uint256 b) public returns (uint256) {
        if (n == 0) {
            return a;
        }
        if (n == 1) {
            return b;
        }
        uint256 result = fibonacci(n - 1, a, b) + fibonacci(n - 2, a, b);
        return result;
    }

    // Update a mapping with complex logic
    function updateMappingWithConcatenation(uint256 id, string memory data) public {
        bytes memory dataBytes = bytes(data);
        string memory tempString = "";
        for (uint256 i = 0; i < dataBytes.length; i++) {
            for (uint256 j = i; j < dataBytes.length; j++) {
                tempString = string(abi.encodePacked(tempString, dataBytes[j]));
            }
        }
        idToString[id] = tempString;
    }

    // Function that tracks the number of calls
    function countCalls() public {
        callCounter++;
        for (uint256 i = 0; i < callCounter; i++) {
            uint256 dummy = i * callCounter; // Dummy operation to consume gas
            dummy; // Suppress unused variable warning
        }
    }
}