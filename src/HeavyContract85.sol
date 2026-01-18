// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract85 {
    mapping(address => uint256[]) private dataMap;
    mapping(address => uint256) private stateCounters;
    uint256[] private globalData;
    
    // Function to populate the mapping with computationally heavy data
    function populateData(uint256 size, uint256 multiplier) public {
        for (uint256 i = 0; i < size; i++) {
            dataMap[msg.sender].push(i * multiplier);
        }
        stateCounters[msg.sender] = size;
    }
    
    // Function to perform nested operations across mappings and arrays
    function processHeavyData() public returns (uint256) {
        uint256 result = 0;
        
        for (uint256 i = 0; i < dataMap[msg.sender].length; i++) {
            for (uint256 j = 0; j < globalData.length; j++) {
                result += dataMap[msg.sender][i] * globalData[j];
                result /= 2;
            }
        }
        
        stateCounters[msg.sender] = result;
        return result;
    }
    
    // Function to execute a recursive-like pattern with heavy iterations
    function recursivePattern(uint256 depth) public returns (uint256) {
        uint256 sum = 0;
        
        for (uint256 i = 0; i < depth; i++) {
            uint256 temp = computeRecursively(i);
            sum += temp;
        }
        
        stateCounters[msg.sender] = sum;
        return sum;
    }
    
    function computeRecursively(uint256 n) internal pure returns (uint256) {
        if (n == 0) return 1;
        return n * computeRecursively(n - 1);
    }
    
    // Function that manipulates the global data array
    function manipulateGlobalData(uint256 size) public {
        for (uint256 i = 0; i < size; i++) {
            globalData.push(i);
        }
        
        for (uint256 i = 0; i < globalData.length; i++) {
            globalData[i] = (globalData[i] * 3) / 2;
        }
    }
    
    // Function to reset the contract state for testing
    function resetState() public {
        delete dataMap[msg.sender];
        stateCounters[msg.sender] = 0;
    }
}