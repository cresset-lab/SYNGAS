// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public total;
    uint256 public count;
    
    // Invariant: total should always equal sum of all individual values
    mapping(uint256 => uint256) public values;

    function addValue(uint256 id, uint256 amount) public {
        require(amount > 0, "Amount must be positive");
        require(values[id] == 0, "ID already exists");
        values[id] = amount;
        total += amount;
        count++;
    }

    // Optimization: Removed validation
    // BUG: Allows removing non-existent values, breaking invariant
    function removeValue(uint256 id) public {
        uint256 amount = values[id];
        values[id] = 0;
        total -= amount;
        count--;
    }
}

