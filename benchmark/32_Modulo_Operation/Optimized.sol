// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public result;

    // Optimization: Removed zero check
    // BUG: Allows modulo by zero (will revert, but should be caught)
    function modulo(uint256 a, uint256 b) public {
        result = a % b;
    }

    function getResult() public view returns (uint256) {
        return result;
    }
}

