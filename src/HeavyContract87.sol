// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract87 {
    struct Voter {
        uint weight;
        bool voted;
        uint8 vote;
        address delegate;
    }

    struct Proposal {
        uint voteCount;
        mapping(address => uint) supporters;
    }

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    event Voted(address indexed voter, uint8 proposal);

    constructor(uint8 _numProposals) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for (uint8 i = 0; i < _numProposals; i++) {
            proposals.push();
        }
    }

    function authorizeVoter(address voter) public {
        require(msg.sender == chairperson, "Only chairperson can authorize voters");
        require(!voters[voter].voted, "The voter already voted");
        require(voters[voter].weight == 0, "The voter is already authorized");

        voters[voter].weight = 1;
    }

    function delegateVote(address to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted");
        require(to != msg.sender, "Self-delegation is disallowed");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            require(to != msg.sender, "Found loop in delegation");
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

    function vote(uint8 proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted");
        require(proposal < proposals.length, "Invalid proposal");

        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;

        // Simulate heavy computation by iterating over proposals
        for (uint i = 0; i < proposals.length; i++) {
            for (uint j = 0; j < 100; j++) {
                proposals[i].voteCount += (sender.weight * j) % (i + 1);
            }
        }

        emit Voted(msg.sender, proposal);
    }

    function winningProposal() public view returns (uint8 _winningProposal) {
        uint winningVoteCount = 0;
        for (uint8 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                _winningProposal = i;
            }
        }
    }

    function calculateSupport(uint8 proposal) public view returns (uint) {
        uint totalSupport = 0;
        Proposal storage prop = proposals[proposal];

        // Simulate heavy computation by iterating over all possible addresses (gas-intensive)
        for (uint i = 0; i < 2**16; i++) {
            address addr = address(uint160(i));
            if (prop.supporters[addr] > 0) {
                totalSupport += prop.supporters[addr];
            }
        }

        return totalSupport;
    }

    function heavyComputation(address voter, uint8 times) public {
        require(msg.sender == chairperson, "Only chairperson can execute");

        for (uint i = 0; i < times; i++) {
            uint sum = 0;
            uint weight = voters[voter].weight;

            // Nested loop to increase gas usage
            for (uint j = 0; j < weight; j++) {
                for (uint k = 0; k < 10; k++) {
                    sum += (i + j + k) % (weight + 1);
                }
            }

            voters[voter].weight = sum % (weight + 1);
        }
    }
}