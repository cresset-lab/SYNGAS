// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract81 {
    struct Voter {
        bool voted;
        uint weight;
        uint vote;
    }

    struct Proposal {
        uint voteCount;
        string name;
    }
    
    Proposal[] public proposals;
    mapping(address => Voter) public voters;
    address public chairperson;
    uint public totalWeight;

    constructor(string[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                voteCount: 0,
                name: proposalNames[i]
            }));
        }
    }
    
    function giveRightToVote(address voter) public {
        require(msg.sender == chairperson, "Only chairperson can give right to vote.");
        require(!voters[voter].voted, "The voter already voted.");
        require(voters[voter].weight == 0, "The voter already has right to vote.");
        
        voters[voter].weight = 1;
        totalWeight += 1;
    }
    
    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote.");
        require(!sender.voted, "Already voted.");
        
        sender.voted = true;
        sender.vote = proposal;
        
        proposals[proposal].voteCount += sender.weight;
    }
    
    function computeHeavyWeight(uint factor) public view returns (uint) {
        uint heavyWeight = 0;
        for (uint i = 0; i < proposals.length; i++) {
            for (uint j = 0; j < factor; j++) {
                heavyWeight += proposals[i].voteCount * (j + 1);
            }
        }
        return heavyWeight;
    }
    
    function weightedVoteCount() public view returns (uint[] memory) {
        uint[] memory weightedCounts = new uint[](proposals.length);
        for (uint i = 0; i < proposals.length; i++) {
            weightedCounts[i] = proposals[i].voteCount * voters[msg.sender].weight;
        }
        return weightedCounts;
    }
    
    function computeMultiDimOperations(uint inputFactor) public {
        uint[][] memory multiDimArray = new uint[][](proposals.length);
        for (uint i = 0; i < proposals.length; i++) {
            multiDimArray[i] = new uint[](inputFactor);
            for (uint j = 0; j < inputFactor; j++) {
                multiDimArray[i][j] = proposals[i].voteCount * (j + 1);
                voters[msg.sender].weight += multiDimArray[i][j] % (j + 1);
            }
        }
    }
    
    function recursiveVoteCount(uint index, uint depth) public view returns (uint) {
        if (depth == 0 || index >= proposals.length) {
            return 0;
        }
        return proposals[index].voteCount + recursiveVoteCount(index + 1, depth - 1);
    }
}