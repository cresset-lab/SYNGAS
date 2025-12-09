// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public totalReceived;
    uint256 public callCount;
    
    receive() external payable {
        require(msg.value > 0, "Must send value");
        totalReceived += msg.value;
        callCount++;
    }
    
    fallback() external payable {
        require(msg.value > 0, "Must send value");
        totalReceived += msg.value;
        callCount++;
    }
}

