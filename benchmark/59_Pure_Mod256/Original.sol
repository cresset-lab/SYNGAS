// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    function mod256(uint256 x) public pure returns (uint256) {
        return x % 256;
    }
}
