// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract77 {
    struct Voter {
        bool voted;
        uint weight;
        address delegate;
        uint vote;
    }

    struct Proposal {
        uint voteCount;
    }

    address public chairperson;

    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    constructor(uint numProposals) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        for (uint i = 0; i < numProposals; i++) {
            proposals.push(Proposal(0));
        }
    }

    function giveRightToVote(address voter) public {
        require(msg.sender == chairperson, "Only chairperson can give right to vote.");
        require(!voters[voter].voted, "The voter already voted.");
        require(voters[voter].weight == 0, "The voter already has the right to vote.");

        voters[voter].weight = 1;
    }

    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender, "Found loop in delegation.");
        }

        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        // Perform complex calculations to simulate heavy load
        for (uint i = 0; i < 100; i++) {
            for (uint j = 0; j < 100; j++) {
                proposals[proposal].voteCount += sender.weight + i + j;
                proposals[proposal].voteCount -= (i % 5) + (j % 5);
            }
        }
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

    function calculateHeavy(uint _input) public pure returns (uint result) {
        result = _input;
        for (uint i = 0; i < 50; i++) {
            for (uint j = 0; j < 50; j++) {
                result += (i * j) + (_input % (i + 1)) - (j % (_input + 1));
            }
        }
    }

    function recursiveLoop(uint n) public pure returns (uint) {
        if (n == 0) {
            return 0;
        } else {
            uint sum = 0;
            for (uint i = 0; i < 10; i++) {
                sum += recursiveLoop(n - 1) + i;
            }
            return sum;
        }
    }
}