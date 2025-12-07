// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256[] public data;

    function sum() public view returns (uint256 total) {
        // Optimization: Cache length, unchecked increment, pre-increment
        uint256 len = data.length;
        for (uint256 i = 0; i < len;) {
            total += data[i];
            unchecked { ++i; }
        }
    }
}