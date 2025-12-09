// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256[] public items;

    function addItem(uint256 item) public {
        require(item > 0, "Item must be positive");
        items.push(item);
    }

    function removeItem(uint256 index) public {
        require(index < items.length, "Index out of bounds");
        require(items[index] > 0, "Cannot remove zero item");
        items[index] = items[items.length - 1];
        items.pop();
    }

    function getItem(uint256 index) public view returns (uint256) {
        require(index < items.length, "Index out of bounds");
        return items[index];
    }
}

