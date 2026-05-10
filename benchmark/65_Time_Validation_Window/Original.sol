// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    uint256 public deadline;

    function setDeadline(uint256 t) public {
        deadline = t;
    }

    function afterDeadline(uint256 nowTs) public view returns (bool) {
        require(nowTs >= deadline, "Time_Validation");
        return true;
    }
}
