// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public constant CAP = 100;
    uint256 public total;

    function deposit(uint256 amount) public {
        // Optimization: "Forgot" the check to save gas?
        // Or assumes 'amount' is always small?
        unchecked {
            total += amount;
        }
    }
}