// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Target {
    // State variables
    uint256 public total;
    uint256[] public data;

    // Helper to populate data for testing
    function addData(uint256[] memory _values) public {
        for (uint256 i = 0; i < _values.length; i++) {
            data.push(_values[i]);
        }
    }

    // --- The Function to Optimize ---
    // This function is functionally correct but gas-inefficient.
    function doSomethingExpensive(uint256 limit) public returns (uint256) {
        
        // Inefficiency 1: Resetting state variable directly 
        total = 0;

        // Inefficiency 2: Reading state variable (data.length) in every loop iteration
        // Inefficiency 3: Post-increment (i++) instead of pre-increment (++i)
        for (uint256 i = 0; i < data.length; i++) {
            
            if (i < limit) {
                // Inefficiency 4: Writing to STORAGE 'total' in every iteration (SSTORE is expensive)
                // Inefficiency 5: Default checked arithmetic (SafeMath is built-in 0.8+, but costs gas)
                total += data[i];
            }
        }

        return total;
    }
}