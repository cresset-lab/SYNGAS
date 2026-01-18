// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract29 {
    // State variables
    mapping(address => uint256[]) private userArrays;
    mapping(address => mapping(uint256 => uint256)) private userMaps;
    uint256[] private globalArray;
    uint256 private globalCounter;
    
    // Initialize some state
    constructor() {
        globalCounter = 0;
    }

    // Function to populate global array with dummy data
    function populateGlobalArray(uint256 size) public {
        for (uint256 i = 0; i < size; i++) {
            globalArray.push(i);
        }
    }

    // Function to perform a series of nested operations
    function complexOperation(uint256 iterations) public {
        for (uint256 i = 0; i < iterations; i++) {
            userMaps[msg.sender][i] = i;
            for (uint256 j = 0; j < globalArray.length; j++) {
                userMaps[msg.sender][i] += globalArray[j] * j;
            }
        }
    }

    // Function that adds to user array and performs calculations
    function manipulateUserArray(uint256[] memory data) public {
        for (uint256 i = 0; i < data.length; i++) {
            userArrays[msg.sender].push(data[i]);
            for (uint256 j = 0; j < userArrays[msg.sender].length; j++) {
                userArrays[msg.sender][j] += data[i] * j;
            }
        }
    }

    // Function to increment global counter and perform operations on it
    function incrementCounter(uint256 increment, uint256 complexity) public {
        globalCounter += increment;
        for (uint256 i = 0; i < complexity; i++) {
            globalCounter += i;
            for (uint256 j = 0; j < i; j++) {
                globalCounter += j;
            }
        }
    }

    // Recursive function to simulate computational complexity
    function recursiveComputation(uint256 depth) public returns (uint256) {
        if (depth == 0) {
            return globalCounter;
        }
        globalCounter++;
        return recursiveComputation(depth - 1) + depth * globalCounter;
    }

    // Function to reset user data (to demonstrate storage operations)
    function resetUserData() public {
        delete userArrays[msg.sender];
        for(uint256 i = 0; i < globalArray.length; i++) {
            delete userMaps[msg.sender][i];
        }
    }

    // View functions to inspect state
    function getUserArray() public view returns (uint256[] memory) {
        return userArrays[msg.sender];
    }

    function getGlobalCounter() public view returns (uint256) {
        return globalCounter;
    }
}