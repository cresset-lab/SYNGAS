// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract16 {
    struct Voter {
        uint256 weight;
        bool voted;
        address delegate;
        uint256 vote;
    }

    struct Proposal {
        uint256 voteCount;
    }

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    // This mapping is intentionally large to simulate gas-heavy operations
    mapping(uint256 => uint256) public complexMap;

    uint256 public constant MAX_PROPOSALS = 10;
    uint256 public constant MAX_COMPLEXITY = 100;

    constructor(uint256 proposalCount) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for (uint256 i = 0; i < proposalCount && i < MAX_PROPOSALS; i++) {
            proposals.push(Proposal({ voteCount: 0 }));
        }
    }

    function giveRightToVote(address voter) public {
        require(msg.sender == chairperson, "Only chairperson can give right to vote.");
        require(!voters[voter].voted, "The voter already voted.");
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

        Voter storage delegate_ = voters[to];
        require(delegate_.weight >= 1, "Delegate has no right to vote.");

        sender.voted = true;
        sender.delegate = to;

        if (delegate_.voted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    function vote(uint256 proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight > 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        require(proposal < proposals.length, "Invalid proposal.");

        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
    }

    function computeHeavyOperation(uint256 complexity) public {
        require(complexity <= MAX_COMPLEXITY, "Complexity too high.");
        uint256 proposalsLength = proposals.length;
        for (uint256 i = 0; i < complexity; i++) {
            for (uint256 j = 0; j < proposalsLength; j++) {
                complexMap[i * proposalsLength + j] = (complexMap[i * proposalsLength + j] + i * j) % 123456;
            }
        }
    }

    function weightedSum(uint256 multiplier) public view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < proposals.length; i++) {
            for (uint256 j = 0; j < voters[msg.sender].weight; j++) {
                sum += proposals[i].voteCount * multiplier;
            }
        }
        return sum;
    }

    function processVotes() public {
        require(msg.sender == chairperson, "Only chairperson can process.");
        uint256 totalVotes = 0;
        for (uint256 i = 0; i < proposals.length; i++) {
            for (uint256 j = 0; j < MAX_COMPLEXITY; j++) {
                totalVotes += proposals[i].voteCount * j;
                complexMap[totalVotes] = i;
            }
        }
    }
}