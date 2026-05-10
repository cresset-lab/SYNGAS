// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public n;

    function inc(uint256 delta) public {
        n += delta;
    }
}
