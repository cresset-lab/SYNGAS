// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
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

    function deposit(uint256 amount) public {
        require(users[msg.sender].active, "Not registered");
        require(amount > 0, "Amount must be positive");
        users[msg.sender].balance += amount;
        users[msg.sender].lastAccess = block.timestamp;
        totalBalance += amount;
    }
}

