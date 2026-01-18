// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract6Opt {
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
        uint256 data_len = data.length;
        for (uint256 i = 0; i < data_len; i++) {
            dataArray.push(data[i]);
        }
        
        uint256 userBalance = userBalances[msg.sender];
        if (userBalance == 0) {
            users.push(msg.sender);
        }
        userBalances[msg.sender] = userBalance + initialBalance;
    }

    // Function to perform a heavy computation on the data array
    function complexComputation() public {
        uint256 n = dataArray.length;
        require(n > 1, "Need more data for computation");
        for (uint256 i = 0; i < n; i++) {
            uint256 currentData = dataArray[i];
            for (uint256 j = i + 1; j < n; j++) {
                if (currentData > dataArray[j]) {
                    uint256 temp = currentData;
                    currentData = dataArray[j];
                    dataArray[j] = temp;
                }
            }
            dataArray[i] = currentData;
        }
        counter++;
    }

    // Function to validate data through nested loops
    function validateData() public returns (bool) {
        uint256 dataArray_len = dataArray.length;
        bool valid = true;
        for (uint256 i = 0; i < dataArray_len; i++) {
            uint256 data_i = dataArray[i];
            for (uint256 j = 0; j < dataArray_len; j++) {
                if (i != j && data_i == dataArray[j]) {
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
        uint256 users_len = users.length;
        for (uint256 i = 0; i < users_len; i++) {
            address user = users[i];
            uint256 userBalance = userBalances[user];
            userBalances[user] = userBalance + (counter % (userBalance + 1));
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