// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract33 {
    
    // State variables
    string public concatenatedString;
    uint256 public computationResult;
    mapping(uint256 => string) public indexToString;
    uint256[] public computationArray;
    
    // Constructor
    constructor() {
        concatenatedString = "";
        computationResult = 0;
    }
    
    // Function to perform extensive string concatenation
    function heavyStringConcat(uint256 iterations, string memory baseString) public {
        for (uint256 i = 0; i < iterations; i++) {
            concatenatedString = string(abi.encodePacked(concatenatedString, baseString));
            indexToString[i] = concatenatedString; // Storing in a mapping
        }
    }
    
    // Function to perform computationally heavy math operations
    function heavyComputation(uint256 input) public {
        uint256 localResult = 0;
        for (uint256 i = 0; i < input; i++) {
            for (uint256 j = 0; j < i; j++) {
                localResult += i * j; // Quadratic operation
            }
        }
        computationResult = localResult; // Update state variable
    }

    // Recursive function to execute a computationally heavy Fibonacci sequence
    function heavyFibonacci(uint256 n) public returns (uint256) {
        if (n <= 1) {
            return n;
        } else {
            return heavyFibonacci(n - 1) + heavyFibonacci(n - 2); // Recursive calls
        }
    }
    
    // Function to populate and compute on an array with heavy operations
    function populateAndComputeArray(uint256 size) public {
        delete computationArray; // Reset array
        for (uint256 i = 0; i < size; i++) {
            computationArray.push(i * 2); // Populate with some values
        }
        
        uint256 arraySum = 0;
        for (uint256 i = 0; i < computationArray.length; i++) {
            for (uint256 j = 0; j < computationArray.length / 2; j++) {
                arraySum += computationArray[i] / (j + 1);
            }
        }

        computationResult = arraySum; // Update state variable
    }

    // Function to perform nested loops with storage manipulation
    function nestedLoopsWithStorage(uint256 depth) public {
        for (uint256 i = 0; i < depth; i++) {
            for (uint256 j = 0; j < i; j++) {
                computationResult += i * j;
                indexToString[computationResult] = "NestedValue"; // Store string based on computation
            }
        }
    }
}