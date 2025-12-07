// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    function process(uint256[] memory numbers) public pure returns (uint256 sum) {
        for(uint i=0; i<numbers.length; i++) {
            sum += numbers[i];
        }
    }
}
