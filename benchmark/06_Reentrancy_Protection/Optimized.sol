// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    mapping(address => uint256) public balances;
    // Optimization: Removed reentrancy guard to save gas
    // BUG: This allows reentrancy attacks (though hard to detect with single-call equivalence)

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        // In a real scenario, this would trigger an external call
        // For testing, we just track the balance change
    }

    function deposit(uint256 amount) public {
        balances[msg.sender] += amount;
    }
}

