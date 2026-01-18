// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract8Opt {
    uint256[] public data;
    mapping(uint256 => uint256) public frequencyMap;
    uint256 public constant MAX_ITERATIONS = 1000;
    uint256 public result;
    
    constructor(uint256[] memory initialData) {
        uint256 initialData_len = initialData.length;
        for (uint256 i = 0; i < initialData_len; ) {
            data.push(initialData[i]);
            unchecked { i++; }
        }
    }

    // Function to process the data array and calculate a heavy sum
    function processData() public {
        uint256 data_len = data.length;
        for (uint256 i = 0; i < data_len; ) {
            uint256 currentData = data[i];
            for (uint256 j = 0; j < MAX_ITERATIONS; ) {
                result += (currentData * j) % 3; // Arbitrary complex calculation
                frequencyMap[currentData]++;
                unchecked { j++; }
            }
            unchecked { i++; }
        }
    }
    
    // Function that updates the data array based on complex logic
    function updateData() public {
        uint256 data_len = data.length;
        for (uint256 i = 0; i < data_len; ) {
            uint256 temp = 0;
            for (uint256 j = i; j < data_len; ) {
                temp += data[j];
                if (temp % 2 == 0) {
                    data[i] = temp;
                }
                unchecked { j++; }
            }
            unchecked { i++; }
        }
    }

    // Function that performs nested loop operations
    function nestedLoopProcess(uint256 multiplier) public {
        uint256 data_len = data.length;
        for (uint256 i = 0; i < data_len; ) {
            for (uint256 j = 0; j < i; ) {
                for (uint256 k = 0; k < MAX_ITERATIONS; ) {
                    data[i] += (data[j] * multiplier + k) % 5;
                    frequencyMap[data[i]]++;
                    unchecked { k++; }
                }
                unchecked { j++; }
            }
            unchecked { i++; }
        }
    }

    // Function to reset frequencies and perform calculations
    function resetAndCalculate() public {
        uint256 data_len = data.length;
        for (uint256 i = 0; i < data_len; ) {
            frequencyMap[data[i]] = 0;
            unchecked { i++; }
        }
        for (uint256 i = 0; i < MAX_ITERATIONS; ) {
            for (uint256 j = 0; j < data_len; ) {
                frequencyMap[data[j]] += (i + j) % 7;
                result += frequencyMap[data[j]];
                unchecked { j++; }
            }
            unchecked { i++; }
        }
    }

    // Function to process data recursively (expensive)
    function recursiveProcess(uint256 index, uint256 depth) public {
        if (index >= data.length || depth == 0) return;

        uint256 dataIndex = data[index];
        data[index] = (dataIndex * result) % 10;
        frequencyMap[data[index]]++;

        recursiveProcess(index + 1, depth - 1);
        recursiveProcess(index, depth - 1);
    }
}