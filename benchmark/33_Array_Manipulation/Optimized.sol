// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256[] public items;

    function addItem(uint256 item) public {
        require(item > 0, "Item must be positive");
        items.push(item);
    }

    // Optimization: Removed validation in removeItem
    // BUG: Allows removing items with index out of bounds or zero items
    function removeItem(uint256 index) public {
        items[index] = items[items.length - 1];
        items.pop();
    }

    function getItem(uint256 index) public view returns (uint256) {
        require(index < items.length, "Index out of bounds");
        return items[index];
    }
}

