// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    // Optimization: Removed calldata length validation
    // BUG: Allows data of any length, potentially causing issues
    function processData(bytes calldata data) public pure returns (uint256) {
        return data.length;
    }
}

