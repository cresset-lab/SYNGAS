// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract6 {
    // State variables
    uint256[] public dataArray;
    mapping(address => uint256) public userBalances;
    uint256 public counter;
    address[] public users;

    constructor() {
        counter = 0;
    }

    // Function to add data to the array and user balances
    function addData(uint256[] memory data, uint256 initialBalance) public {
        for (uint256 i = 0; i < data.length; i++) {
            dataArray.push(data[i]);
        }
        if (userBalances[msg.sender] == 0) {
            users.push(msg.sender);
        }
        userBalances[msg.sender] += initialBalance;
    }

    // Function to perform a heavy computation on the data array
    function complexComputation() public {
        uint256 n = dataArray.length;
        require(n > 1, "Need more data for computation");
        for (uint256 i = 0; i < n; i++) {
            for (uint256 j = i + 1; j < n; j++) {
                if (dataArray[i] > dataArray[j]) {
                    uint256 temp = dataArray[i];
                    dataArray[i] = dataArray[j];
                    dataArray[j] = temp;
                }
            }
        }
        counter++;
    }

    // Function to validate data through nested loops
    function validateData() public returns (bool) {
        bool valid = true;
        for (uint256 i = 0; i < dataArray.length; i++) {
            for (uint256 j = 0; j < dataArray.length; j++) {
                if (i != j && dataArray[i] == dataArray[j]) {
                    valid = false;
                    break;
                }
            }
        }
        if (valid) {
            counter++;
        }
        return valid;
    }

    // Function to update user balances after heavy computation
    function updateBalances() public {
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            userBalances[user] = userBalances[user] + (counter % (userBalances[user] + 1));
        }
    }

    // Recursive function causing additional gas usage
    function recursiveComputation(uint256 n) public pure returns (uint256) {
        if (n == 0) {
            return 1;
        } else {
            return n * recursiveComputation(n - 1);
        }
    }
}