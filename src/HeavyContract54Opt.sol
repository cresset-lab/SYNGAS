// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract54Opt {
    string public concatenatedString;
    uint256[] public dataArray;
    mapping(uint256 => string) public dataMapping;
    uint256 public counter;
    
    constructor() {
        counter = 0;
    }
    
    // Concatenates strings from an array into a single string
    function concatenateStrings(string[] calldata strings) public {
        bytes memory buffer = bytes(concatenatedString);
        uint256 length = strings.length;
        for (uint256 i = 0; i < length; i++) {
            buffer = abi.encodePacked(buffer, strings[i]);
        }
        concatenatedString = string(buffer);
    }

    // Processes the array and stores results in a mapping
    function processArray(uint256[] calldata values) public {
        uint256 length = values.length;
        for (uint256 i = 0; i < length; i++) {
            uint256 value = values[i];
            for (uint256 j = 0; j < 500; j++) { // Nested loop to increase complexity
                dataMapping[value + j] = getRepeatedString("Value", j);
            }
        }
    }

    // Updates the data array by doubling each element
    function updateDataArray() public {
        uint256 length = dataArray.length;
        for (uint256 i = 0; i < length; i++) {
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
        uint256 n1 = 1;
        uint256 n2 = 0;
        uint256 result;
        for (uint256 i = 2; i <= n; i++) {
            result = n1 + n2;
            n2 = n1;
            n1 = result;
        }
        return result;
    }

    // Helper function to generate a repeated string
    function getRepeatedString(string memory base, uint256 times) internal pure returns (string memory) {
        bytes memory buffer;
        for (uint256 i = 0; i < times; i++) {
            buffer = abi.encodePacked(buffer, base);
        }
        return string(buffer);
    }
}