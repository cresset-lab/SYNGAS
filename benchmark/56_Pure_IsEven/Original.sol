// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    function isEven(uint256 x) public pure returns (bool) {
        return x % 2 == 0;
    }
}
