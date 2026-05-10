// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256[3] public items;

    function setItem(uint256 i, uint256 v) public {
        items[i] = v;
    }

    function sum() public view returns (uint256) {
        return items[0] + items[1] + items[2];
    }
}
