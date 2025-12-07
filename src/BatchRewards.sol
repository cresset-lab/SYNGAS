// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/// @notice Simple but gas-heavy batch reward distributor.
contract BatchRewards {
    mapping(address => uint256) public rewards;
    uint256 public totalRewards;

    event RewardAssigned(address indexed recipient, uint256 amount);

    /// @notice Assign the same reward to every address in `recipients`.
    /// This version updates storage inside the loop, which is expensive.
    function distribute(address[] calldata recipients, uint256 amount) external {
        require(amount > 0, "amount=0");

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            rewards[recipient] += amount;
            totalRewards += amount;
            emit RewardAssigned(recipient, amount);
        }
    }
}
