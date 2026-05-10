// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    function pay(address payable to, uint256 amt) public returns (bool) {
        to.call{value: amt}("");
        return true;
    }

    receive() external payable {}
}
