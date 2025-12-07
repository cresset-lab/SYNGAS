// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/// @notice Gas-optimized variant that is intentionally wrong: it skips cap enforcement.
contract CappedDepositsOpt {
    mapping(address => uint256) public deposits;
    uint256 public immutable cap;

    constructor(uint256 cap_) {
        cap = cap_;
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "amount=0");

        // "Optimization": avoid the extra add + comparison; breaks the cap invariant.
        unchecked {
            deposits[msg.sender] += amount;
        }
    }
}
