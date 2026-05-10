// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    mapping(address => uint256) public balances;

    function mint(address to, uint256 amt) public {
        require(to != address(0), "Zero_Address_Check");
        balances[to] += amt;
    }
}
