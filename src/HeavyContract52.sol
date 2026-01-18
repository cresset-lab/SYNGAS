// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract52 {
    string public name = "HeavyToken";
    string public symbol = "HTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    
    address[] private allAccounts;
    mapping(address => bool) private accountExists;

    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply;
        balances[msg.sender] = _initialSupply;
        allAccounts.push(msg.sender);
        accountExists[msg.sender] = true;
    }

    // A complex transfer function that burns gas by resizing arrays and doing complex calculations
    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(balances[msg.sender] >= _amount, "Insufficient balance.");
        
        uint256 fee = calculateFee(_amount);
        uint256 amountAfterFee = _amount - fee;

        balances[msg.sender] -= _amount;
        balances[_to] += amountAfterFee;

        if (!accountExists[_to]) {
            allAccounts.push(_to);
            accountExists[_to] = true;
        }

        // Burn operations
        burn(fee);
        
        return true;
    }

    function calculateFee(uint256 _amount) private view returns (uint256) {
        uint256 fee = _amount / 100; // 1% fee
        for (uint256 i = 0; i < allAccounts.length; i++) {
            fee += (balances[allAccounts[i]] % 10);
        }
        return fee;
    }

    // Function to burn tokens from the system
    function burn(uint256 _amount) private {
        totalSupply -= _amount;
    }

    // A function that performs heavy computation on balances
    function complexBalanceOperation() public view returns (uint256) {
        uint256 result = 0;
        for (uint256 i = 0; i < allAccounts.length; i++) {
            uint256 balance = balances[allAccounts[i]];
            result += fibonacci(balance % 10);
        }
        return result;
    }

    // A recursive fibonacci function that is intentionally inefficient
    function fibonacci(uint256 n) private pure returns (uint256) {
        if (n <= 1) {
            return n;
        }
        return fibonacci(n - 1) + fibonacci(n - 2);
    }

    // Function to resize the array and perform action
    function resizeAndCompute(uint256 newSize) public {
        uint256 originalLength = allAccounts.length;

        if (newSize > originalLength) {
            for (uint256 i = originalLength; i < newSize; i++) {
                address newAccount = address(uint160(i));
                allAccounts.push(newAccount);
                accountExists[newAccount] = true;
            }
        } else if (newSize < originalLength) {
            for (uint256 i = originalLength; i > newSize; i--) {
                address lastAccount = allAccounts[allAccounts.length - 1];
                delete accountExists[lastAccount];
                allAccounts.pop();
            }
        }

        // Perform heavy computation
        uint256 temp = 0;
        for (uint256 j = 0; j < allAccounts.length; j++) {
            temp += balances[allAccounts[j]] % 100;
        }
    }

    // A function to simulate multiple transfers and cause heavy gas consumption
    function batchTransfer(address[] memory _recipients, uint256 _amount) public {
        for (uint256 i = 0; i < _recipients.length; i++) {
            transfer(_recipients[i], _amount);
        }
    }

    // Function to allow account holders to approve allowance
    function approve(address _spender, uint256 _amount) public returns (bool) {
        allowances[msg.sender][_spender] = _amount;
        return true;
    }

    // Function to perform heavy allowance check
    function allowance(address _owner, address _spender) public view returns (uint256) {
        uint256 allowanceAmount = allowances[_owner][_spender];
        for (uint256 i = 0; i < allAccounts.length; i++) {
            if (allowances[_owner][allAccounts[i]] > 0) {
                allowanceAmount += 1;
            }
        }
        return allowanceAmount;
    }
}