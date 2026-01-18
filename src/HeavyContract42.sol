// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract42 {
    struct Voter {
        uint256 weight;
        bool voted;
        address delegate;
        uint256 vote;
    }

    struct Proposal {
        uint256 voteCount;
        uint256 weightSum;
    }

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    constructor(uint256 _numProposals) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        for (uint256 i = 0; i < _numProposals; i++) {
            proposals.push(Proposal({ voteCount: 0, weightSum: 0 }));
        }
    }

    // Add voters, which can only be done by the chairperson
    function addVoter(address voter) public {
        require(msg.sender == chairperson, "Only chairperson can add voters.");
        require(!voters[voter].voted, "The voter already voted.");
        require(voters[voter].weight == 0, "Voter already added.");

        voters[voter].weight = 1;
    }

    // Delegate votes to another voter
    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        require(to != msg.sender, "Self-delegation is not allowed.");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender, "Found loop in delegation.");
        }

        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];

        if (delegate_.voted) {
            proposals[delegate_.vote].voteCount += sender.weight;
            proposals[delegate_.vote].weightSum += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    // Vote for a proposal
    function vote(uint256 proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        require(proposal < proposals.length, "Invalid proposal.");

        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
        proposals[proposal].weightSum += sender.weight;
    }

    // Complex calculation to get winning proposal with nested operations
    function winningProposal() public view returns (uint256 winningProposal_) {
        uint256 maxVoteCount = 0;
        uint256 maxWeightSum = 0;

        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > maxVoteCount) {
                maxVoteCount = proposals[i].voteCount;
                maxWeightSum = proposals[i].weightSum;
                winningProposal_ = i;
            } else if (proposals[i].voteCount == maxVoteCount) {
                if (proposals[i].weightSum > maxWeightSum) {
                    maxWeightSum = proposals[i].weightSum;
                    winningProposal_ = i;
                }
            }
        }
    }

    // Function to manipulate and test gas usage with nested loops
    function complexOperation(uint256 rounds) public {
        uint256 temp;
        for (uint256 i = 0; i < rounds; i++) {
            for (uint256 j = 0; j < proposals.length; j++) {
                for (uint256 k = 0; k < proposals.length; k++) {
                    temp += (proposals[j].voteCount + proposals[k].weightSum) * (i + j + k);
                }
            }
        }
    }

    // Recursive function to manipulate state and test gas usage
    function recursiveWeightManipulation(uint256 index, uint256 depth) public {
        require(index < proposals.length, "Index out of bounds");
        if (depth == 0) return;

        proposals[index].voteCount += depth;
        proposals[index].weightSum += depth;

        recursiveWeightManipulation((index + 1) % proposals.length, depth - 1);
    }
}