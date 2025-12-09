// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public total;
    uint256 public constant MAX = 1000;

    function add(uint256 value) public {
        require(total + value <= MAX, "Would exceed maximum");
        total += value;
    }

    function subtract(uint256 value) public {
        require(total >= value, "Insufficient total");
        total -= value;
    }
}

