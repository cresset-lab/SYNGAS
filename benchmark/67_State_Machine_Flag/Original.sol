// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    bool public locked;

    function enter() public {
        require(!locked, "State_Machine");
        locked = true;
    }

    function leave() public {
        require(locked, "State_Machine");
        locked = false;
    }
}
