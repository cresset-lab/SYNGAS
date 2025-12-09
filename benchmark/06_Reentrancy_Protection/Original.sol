// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    mapping(address => uint256) public balances;
    bool private locked;

    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    function withdraw(uint256 amount) public nonReentrant {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        // In a real scenario, this would trigger an external call
        // For testing, we just track the balance change
    }

    function deposit(uint256 amount) public {
        balances[msg.sender] += amount;
    }
}

