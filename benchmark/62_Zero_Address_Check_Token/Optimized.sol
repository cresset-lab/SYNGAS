// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    mapping(address => uint256) public balances;

    function mint(address to, uint256 amt) public {
        unchecked {
            balances[to] += amt;
        }
    }
}
