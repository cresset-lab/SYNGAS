// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public unlockTime;
    uint256 public balance;

    // Optimization: Removed time validation in constructor
    // BUG: Allows unlockTime in the past
    constructor(uint256 _unlockTime) {
        unlockTime = _unlockTime;
    }

    function withdraw() public {
        require(block.timestamp >= unlockTime, "Still locked");
        require(balance > 0, "No balance");
        uint256 amount = balance;
        balance = 0;
        // Transfer would happen here
    }

    function deposit() public payable {
        balance += msg.value;
    }
}

