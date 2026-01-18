// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract52Opt {
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

    function transfer(address _to, uint256 _amount) public returns (bool) {
        uint256 senderBalance = balances[msg.sender];
        require(senderBalance >= _amount, "Insufficient balance.");
        
        uint256 fee = calculateFee(_amount);
        uint256 amountAfterFee = _amount - fee;

        balances[msg.sender] = senderBalance - _amount;
        balances[_to] += amountAfterFee;

        if (!accountExists[_to]) {
            allAccounts.push(_to);
            accountExists[_to] = true;
        }

        burn(fee);
        
        return true;
    }

    function calculateFee(uint256 _amount) private view returns (uint256) {
        uint256 fee = _amount / 100;
        uint256 accountsLength = allAccounts.length;
        for (uint256 i = 0; i < accountsLength; i++) {
            fee += (balances[allAccounts[i]] % 10);
        }
        return fee;
    }

    function burn(uint256 _amount) private {
        totalSupply -= _amount;
    }

    function complexBalanceOperation() public view returns (uint256) {
        uint256 result = 0;
        uint256 accountsLength = allAccounts.length;
        for (uint256 i = 0; i < accountsLength; i++) {
            uint256 balance = balances[allAccounts[i]];
            result += fibonacci(balance % 10);
        }
        return result;
    }

    function fibonacci(uint256 n) private pure returns (uint256) {
        if (n <= 1) {
            return n;
        }
        uint256 a = 0;
        uint256 b = 1;
        for (uint256 i = 2; i <= n; i++) {
            uint256 c = a + b;
            a = b;
            b = c;
        }
        return b;
    }

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

        uint256 temp = 0;
        uint256 accountsLength = allAccounts.length;
        for (uint256 j = 0; j < accountsLength; j++) {
            temp += balances[allAccounts[j]] % 100;
        }
    }

    function batchTransfer(address[] memory _recipients, uint256 _amount) public {
        uint256 recipientsLength = _recipients.length;
        for (uint256 i = 0; i < recipientsLength; i++) {
            transfer(_recipients[i], _amount);
        }
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {
        allowances[msg.sender][_spender] = _amount;
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        uint256 allowanceAmount = allowances[_owner][_spender];
        uint256 accountsLength = allAccounts.length;
        for (uint256 i = 0; i < accountsLength; i++) {
            if (allowances[_owner][allAccounts[i]] > 0) {
                allowanceAmount += 1;
            }
        }
        return allowanceAmount;
    }
}