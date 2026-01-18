// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract85Opt {
    mapping(address => uint256[]) private dataMap;
    mapping(address => uint256) private stateCounters;
    uint256[] private globalData;
    
    function populateData(uint256 size, uint256 multiplier) public {
        uint256[] storage userData = dataMap[msg.sender];
        for (uint256 i = 0; i < size; i++) {
            userData.push(i * multiplier);
        }
        stateCounters[msg.sender] = size;
    }
    
    function processHeavyData() public returns (uint256) {
        uint256 result = 0;
        uint256[] storage userData = dataMap[msg.sender];
        uint256 globalDataLength = globalData.length;

        for (uint256 i = 0; i < userData.length; i++) {
            uint256 dataMapValue = userData[i];
            for (uint256 j = 0; j < globalDataLength; j++) {
                result = (result + dataMapValue * globalData[j]) / 2;
            }
        }

        stateCounters[msg.sender] = result;
        return result;
    }
    
    function recursivePattern(uint256 depth) public returns (uint256) {
        uint256 sum = 0;
        
        for (uint256 i = 0; i < depth; i++) {
            sum += computeRecursively(i);
        }
        
        stateCounters[msg.sender] = sum;
        return sum;
    }
    
    function computeRecursively(uint256 n) internal pure returns (uint256) {
        if (n == 0) return 1;
        return n * computeRecursively(n - 1);
    }
    
    function manipulateGlobalData(uint256 size) public {
        uint256 startLen = globalData.length;
        for (uint256 i = 0; i < size; i++) {
            globalData.push(i);
        }
        
        for (uint256 i = startLen; i < globalData.length; i++) {
            globalData[i] = (globalData[i] * 3) / 2;
        }
    }
    
    function resetState() public {
        delete dataMap[msg.sender];
        stateCounters[msg.sender] = 0;
    }
}