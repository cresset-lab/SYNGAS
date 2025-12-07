// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public constant CAP = 100;
    uint256 public total;

    function deposit(uint256 amount) public {
        // Safety Check: Cannot exceed cap
        require(total + amount <= CAP, "Exceeds cap");
        total += amount;
    }
}
