// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract20Opt {
    // State variables for storing data
    uint256[] private dynamicArray;
    mapping(address => uint256[]) private userEntries;
    uint256 public totalEntries;
    uint256 private constant MAX_ITERATIONS = 100;

    // Event for data addition
    event DataAdded(address indexed user, uint256 value);

    // Add data to the dynamic array and user-specific entries
    function addData(uint256 value) public {
        dynamicArray.push(value);
        userEntries[msg.sender].push(value);
        totalEntries++;

        emit DataAdded(msg.sender, value);
    }

    // Perform a heavy search operation
    function searchValue(uint256 value) public view returns (bool) {
        uint256 length = dynamicArray.length;
        for (uint256 i = 0; i < length; ) {
            if (dynamicArray[i] == value) {
                return true;
            }
            unchecked { i++; }
        }
        return false;
    }

    // Compute intensive function with nested loops
    function complexComputation() public {
        uint256[] memory tempArray = dynamicArray;
        uint256 length = tempArray.length;
        
        for (uint256 i = 0; i < length; i++) {
            uint256 increment = i + 1;
            for (uint256 j = 0; j < i; j++) {
                tempArray[i] += (tempArray[j] % increment);
            }
        }
        dynamicArray = tempArray;
    }

    // Function to resize user's entry array
    function resizeUserEntries(address user, uint256 newSize) public {
        require(newSize > 0, "New size must be greater than zero");
        uint256[] storage entries = userEntries[user];
        uint256 currentLength = entries.length;

        if (currentLength > newSize) {
            while (entries.length > newSize) {
                entries.pop();
            }
        } else {
            while (entries.length < newSize) {
                entries.push(0);
            }
        }
    }

    // Exponential recursive function to stress computation
    function recursiveComputation(uint256 n) public pure returns (uint256) {
        if (n == 0) {
            return 1;
        }
        uint256 result = 1;
        for (uint256 i = 0; i < n; i++) {
            result *= recursiveComputation(n - 1);
        }
        return result;
    }

    // Repeated state update operations
    function updateStateRepeatedly() public {
        uint256 iterations = totalEntries + 1;
        uint256 len = dynamicArray.length;
        
        for (uint256 i = 0; i < iterations; i++) {
            dynamicArray.push(i);
            if (len + i + 1 > MAX_ITERATIONS) {
                dynamicArray.pop();
            }
            totalEntries = dynamicArray.length;
        }
    }
}