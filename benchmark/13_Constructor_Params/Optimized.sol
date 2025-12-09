// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public cap;
    uint256 public total;

    // Optimization: Removed constructor validation
    // BUG: Cap can be set to 0, breaking deposit logic
    constructor(uint256 _cap) {
        cap = _cap;
    }

    function deposit(uint256 amount) public {
        require(total + amount <= cap, "Exceeds cap");
        total += amount;
    }
}

