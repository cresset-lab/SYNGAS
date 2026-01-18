// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract3 {
    
    struct Voter {
        bool isRegistered;
        uint weight;
        bool hasVoted;
        uint vote; // index of the voted proposal
    }

    struct Proposal {
        bytes32 name; // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    mapping(address => Voter) public voters;
    Proposal[] public proposals;
    address public chairperson;

    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    // Register a voter with a complex weight calculation
    function registerVoter(address voter, uint weightFactor) public {
        require(msg.sender == chairperson, "Only chairperson can register");
        require(!voters[voter].isRegistered, "Voter already registered");
        
        uint complexWeight = 1;
        for (uint i = 0; i < weightFactor; i++) {
            complexWeight *= 2;
        }
        
        voters[voter] = Voter({
            isRegistered: true,
            weight: complexWeight,
            hasVoted: false,
            vote: 0
        });
    }

    // Delegate vote with dynamic array operations
    function delegateVote(address to) public {
        Voter storage sender = voters[msg.sender];
        require(sender.isRegistered, "Sender is not registered");
        require(!sender.hasVoted, "Already voted");
        require(to != msg.sender, "Self-delegation not allowed");

        while (voters[to].isRegistered && voters[to].hasVoted) {
            to = address(uint160(voters[to].vote));
        }

        require(voters[to].isRegistered, "Delegatee is not registered");

        sender.hasVoted = true;
        sender.vote = uint(uint160(to));

        Voter storage delegate_ = voters[to];
        if (delegate_.hasVoted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    // Compute votes for each proposal with nested loops
    function computeVotes() public {
        for (uint i = 0; i < proposals.length; i++) {
            proposals[i].voteCount = 0; // Reset vote count for recomputation
            for (uint j = 0; j < proposals.length; j++) {
                if (i != j) {
                    proposals[i].voteCount += proposals[j].voteCount / (i + 1);
                }
            }
        }
    }
    
    // Vote for a proposal with heavy computation and state updates
    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.isRegistered, "Has no right to vote");
        require(!sender.hasVoted, "Already voted");
        require(proposal < proposals.length, "Invalid proposal index");

        sender.hasVoted = true;
        sender.vote = proposal;
        
        proposals[proposal].voteCount += sender.weight;

        // Inefficiently update vote counts
        for (uint i = 0; i < proposals.length; i++) {
            if (i != proposal) {
                proposals[i].voteCount -= sender.weight / (i + 1);
            }
        }
    }

    // Get the winning proposal with loop and calculation
    function winningProposal() public view returns (uint winningProposal_) {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }
}