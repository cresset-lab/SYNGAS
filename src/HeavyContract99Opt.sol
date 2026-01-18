// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract99Opt {
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
        uint256 balance = balances[account];
        if (balance % 2 == 0) {
            lastUpdated[account] = block.timestamp;
            if (balance > 0) {
                balances[account]--;
                recursiveUpdate(account);
            }
        }
    }
    
    // Heavy computation to calculate sum of balances with nested loops
    function calculateTotalBalance() public view returns (uint256 sum) {
        uint256 holdersLen = holders.length;
        for (uint256 i = 0; i < holdersLen; i++) {
            sum += balances[holders[i]];
        }
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
        uint256 senderBalance = balances[msg.sender];
        uint256 senderLastUpdated = lastUpdated[msg.sender];
        for (uint256 i = 0; i < iterations; i++) {
            senderBalance += i;
            senderLastUpdated = block.timestamp + i;
        }
        balances[msg.sender] = senderBalance;
        lastUpdated[msg.sender] = senderLastUpdated;
    }
    
    // Function to simulate nested loop storage updates
    function complexStorageUpdate(uint256 loops) public {
        uint256 holdersLen = holders.length;
        for (uint256 i = 0; i < loops; i++) {
            for (uint256 j = 0; j < holdersLen; j++) {
                address holder = holders[j];
                balances[holder] /= 2;
            }
        }
    }
}