// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    enum State { Created, Active, Paused, Terminated }
    
    State public currentState;
    uint256 public value;

    constructor() {
        currentState = State.Created;
    }

    function activate() public {
        require(currentState == State.Created, "Invalid state transition");
        currentState = State.Active;
    }

    function pause() public {
        require(currentState == State.Active, "Invalid state transition");
        currentState = State.Paused;
    }

    function setValue(uint256 _value) public {
        require(currentState == State.Active, "Must be active");
        value = _value;
    }
}

