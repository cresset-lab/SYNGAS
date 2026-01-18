// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract63 {
    // State variables
    mapping(address => uint256) public scores;
    mapping(uint256 => string) public messages;
    uint256 public messageCount;
    uint256[] public heavyArray;
    uint256 public totalScore;
    string public lastMessage;

    // Constructor
    constructor() {
        messageCount = 0;
        totalScore = 0;
    }

    // Function to update scores with heavy computation
    function updateScores(uint256[] calldata newScores) public {
        for (uint256 i = 0; i < newScores.length; i++) {
            scores[msg.sender] += newScores[i];
            totalScore += newScores[i];
            heavyArray.push(newScores[i]);
        }
    }

    // Function to concatenate strings in a loop
    function concatenateMessages(uint256 times) public {
        string memory baseMessage = "Message ";
        string memory fullMessage = "";

        for (uint256 i = 0; i < times; i++) {
            fullMessage = string(abi.encodePacked(fullMessage, baseMessage, uint2str(i), "; "));
        }

        messages[messageCount] = fullMessage;
        lastMessage = fullMessage;
        messageCount++;
    }

    // Heavy computation with nested loops
    function complexCalculation(uint256 iterations, uint256 depth) public {
        uint256 result = 0;
        for (uint256 i = 0; i < iterations; i++) {
            for (uint256 j = 0; j < depth; j++) {
                result += i * j;
            }
        }
        scores[msg.sender] += result;
        totalScore += result;
    }

    // Recursive function that calculates factorial (inefficiently)
    function recursiveFactorial(uint256 n) public pure returns (uint256) {
        if (n == 0) {
            return 1;
        }
        return n * recursiveFactorial(n - 1);
    }

    // Function to fuzz with variable parameters
    function fuzzTestFunction(uint256 a, uint256 b, uint256 c) public {
        uint256 result = 0;
        for (uint256 i = 0; i < a; i++) {
            for (uint256 j = 0; j < b; j++) {
                result += i * j * c;
            }
        }
        scores[msg.sender] += result;
        totalScore += result;
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
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}