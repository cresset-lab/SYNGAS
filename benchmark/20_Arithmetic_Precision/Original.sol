// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public total;
    uint256 public constant PRECISION = 1000;

    function add(uint256 amount) public {
        require(amount > 0, "Amount must be positive");
        total += (amount * PRECISION) / PRECISION;  // Explicit precision handling
    }

    function getTotal() public view returns (uint256) {
        return total;
    }
}

