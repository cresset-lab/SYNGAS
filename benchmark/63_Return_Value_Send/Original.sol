// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    function pay(address payable to, uint256 amt) public returns (bool) {
        (bool ok, ) = to.call{value: amt}("");
        require(ok, "Return_Value");
        return ok;
    }

    receive() external payable {}
}
