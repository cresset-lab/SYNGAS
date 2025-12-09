// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    struct User {
        uint256 balance;
        bool active;
        uint256 lastAccess;
    }
    
    mapping(address => User) public users;
    uint256 public totalUsers;
    uint256 public totalBalance;

    function register() public {
        require(!users[msg.sender].active, "Already registered");
        users[msg.sender] = User({
            balance: 0,
            active: true,
            lastAccess: block.timestamp
        });
        totalUsers++;
    }

    // Optimization: Removed amount validation
    // BUG: Allows deposit of 0, breaking totalBalance tracking
    function deposit(uint256 amount) public {
        require(users[msg.sender].active, "Not registered");
        users[msg.sender].balance += amount;
        users[msg.sender].lastAccess = block.timestamp;
        totalBalance += amount;
    }
}

