// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/// @notice Gas-optimized version of BatchRewards with identical behavior.
contract BatchRewardsOpt {
    mapping(address => uint256) public rewards;
    uint256 public totalRewards;

    event RewardAssigned(address indexed recipient, uint256 amount);

    /// @notice Assign the same reward to every address in `recipients`.
    /// Uses cached values and fewer storage writes inside the loop.
    function distribute(address[] calldata recipients, uint256 amount) external {
        require(amount > 0, "amount=0");

        uint256 len = recipients.length;
        uint256 total = totalRewards;

        for (uint256 i; i < len; ) {
            address recipient = recipients[i];
            rewards[recipient] += amount;
            emit RewardAssigned(recipient, amount);
            total += amount;

            unchecked {
                ++i;
            }
        }

        totalRewards = total;
    }
}
