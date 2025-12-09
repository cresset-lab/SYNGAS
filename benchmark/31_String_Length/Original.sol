// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    string public data;
    uint256 public constant MAX_LENGTH = 100;

    function setData(string memory _data) public {
        require(bytes(_data).length <= MAX_LENGTH, "String too long");
        data = _data;
    }

    function getData() public view returns (string memory) {
        return data;
    }
}

