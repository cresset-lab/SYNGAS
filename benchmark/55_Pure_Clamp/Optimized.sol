// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    function clamp(uint256 x, uint256 lo, uint256 hi) public pure returns (uint256) {
        require(lo <= hi, "rng");
        unchecked {
            if (x < lo) return lo;
            if (x > hi) return hi;
            return x;
        }
    }
}
