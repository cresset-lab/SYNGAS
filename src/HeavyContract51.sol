// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract51 {
    struct Voter {
        bool voted;
        uint weight;
        uint vote;
    }

    struct Proposal {
        string name;
        uint voteCount;
    }

    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    address public chairperson;
    uint public totalVotes;
    uint public totalWeight;
    uint public constant MAX_ITERATIONS = 500;

    constructor(string[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    function giveRightToVote(address voter) public {
        require(msg.sender == chairperson, "Only chairperson can give right to vote.");
        require(!voters[voter].voted, "The voter already voted.");
        require(voters[voter].weight == 0, "Voter weight already set.");
        
        voters[voter].weight = 1;
    }

    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight > 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        require(proposal < proposals.length, "Invalid proposal.");
        
        sender.voted = true;
        sender.vote = proposal;
        
        proposals[proposal].voteCount += sender.weight;
        totalVotes += sender.weight;
        totalWeight += hashComputation(sender.weight);
    }

    function hashComputation(uint input) internal pure returns (uint) {
        uint hash = input;
        for (uint i = 0; i < MAX_ITERATIONS; i++) {
            hash = uint(keccak256(abi.encodePacked(hash, i)));
        }
        return hash;
    }

    function winningProposal() public view returns (uint winningProposal_) {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function getWinnerName() public view returns (string memory winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }

    function computeHeavyWeight(uint loopCount) public {
        require(loopCount > 0 && loopCount <= MAX_ITERATIONS, "Loop count out of range.");
        for (uint i = 0; i < loopCount; i++) {
            for (uint j = 0; j < proposals.length; j++) {
                proposals[j].voteCount += hashComputation(j);
                totalWeight += hashComputation(i + j);
            }
        }
    }

    function resetVotes() public {
        require(msg.sender == chairperson, "Only chairperson can reset votes.");
        for (uint i = 0; i < proposals.length; i++) {
            proposals[i].voteCount = 0;
        }
        totalVotes = 0;
        totalWeight = 0;

        for (uint k = 0; k < MAX_ITERATIONS; k++) {
            totalWeight += hashComputation(k);
        }
    }
}