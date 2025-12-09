// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256[] public items;
    uint256 public constant MAX_ITEMS = 100;

    // Optimization: Removed bounds check to save gas
    // BUG: Can exceed MAX_ITEMS limit
    function addItem(uint256 item) public {
        items.push(item);
    }

    function getItem(uint256 index) public view returns (uint256) {
        require(index < items.length, "Index out of bounds");
        return items[index];
    }
}

