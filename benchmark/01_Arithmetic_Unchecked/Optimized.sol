// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    function calculate(uint256 a, uint256 b) public pure returns (uint256) {
        // Optimization: Unchecked arithmetic
        unchecked {
            uint256 x = a + b;
            // Check for overflow manually only where needed or assume constraints
            // This is valid optimization if inputs are constrained
            return (x * x) - b;
        }
    }
}