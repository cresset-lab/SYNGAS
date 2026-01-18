// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract99 {
    // State variables
    mapping(address => uint256) private balances;
    mapping(address => uint256) private lastUpdated;
    address[] private holders;
    uint256 private constant MAX_ITER = 100;

    // Token information
    string public name = "Heavy Token";
    string public symbol = "HTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    constructor(uint256 initialSupply) {
        balances[msg.sender] = initialSupply;
        totalSupply = initialSupply;
        holders.push(msg.sender);
    }
    
    // Complex transfer logic
    function transfer(address to, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        
        // Update holders array
        if (balances[to] == amount) {
            holders.push(to);
        }
        
        recursiveUpdate(to);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
    // Recursive update function to simulate heavy computation
    function recursiveUpdate(address account) internal {
        if (balances[account] % 2 == 0) {
            lastUpdated[account] = block.timestamp;
            if (balances[account] > 0) {
                balances[account]--;
                recursiveUpdate(account);
            }
        }
    }
    
    // Heavy computation to calculate sum of balances with nested loops
    function calculateTotalBalance() public view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < holders.length; i++) {
            for (uint256 j = 0; j < balances[holders[i]]; j++) {
                sum += 1;
            }
        }
        return sum;
    }
    
    // Random heavy calculation
    function randomHeavyCalculation(uint256 seed) public pure returns (uint256) {
        uint256 result = seed;
        for (uint256 i = 0; i < MAX_ITER; i++) {
            result = (result * 1103515245 + 12345) % (1 << 31);
        }
        return result;
    }
    
    // Function to fuzz test with heavy storage operations
    function fuzzTest(uint256 iterations) public {
        for (uint256 i = 0; i < iterations; i++) {
            balances[msg.sender] += i;
            lastUpdated[msg.sender] = block.timestamp + i;
        }
    }
    
    // Function to simulate nested loop storage updates
    function complexStorageUpdate(uint256 loops) public {
        for (uint256 i = 0; i < loops; i++) {
            for (uint256 j = 0; j < holders.length; j++) {
                uint256 holderBalance = balances[holders[j]];
                balances[holders[j]] = holderBalance / 2;
            }
        }
    }
}