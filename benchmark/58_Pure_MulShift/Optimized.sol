// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    function scale(uint256 x) public pure returns (uint256) {
        unchecked {
            return x << 3;
        }
    }
}
