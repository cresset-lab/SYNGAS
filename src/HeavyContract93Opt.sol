
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract93Opt {
    
    mapping(uint256 => uint256[]) public dataStorage;
    uint256[] public indexArray;
    uint256 public dataCounter;

    constructor() {
        // Initialize with some data
        for (uint256 i = 0; i < 10; i++) {
            indexArray.push(i);
            uint256[] storage data = dataStorage[i];
            for (uint256 j = 0; j < 10; j++) {
                data.push(i * j);
            }
        }
    }

    // Function to perform nested iterations and update storage
    function heavyUpdate(uint256 iterations) public {
        uint256[] memory indexArrayMem = indexArray;
        for (uint256 i = 0; i < iterations; i++) {
            for (uint256 j = 0; j < indexArrayMem.length; j++) {
                uint256 index = indexArrayMem[j];
                uint256[] storage dataIdx = dataStorage[index];
                dataIdx.push(dataCounter++);
                if (dataIdx.length > 20) {
                    dataIdx.pop();
                }
            }
        }
    }

    // Function to process data and store results
    function processData(uint256 seed) public {
        uint256[] memory indexArrayMem = indexArray;
        for (uint256 i = 0; i < indexArrayMem.length; i++) {
            uint256 index = indexArrayMem[i];
            uint256[] storage data = dataStorage[index];
            for (uint256 j = 0; j < data.length; j++) {
                data[j] = (data[j] + seed) % (index + 1);
            }
        }
    }

    // Recursive function that performs calculations and updates state
    function recursiveCalculation(uint256 n) public returns (uint256) {
        if (n <= 1) {
            return n;
        }

        uint256 result = (recursiveCalculation(n - 1) + recursiveCalculation(n - 2)) % dataCounter;
        dataCounter += result; // Update state variable
        return result;
    }

    // Function to randomly shuffle the indexArray and update storage
    function shuffleIndexArray(uint256 seed) public {
        uint256 len = indexArray.length;
        for (uint256 i = 0; i < len; i++) {
            uint256 n = i + uint256(keccak256(abi.encodePacked(seed, block.timestamp, msg.sender))) % (len - i);
            (indexArray[i], indexArray[n]) = (indexArray[n], indexArray[i]);
        }

        for (uint256 i = 0; i < len; i++) {
            uint256 index = indexArray[i];
            uint256[] storage dataIdx = dataStorage[index];
            dataIdx.push(indexArray[i]);
            if (dataIdx.length > 20) {
                dataIdx.pop();
            }
        }
    }

    // Function to clear data storage (gas-heavy due to iterations)
    function clearStorage() public {
        for (uint256 i = 0; i < indexArray.length; i++) {
            delete dataStorage[indexArray[i]];
        }
        delete indexArray;
        dataCounter = 0;
    }
}
