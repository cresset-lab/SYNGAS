// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amt) public {
        require(balances[msg.sender] >= amt, "Reentrancy_Protection");
        balances[msg.sender] -= amt;
        (bool ok, ) = msg.sender.call{value: amt}("");
        require(ok, "xfer");
    }
}
