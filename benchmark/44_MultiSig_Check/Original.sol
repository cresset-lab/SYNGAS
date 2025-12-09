// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Original {
    mapping(address => bool) public signers;
    mapping(bytes32 => mapping(address => bool)) public approvals;
    uint256 public requiredSignatures = 2;
    
    constructor() {
        signers[msg.sender] = true;
    }
    
    function approve(bytes32 txHash) public {
        require(signers[msg.sender], "Not a signer");
        approvals[txHash][msg.sender] = true;
    }
    
    function execute(bytes32 txHash) public {
        uint256 count = 0;
        address[] memory signerList = new address[](3);
        signerList[0] = address(0x1);
        signerList[1] = address(0x2);
        signerList[2] = address(0x3);
        
        for (uint256 i = 0; i < signerList.length; i++) {
            if (signers[signerList[i]] && approvals[txHash][signerList[i]]) {
                count++;
            }
        }
        require(count >= requiredSignatures, "Insufficient signatures");
    }
}

