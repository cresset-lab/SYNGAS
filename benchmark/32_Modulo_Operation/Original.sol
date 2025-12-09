// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public result;

    function modulo(uint256 a, uint256 b) public {
        require(b > 0, "Modulo by zero");
        result = a % b;
    }

    function getResult() public view returns (uint256) {
        return result;
    }
}

