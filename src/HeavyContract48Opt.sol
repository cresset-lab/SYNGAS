// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract48Opt {
    string public mainString = "InitialString";
    uint256[] public numbers;
    mapping(uint256 => string) public idToString;
    uint256 public callCounter = 0;

    // Concatenate strings in a loop, very gas-intensive
    function concatenateStrings(string calldata input, uint256 times) public {
        bytes memory result;
        
        // Concatenate using `bytes` to reduce intermediate string conversions
        for (uint256 i = 0; i < times; i++) {
            result = abi.encodePacked(result, input);
        }
        mainString = string(result);
    }

    // Heavy computation using nested loops
    function complexNumberProcessor(uint256[] calldata inputNumbers) public {
        numbers = inputNumbers;

        uint256 len = numbers.length;
        for (uint256 i = 0; i < len; i++) {
            uint256 val = numbers[i];
            for (uint256 j = i; j < len; j++) {
                numbers[j] += val;
            }
        }
    }

    // Recursive function for Fibonacci-like sequence calculation
    function fibonacci(uint256 n, uint256 a, uint256 b) public pure returns (uint256) {
        if (n == 0) {
            return a;
        }
        if (n == 1) {
            return b;
        }
        uint256 p = a;
        uint256 q = b;
        uint256 fib;
        for (uint256 i = 2; i <= n; i++) {
            fib = p + q;
            p = q; 
            q = fib;
        }
        return fib;
    }

    // Update a mapping with complex logic
    function updateMappingWithConcatenation(uint256 id, string calldata data) public {
        bytes memory tempBytes;
        bytes memory dataBytes = bytes(data);
        uint256 length = dataBytes.length;
        for (uint256 i = 0; i < length; i++) {
            for (uint256 j = i; j < length; j++) {
                tempBytes = abi.encodePacked(tempBytes, dataBytes[j]);
            }
        }
        idToString[id] = string(tempBytes);
    }

    // Function that tracks the number of calls
    function countCalls() public {
        callCounter++;
    }
}