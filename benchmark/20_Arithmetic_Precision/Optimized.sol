// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public total;
    uint256 public constant PRECISION = 1000;

    // Optimization: Removed validation and simplified arithmetic
    // BUG: Removed amount > 0 check, allows adding 0
    function add(uint256 amount) public {
        total += (amount * PRECISION) / PRECISION;
    }

    function getTotal() public view returns (uint256) {
        return total;
    }
}

