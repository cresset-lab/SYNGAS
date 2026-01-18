// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract26 {
    struct Voter {
        uint256 weight; // weight of the vote
        bool voted; // if true, that person already voted
        uint256 vote; // index of the voted proposal
    }

    struct Proposal {
        bytes32 name; // short name of the proposal
        uint256 voteCount; // number of accumulated votes
    }

    mapping(address => Voter) public voters;
    Proposal[] public proposals;
    uint256 public totalWeight;
    uint256 public constant MAX_PROPOSALS = 100;
    
    constructor(bytes32[] memory proposalNames) {
        for (uint256 i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    function giveRightToVote(address voter) public {
        require(!voters[voter].voted, "The voter already voted.");
        require(voters[voter].weight == 0, "Weight already assigned.");
        
        voters[voter].weight = 1;
        totalWeight += 1;
    }

    function vote(uint256 proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote.");
        require(!sender.voted, "Already voted.");
        require(proposal < proposals.length, "Invalid proposal index.");

        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
    }

    function weightAdjuster(address voter, uint256 additionalWeight) public {
        voters[voter].weight += additionalWeight;
        totalWeight += additionalWeight;
    }
    
    function computeWeightedVotes() public view returns (uint256[] memory) {
        uint256[] memory weightedVotes = new uint256[](proposals.length);
        
        for (uint256 i = 0; i < proposals.length; i++) {
            weightedVotes[i] = proposals[i].voteCount * proposals[i].voteCount;
        }
        
        return weightedVotes;
    }
    
    function iterativeWeightRecalculation() public {
        for (uint256 i = 0; i < proposals.length; i++) {
            proposals[i].voteCount = 0;
        }
        
        for (uint256 i = 0; i < MAX_PROPOSALS; i++) {
            for (uint256 j = 0; j < proposals.length; j++) {
                proposals[j].voteCount += (i + 1);
            }
        }
    }
    
    function inefficientVoteTally() public view returns (uint256) {
        uint256 total = 0;
        
        // Iterate over proposals and sum their vote counts
        // Note: Cannot iterate over mapping, so we use the proposals array
        for (uint256 i = 0; i < proposals.length; i++) {
            total += proposals[i].voteCount;
        }
        
        return total;
    }

    function heavyComputationFunction(uint256 loops) public {
        for (uint256 i = 0; i < loops; i++) {
            for (uint256 j = 0; j < proposals.length; j++) {
                proposals[j].voteCount += i;
            }
        }
    }
}