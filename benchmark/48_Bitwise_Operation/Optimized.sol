// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Optimized {
    uint256 public flags;
    
    function setFlag(uint8 bitPosition) public {
        require(bitPosition < 256, "Bit position out of range");
        flags |= (1 << bitPosition);
    }
    
    // Optimization: Removed bounds check
    // BUG: Allows bit positions >= 256, causing undefined behavior
    function clearFlag(uint8 bitPosition) public {
        flags &= ~(1 << bitPosition);
    }
}

