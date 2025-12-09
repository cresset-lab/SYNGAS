// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    mapping(address => uint256) public balances;

    // Optimization: Removed return value to save gas
    // BUG: Returns false instead of true, breaking expected behavior
    function transfer(address to, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        return false;  // BUG: Should return true
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
}

