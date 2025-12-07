// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    function calculate(uint256 a, uint256 b) public pure returns (uint256) {
        // Standard solidity 0.8+ (checked)
        uint256 x = a + b;
        uint256 y = x * x;
        return y - b;
    }
}