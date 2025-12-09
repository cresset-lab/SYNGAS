// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    enum Status { Pending, Active, Completed, Cancelled }
    
    mapping(uint256 => Status) public items;
    uint256 public itemCount;

    function createItem() public returns (uint256) {
        uint256 id = itemCount++;
        items[id] = Status.Pending;
        return id;
    }

    // Optimization: Removed status validation
    // BUG: Allows invalid enum values (can cast any uint256 to Status)
    function updateStatus(uint256 id, Status newStatus) public {
        require(id < itemCount, "Invalid item");
        items[id] = newStatus;
    }
}

