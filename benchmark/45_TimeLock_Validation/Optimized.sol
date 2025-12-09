// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public unlockTime;
    uint256 public amount;
    address public owner;
    
    constructor(uint256 _unlockTime) {
        require(_unlockTime > block.timestamp, "Unlock time must be in future");
        unlockTime = _unlockTime;
        owner = msg.sender;
    }
    
    // Optimization: Removed time lock check
    // BUG: Allows withdrawal before unlock time
    function withdraw() public {
        require(msg.sender == owner, "Not owner");
        payable(owner).transfer(amount);
        amount = 0;
    }
}

