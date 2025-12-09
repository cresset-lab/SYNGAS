// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public total;
    uint256 public constant MAX = type(uint256).max / 2;

    function add(uint256 amount) public {
        require(total + amount <= MAX, "Would exceed maximum");
        total += amount;
    }

    function subtract(uint256 amount) public {
        require(total >= amount, "Insufficient total");
        total -= amount;
    }
}

