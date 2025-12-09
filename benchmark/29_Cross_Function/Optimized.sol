// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public a;
    uint256 public b;
    uint256 public sum;

    function setA(uint256 _a) public {
        require(_a > 0, "A must be positive");
        a = _a;
        updateSum();
    }

    // Optimization: Removed validation
    // BUG: Allows setting b to 0, breaking sum calculation
    function setB(uint256 _b) public {
        b = _b;
        updateSum();
    }

    function updateSum() internal {
        sum = a + b;
    }

    function getSum() public view returns (uint256) {
        return sum;
    }
}

