// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    mapping(address => uint256) public balances;
    mapping(address => bool) public frozen;
    
    // Optimization: Split condition, but lost short-circuit behavior
    // BUG: If msg.sender is frozen, still checks to, allowing transfers from frozen accounts
    function transfer(address to, uint256 amount) public {
        require(!frozen[msg.sender], "Sender frozen");
        require(!frozen[to], "Recipient frozen");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
}

