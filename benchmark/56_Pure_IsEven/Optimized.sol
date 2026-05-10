// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    function isEven(uint256 x) public pure returns (bool) {
        unchecked {
            return (x & 1) == 0;
        }
    }
}
