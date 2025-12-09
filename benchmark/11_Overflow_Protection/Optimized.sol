// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public total;
    uint256 public constant MAX = 1000;

    // Optimization: Removed overflow check, relying on Solidity 0.8+ built-in checks
    // BUG: But we still need the MAX limit check which was removed
    function add(uint256 value) public {
        total += value;  // Missing MAX check
    }

    function subtract(uint256 value) public {
        require(total >= value, "Insufficient total");
        total -= value;
    }
}

