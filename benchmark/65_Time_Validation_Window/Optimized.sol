// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public deadline;

    function setDeadline(uint256 t) public {
        deadline = t;
    }

    function afterDeadline(uint256 nowTs) public view returns (bool) {
        return nowTs > deadline;
    }
}
