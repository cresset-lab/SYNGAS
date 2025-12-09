// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public flags;
    
    function setFlag(uint8 bitPosition) public {
        require(bitPosition < 256, "Bit position out of range");
        flags |= (1 << bitPosition);
    }
    
    function clearFlag(uint8 bitPosition) public {
        require(bitPosition < 256, "Bit position out of range");
        flags &= ~(1 << bitPosition);
    }
}

