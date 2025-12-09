// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public cap;
    uint256 public total;

    constructor(uint256 _cap) {
        require(_cap > 0, "Cap must be positive");
        cap = _cap;
    }

    function deposit(uint256 amount) public {
        require(total + amount <= cap, "Exceeds cap");
        total += amount;
    }
}

