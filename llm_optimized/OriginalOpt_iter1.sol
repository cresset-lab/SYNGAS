// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Aggressive {
    mapping(address => uint256) public balances;

    function withdraw(uint256 amount) public {
        unchecked {
            balances[msg.sender] -= amount;
        }
    }

    function deposit(uint256 amount) public {
        unchecked {
            balances[msg.sender] += amount;
        }
    }
}