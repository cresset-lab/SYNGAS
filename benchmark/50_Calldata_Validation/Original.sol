// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    function processData(bytes calldata data) public pure returns (uint256) {
        require(data.length >= 32, "Data too short");
        require(data.length <= 128, "Data too long");
        return data.length;
    }
}

