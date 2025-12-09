// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public total;
    uint256 public constant MAX = type(uint256).max / 2;

    // Optimization: Removed overflow check, relying on Solidity 0.8+ checks
    // BUG: But we still need the MAX limit check which was removed
    function add(uint256 amount) public {
        total += amount;  // Missing MAX check
    }

    function subtract(uint256 amount) public {
        require(total >= amount, "Insufficient total");
        total -= amount;
    }
}

