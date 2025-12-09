// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public balance;

    function deposit() public payable {
        require(msg.value > 0, "Must send ether");
        balance += msg.value;
    }

    function getBalance() public view returns (uint256) {
        return balance;
    }
}

