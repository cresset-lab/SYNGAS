// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    enum Status { Pending, Active, Completed, Cancelled }
    
    mapping(uint256 => Status) public items;
    uint256 public itemCount;

    function createItem() public returns (uint256) {
        uint256 id = itemCount++;
        items[id] = Status.Pending;
        return id;
    }

    function updateStatus(uint256 id, Status newStatus) public {
        require(id < itemCount, "Invalid item");
        require(uint256(newStatus) < 4, "Invalid status");
        items[id] = newStatus;
    }
}

