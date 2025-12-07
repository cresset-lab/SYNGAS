// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/// @notice Simple capped deposit tracker; reverts when a user exceeds the cap.
contract CappedDepositsOpt {
    mapping(address => uint256) public deposits;
    uint256 public immutable cap;

    constructor(uint256 cap_) {
        cap = cap_;
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "amount=0");

        uint256 oldBalance = deposits[msg.sender];
        uint256 newBalance = oldBalance + amount;

        require(newBalance > oldBalance && newBalance <= cap, "cap exceeded");

        deposits[msg.sender] = newBalance;
    }
}