// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract83Opt {
    // State variables
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    uint256 private totalSupply;
    address private owner;
    uint256[] private dynamicArray;
    
    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    // Constructor
    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply;
        balances[msg.sender] = _initialSupply;
    }

    // Public function to get balance
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    // Heavy computation function with dynamic array resizing
    function resizeAndPopulateArray(uint256 elements) public {
        // Resize array with a heavy computation logic
        delete dynamicArray;
        for (uint256 i = 0; i < elements; i++) {
            dynamicArray.push(i**3);
        }
    }

    // Function with nested loops and mappings
    function complexTransfer(address[] calldata _recipients, uint256[] calldata _amounts) public {
        require(_recipients.length == _amounts.length, "Array length mismatch");
        
        uint256 _recipients_len = _recipients.length;
        for (uint256 i = 0; i < _recipients_len; i++) {
            address recipient = _recipients[i];
            uint256 amount = _amounts[i];
            for (uint256 j = 0; j < _recipients_len; j++) {
                if (i != j) {
                    _unsafeTransfer(msg.sender, recipient, amount);
                }
            }
        }
    }

    // Recursive function for complex calculations
    function factorial(uint256 n) public pure returns (uint256) {
        if (n == 0) {
            return 1;
        } else {
            return n * factorial(n - 1);
        }
    }

    // Heavy token transfer logic
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "Invalid address");
        uint256 senderBalance = balances[msg.sender];
        require(senderBalance >= _value, "Insufficient balance");
        
        uint256 fee = _value / 100;
        balances[msg.sender] = senderBalance - _value - fee;
        balances[_to] += _value;
        
        payable(owner).transfer(fee); // Intentionally direct transfer to contract owner
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Approve allowance with loop
    function approveWithLoop(address _spender, uint256 _value) public returns (bool) {
        allowances[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Internal function for unsafe transfers
    function _unsafeTransfer(address _from, address _to, uint256 _value) internal {
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    // Fallback function for receiving ether
    receive() external payable {}
}