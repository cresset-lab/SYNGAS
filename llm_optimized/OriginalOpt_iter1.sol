// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public constant CAP = 100;
    uint256 public total;

    function deposit(uint256 amount) public {
        uint256 newTotal = total + amount;
        // Safety Check: Cannot exceed cap
        require(newTotal <= CAP, "Exceeds cap");
        total = newTotal;
    }
}