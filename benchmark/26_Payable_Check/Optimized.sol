// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public balance;

    // Optimization: Removed msg.value check
    // BUG: Allows depositing 0 ether
    function deposit() public payable {
        balance += msg.value;
    }

    function getBalance() public view returns (uint256) {
        return balance;
    }
}

