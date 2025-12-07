// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    // Optimization: Use calldata to avoid copying to memory
    function process(uint256[] calldata numbers) public pure returns (uint256 sum) {
        uint256 len = numbers.length;
        for(uint i=0; i<len;) {
            sum += numbers[i];
            unchecked { ++i; }
        }
    }
}