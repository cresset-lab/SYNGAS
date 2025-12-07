// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    function calculate(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 x = a + b;
        return (x * x) - b;
    }
}