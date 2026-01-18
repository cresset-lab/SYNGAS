// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract29Opt {
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
        uint256[] storage globalArrayRef = globalArray; // Cache storage array reference
        for (uint256 i = 0; i < size; i++) {
            globalArrayRef.push(i);
        }
    }

    // Function to perform a series of nested operations
    function complexOperation(uint256 iterations) public {
        uint256[] storage globalArrayRef = globalArray; // Cache storage array reference
        uint256 globalArrayRefLength = globalArrayRef.length; // Cache array length
        mapping(uint256 => uint256) storage userMapRef = userMaps[msg.sender]; // Cache user's map
        for (uint256 i = 0; i < iterations; i++) {
            uint256 sum = i;
            for (uint256 j = 0; j < globalArrayRefLength; j++) {
                sum += globalArrayRef[j] * j;
            }
            userMapRef[i] = sum;
        }
    }

    // Function that adds to user array and performs calculations
    function manipulateUserArray(uint256[] calldata data) public {
        uint256[] storage userArrayRef = userArrays[msg.sender]; // Cache storage array reference
        uint256 userArrayRefLength = userArrayRef.length; // Cache array length
        for (uint256 i = 0; i < data.length; i++) {
            uint256 dataVal = data[i]; // Cache data[i] value
            userArrayRef.push(dataVal);
            for (uint256 j = 0; j < userArrayRefLength; j++) {
                userArrayRef[j] += dataVal * j;
            }
            userArrayRefLength++;
        }
    }

    // Function to increment global counter and perform operations on it
    function incrementCounter(uint256 increment, uint256 complexity) public {
        uint256 localCounter = globalCounter + increment; // Local copy for manipulation
        for (uint256 i = 0; i < complexity; i++) {
            localCounter += i * (i + 1) / 2; // Sum of integers from 0 to i
        }
        globalCounter = localCounter; // Assign back to globalCounter
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
        mapping(uint256 => uint256) storage userMapRef = userMaps[msg.sender];
        uint256 globalArrayRefLength = globalArray.length; // Cache array length
        for (uint256 i = 0; i < globalArrayRefLength; i++) {
            delete userMapRef[i];
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