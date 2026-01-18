// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract39 {
    
    struct Voter {
        bool voted;
        uint weight;
        uint vote;
    }
    
    struct Proposal {
        uint voteCount;
        uint weightSum;
    }
    
    mapping(address => Voter) public voters;
    Proposal[] public proposals;
    uint public recursionCounter;
    
    constructor(uint proposalCount) {
        for (uint i = 0; i < proposalCount; i++) {
            proposals.push(Proposal(0, 0));
        }
    }

    function registerVoter(address voter, uint weight) public {
        require(!voters[voter].voted, "Voter already registered.");
        voters[voter].weight = weight;
        voters[voter].voted = false;
    }

    function vote(uint proposalIndex) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        require(proposalIndex < proposals.length, "Invalid proposal index.");
        
        sender.voted = true;
        sender.vote = proposalIndex;
        proposals[proposalIndex].voteCount += 1;
        proposals[proposalIndex].weightSum += sender.weight;
    }

    function recursiveWeightCalculation(uint n) public returns (uint) {
        // Reset counter
        recursionCounter = 0;
        return _computeWeightSum(n);
    }
    
    function _computeWeightSum(uint n) internal returns (uint) {
        if (n == 0) {
            return 0;
        }
        recursionCounter++;
        
        uint weightSum = 0;
        for (uint i = 0; i < proposals.length; i++) {
            weightSum += proposals[i].weightSum;
        }
        
        return weightSum + _computeWeightSum(n - 1);
    }
    
    function complexVotingProcess(uint[] calldata weights, uint[] calldata proposalIndices) public {
        require(weights.length == proposalIndices.length, "Mismatched inputs.");
        
        for (uint i = 0; i < weights.length; i++) {
            // Storage reads and writes
            uint weight = weights[i];
            uint proposalIndex = proposalIndices[i];
            require(proposalIndex < proposals.length, "Invalid proposal index.");

            proposals[proposalIndex].voteCount += 1;
            proposals[proposalIndex].weightSum += weight;

            // Nested loop for intensive computation
            for (uint j = 0; j < proposals.length; j++) {
                proposals[j].weightSum += weight / (j + 1);
            }
        }
    }

    function executeHeavyComputation(uint iterations) public {
        for (uint i = 0; i < iterations; i++) {
            for (uint j = 0; j < proposals.length; j++) {
                proposals[j].voteCount += i * j;
                proposals[j].weightSum += i + j;
            }
        }
    }
    
    function resetContractState() public {
        for (uint i = 0; i < proposals.length; i++) {
            proposals[i].voteCount = 0;
            proposals[i].weightSum = 0;
        }
    }
}