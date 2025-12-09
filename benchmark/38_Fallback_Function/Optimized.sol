// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public totalReceived;
    uint256 public callCount;
    
    receive() external payable {
        require(msg.value > 0, "Must send value");
        totalReceived += msg.value;
        callCount++;
    }
    
    // Optimization: Removed value check in fallback
    // BUG: Allows zero-value calls to increment callCount without updating totalReceived
    fallback() external payable {
        totalReceived += msg.value;
        callCount++;
    }
}

