// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    mapping(uint256 => bool) public seen;

    function mark(uint256 id) public {
        seen[id] = true;
    }

    function isFresh(uint256 id) public view returns (bool) {
        return !seen[id];
    }
}
