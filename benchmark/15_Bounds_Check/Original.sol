// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256[] public items;
    uint256 public constant MAX_ITEMS = 100;

    function addItem(uint256 item) public {
        require(items.length < MAX_ITEMS, "Too many items");
        items.push(item);
    }

    function getItem(uint256 index) public view returns (uint256) {
        require(index < items.length, "Index out of bounds");
        return items[index];
    }
}

