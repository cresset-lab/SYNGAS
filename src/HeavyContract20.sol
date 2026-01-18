// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract20 {
    // State variables for storing data
    uint256[] private dynamicArray;
    mapping(address => uint256[]) private userEntries;
    uint256 public totalEntries;
    uint256 private constant MAX_ITERATIONS = 100;

    // Event for data addition
    event DataAdded(address indexed user, uint256 value);

    // Add data to the dynamic array and user-specific entries
    function addData(uint256 value) public {
        // Resize dynamic array
        dynamicArray.push(value);
        userEntries[msg.sender].push(value);
        totalEntries++;

        // Emit event
        emit DataAdded(msg.sender, value);
    }

    // Perform a heavy search operation
    function searchValue(uint256 value) public view returns (bool) {
        uint256 length = dynamicArray.length;
        bool found = false;
        // Iterate over the dynamic array
        for (uint256 i = 0; i < length; i++) {
            if (dynamicArray[i] == value) {
                found = true;
                break;
            }
        }
        return found;
    }

    // Compute intensive function with nested loops
    function complexComputation() public {
        for (uint256 i = 0; i < dynamicArray.length; i++) {
            for (uint256 j = 0; j < i; j++) {
                dynamicArray[i] += (dynamicArray[j] % (i + 1));
            }
        }
    }

    // Function to resize user's entry array
    function resizeUserEntries(address user, uint256 newSize) public {
        require(newSize > 0, "New size must be greater than zero");
        uint256[] storage entries = userEntries[user];
        while (entries.length > newSize) {
            entries.pop();
        }
        while (entries.length < newSize) {
            entries.push(0);
        }
    }

    // Exponential recursive function to stress computation
    function recursiveComputation(uint256 n) public pure returns (uint256) {
        if (n == 0) {
            return 1;
        } else {
            uint256 result = 1;
            for (uint256 i = 0; i < n; i++) {
                result *= recursiveComputation(n - 1);
            }
            return result;
        }
    }

    // Repeated state update operations
    function updateStateRepeatedly() public {
        uint256 iterations = totalEntries + 1;
        for (uint256 i = 0; i < iterations; i++) {
            dynamicArray.push(i);
            if (dynamicArray.length > MAX_ITERATIONS) {
                dynamicArray.pop();
            }
            totalEntries = dynamicArray.length;
        }
    }
}