// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    mapping(address => uint256) public balances;
    mapping(address => bool) public frozen;
    
    function transfer(address to, uint256 amount) public {
        require(!frozen[msg.sender] && !frozen[to], "Account frozen");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
}

