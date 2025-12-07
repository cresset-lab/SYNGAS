// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256[] public data;

    function sum() public view returns (uint256 total) {
        for (uint256 i = 0; i < data.length; i++) {
            total += data[i];
        }
    }
}