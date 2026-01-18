
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract71Opt {
    // Token state variables
    string public name = "HeavyToken71";
    string public symbol = "HT71";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Storage variables for complex logic
    mapping(uint256 => address) public indexToAddress;
    address[] public holders;
    
    constructor(uint256 initialSupply) {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        holders.push(msg.sender);
        indexToAddress[0] = msg.sender;
    }

    // A computationally intensive transfer function
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        if (balanceOf[_to] == 0 && _value > 0) {
            holders.push(_to);
            indexToAddress[holders.length - 1] = _to;
        }
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        totalSupply += recursiveCalculation(_value); // Intentionally complex calculation
        return true;
    }

    // Approval function with a loop for additional logic
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        uint256 length = holders.length;
        for (uint256 i = 0; i < length; i++) {
            complexArrayOperation(i);
        }
        return true;
    }

    // TransferFrom with nested loops
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        uint256 length = holders.length;
        for (uint256 i = 0; i < length; i++) {
            address currentHolder = holders[i];
            for (uint256 j = i + 1; j < length; j++) {
                address nextHolder = holders[j];
                if (balanceOf[currentHolder] < balanceOf[nextHolder]) {
                    holders[i] = nextHolder;
                    holders[j] = currentHolder;
                    currentHolder = nextHolder;
                }
            }
        }
        return true;
    }
    
    // Function with dynamic array resizing
    function dynamicArrayResizing(uint256 iterations) public {
        uint256[] memory tempArray = new uint256[](iterations);
        for (uint256 i = 0; i < iterations; i++) {
            tempArray[i] = i;
            if (i % 2 == 0) {
                uint256[] memory newArray = new uint256[](tempArray.length + 1);
                for (uint256 j = 0; j < tempArray.length; j++) {
                    newArray[j] = tempArray[j];
                }
                tempArray = newArray;
            }
        }
    }
    
    // Complex nested loop calculation
    function complexArrayOperation(uint256 index) internal {
        uint256 sum = 0;
        uint256 length = holders.length;
        for (uint256 i = 0; i < length; i++) {
            uint256 holderBalance = balanceOf[holders[i]];
            sum += holderBalance;
            for (uint256 j = 0; j < index; j++) {
                sum += j * i;
            }
        }
        balanceOf[msg.sender] += sum;
    }
    
    // Recursive function
    function recursiveCalculation(uint256 n) internal pure returns (uint256) {
        if (n == 0) return 0;
        return n * (n + 1) / 2; // Optimized to use arithmetic series formula
    }
}
