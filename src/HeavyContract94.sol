// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract94 {
    struct Voter {
        bool hasVoted;
        uint256 weight;
        address delegate;
        uint256 vote;
    }

    struct Proposal {
        uint256 voteCount;
    }

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    constructor(uint8 numProposals) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for (uint8 i = 0; i < numProposals; i++) {
            proposals.push(Proposal(0));
        }
    }

    function giveRightToVote(address voter) public {
        require(msg.sender == chairperson, "Only chairperson can give right to vote.");
        require(!voters[voter].hasVoted, "The voter already voted.");
        require(voters[voter].weight == 0, "Voter weight must be zero.");

        voters[voter].weight = 1;
    }

    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(to != msg.sender, "Self-delegation is disallowed.");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender, "Found loop in delegation.");
        }

        sender.hasVoted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.hasVoted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    function vote(uint8 proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote.");
        require(!sender.hasVoted, "Already voted.");
        sender.hasVoted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
    }

    function computeWeightedScores() public view returns (uint256) {
        uint256 totalScore = 0;
        for (uint256 i = 0; i < proposals.length; i++) {
            totalScore += proposals[i].voteCount * i;
        }
        return totalScore;
    }

    function resizeProposalArray(uint8 newSize) public {
        require(msg.sender == chairperson, "Only chairperson can resize proposals.");
        if (newSize < proposals.length) {
            for (uint256 i = proposals.length; i > newSize; i--) {
                proposals.pop();
            }
        } else {
            for (uint256 i = proposals.length; i < newSize; i++) {
                proposals.push(Proposal(0));
            }
        }
    }

    function heavyComputation(uint256 iterations) public pure returns (uint256) {
        uint256 result = 0;
        for (uint256 i = 0; i < iterations; i++) {
            result += i**2 + i**3;
        }
        return result;
    }

    function recursiveFactorial(uint256 n) public pure returns (uint256) {
        if (n == 0) {
            return 1;
        } else {
            return n * recursiveFactorial(n - 1);
        }
    }

    function calculateVoteOutcome() public view returns (uint256) {
        uint256 maxVoteCount = 0;
        uint256 winningProposal;
        for (uint256 p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > maxVoteCount) {
                maxVoteCount = proposals[p].voteCount;
                winningProposal = p;
            }
        }
        return winningProposal;
    }
}