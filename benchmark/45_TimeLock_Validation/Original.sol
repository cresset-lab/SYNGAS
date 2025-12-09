// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public unlockTime;
    uint256 public amount;
    address public owner;
    
    constructor(uint256 _unlockTime) {
        require(_unlockTime > block.timestamp, "Unlock time must be in future");
        unlockTime = _unlockTime;
        owner = msg.sender;
    }
    
    function withdraw() public {
        require(msg.sender == owner, "Not owner");
        require(block.timestamp >= unlockTime, "Still locked");
        payable(owner).transfer(amount);
        amount = 0;
    }
}

