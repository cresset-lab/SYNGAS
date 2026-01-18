// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract95Opt {
    mapping(address => uint256) public registry;
    mapping(uint256 => uint256[]) public numberMapping;
    address[] public addressList;
    uint256 public globalCounter;
    uint256 public constant MAX_ITERATIONS = 100;

    constructor() {
        globalCounter = 0;
    }
    
    // Register an address with a random value
    function registerAddress(address _addr) public {
        registry[_addr] = block.number;
        addressList.push(_addr);
        unchecked { globalCounter++; }
    }
    
    // Perform heavy computation while updating the registry
    function computeAndRegister(uint256 _seed) public {
        unchecked {
            uint256 localGlobalCounter = globalCounter;
            for (uint256 i = 0; i < MAX_ITERATIONS; i++) {
                uint256 computation = _complexCalculation(_seed, i);
                registry[msg.sender] = computation;
                numberMapping[computation % 5].push(computation);
                localGlobalCounter += computation;
            }
            globalCounter = localGlobalCounter;
        }
    }

    // Search for an address in the list, perform a complex calculation
    function searchAndCompute(address _addr) public view returns (uint256) {
        address[] memory localAddressList = addressList; // Load address list into memory to save gas
        for (uint256 i = 0; i < localAddressList.length; i++) {
            if (localAddressList[i] == _addr) {
                return _complexCalculation(uint256(uint160(_addr)), i);
            }
        }
        return 0;
    }

    // Update the global counter with heavy recursive operation
    function updateCounterRecursively(uint256 _depth, uint256 _value) public {
        if (_depth == 0) return;
        unchecked { globalCounter += _value; }
        updateCounterRecursively(_depth - 1, _value / 2);
    }

    // Complex calculation involving multiple operations
    function _complexCalculation(uint256 _base, uint256 _modifier) internal pure returns (uint256) {
        uint256 result = _base;
        unchecked {
            for (uint256 i = 1; i <= _modifier; i++) {
                result = result ^ ((result + i) * 3);
            }
        }
        return result;
    }

    // Get the number mapping results for a specific key
    function getNumberMapping(uint256 _key) public view returns (uint256[] memory) {
        return numberMapping[_key];
    }
}