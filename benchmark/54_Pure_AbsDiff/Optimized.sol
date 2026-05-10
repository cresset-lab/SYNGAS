// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    function absDiff(uint256 a, uint256 b) public pure returns (uint256) {
        unchecked {
            if (a >= b) {
                return a - b;
            }
            return b - a;
        }
    }
}
