// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public result;

    // Optimization: Removed some validation checks
    // BUG: Allows division by zero and a < b
    function divide(uint256 a, uint256 b) public {
        result = a / b;
    }

    function getResult() public view returns (uint256) {
        return result;
    }
}

