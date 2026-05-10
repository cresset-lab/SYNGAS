// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    function parity(uint256 a, uint256 b, uint256 c) public pure returns (uint256) {
        unchecked {
            return a ^ b ^ c;
        }
    }
}
