// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract54 {
    string public concatenatedString;
    uint256[] public dataArray;
    mapping(uint256 => string) public dataMapping;
    uint256 public counter;
    
    constructor() {
        counter = 0;
    }
    
    // Concatenates strings from an array into a single string
    function concatenateStrings(string[] memory strings) public {
        concatenatedString = "";
        for (uint256 i = 0; i < strings.length; i++) {
            concatenatedString = string(abi.encodePacked(concatenatedString, strings[i]));
        }
    }

    // Processes the array and stores results in a mapping
    function processArray(uint256[] memory values) public {
        for (uint256 i = 0; i < values.length; i++) {
            for (uint256 j = 0; j < 500; j++) { // Nested loop to increase complexity
                dataMapping[values[i] + j] = getRepeatedString("Value", j);
            }
        }
    }

    // Updates the data array by doubling each element
    function updateDataArray() public {
        for (uint256 i = 0; i < dataArray.length; i++) {
            dataArray[i] *= 2;
        }
    }

    // Adds a new element to the data array and updates the counter
    function addData(uint256 value) public {
        dataArray.push(value);
        counter++;
    }

    // Recursive calculation to demonstrate heavy computation
    function recursiveCalculation(uint256 n) public view returns (uint256) {
        if (n == 0) {
            return 0;
        } else if (n == 1) {
            return 1;
        }
        return recursiveCalculation(n - 1) + recursiveCalculation(n - 2);
    }

    // Helper function to generate a repeated string
    function getRepeatedString(string memory base, uint256 times) internal pure returns (string memory) {
        string memory result = "";
        for (uint256 i = 0; i < times; i++) {
            result = string(abi.encodePacked(result, base));
        }
        return result;
    }
}