// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract2 {
    string public name = "HeavyToken";
    string public symbol = "HTK";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * 10**uint256(decimals);
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    // Additional storage variables for heavy computations
    uint256[] private dataPoints;
    mapping(uint256 => uint256) private indexMap;
    uint256 private counter;
    uint256[] private complexArray;
    
    constructor() {
        balanceOf[msg.sender] = totalSupply;
        counter = 0;
    }

    // Basic transfer function with additional computations
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        // Simulate complex balance update
        for (uint256 i = 0; i < dataPoints.length; i++) {
            balanceOf[msg.sender] -= dataPoints[i] % (_value + 1);
        }

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        // Execute complex computation
        complexCalculation(_value);

        return true;
    }
    
    // Complex calculation function with nested loop
    function complexCalculation(uint256 seed) private {
        for (uint256 i = 0; i < 10; i++) {
            for (uint256 j = 0; j < 10; j++) {
                counter += (seed + i) * j;
            }
        }
    }

    // Function to add data to the complex array and map
    function addData(uint256 value) public {
        dataPoints.push(value);
        indexMap[value] = dataPoints.length - 1;
    }

    // Heavy computation to simulate data processing
    function processData() public {
        for (uint256 i = 0; i < dataPoints.length; i++) {
            for (uint256 j = i; j < dataPoints.length; j++) {
                complexArray.push(dataPoints[i] + dataPoints[j]);
            }
        }
        
        // Clear the array after processing
        delete complexArray;
    }

    // Function to trigger a recursive-like pattern for calculations
    function recursivePattern(uint256 n) public returns (uint256) {
        require(n < 10, "Too large for recursion demo"); // Prevent excessive recursion
        return n == 0 ? 1 : n * recursivePattern(n - 1);
    }

    // Function to iterate over balances (inefficiently)
    function iterateBalances() public view returns (uint256 total) {
        address addr;
        for (uint256 i = 0; i < 256; i++) {
            addr = address(uint160(i));
            total += balanceOf[addr];
        }
    }

    // Complex transfer with allowance check and nested processing
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        // Perform nested loops for additional computation
        for (uint256 i = 0; i < 5; i++) {
            for (uint256 j = 0; j < 5; j++) {
                counter += i * j;
            }
        }

        return true;
    }
}