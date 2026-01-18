// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract13 {

    struct Voter {
        bool voted;
        uint weight;
        uint vote;
    }

    struct Proposal {
        string name;
        uint voteCount;
    }

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;
    string public concatenatedProposalNames;
    uint public totalWeight;

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
        require(voters[voter].weight == 0, "The voter already has the right to vote.");
        voters[voter].weight = 1;
    }

    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote.");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
        totalWeight += sender.weight;
        updateConcatenatedProposalNames();
    }

    function updateConcatenatedProposalNames() internal {
        concatenatedProposalNames = "";
        for (uint i = 0; i < proposals.length; i++) {
            concatenatedProposalNames = string(abi.encodePacked(concatenatedProposalNames, proposals[i].name));
        }
    }

    function computeWeightedSum() public view returns (uint) {
        uint weightedSum = 0;
        for (uint i = 0; i < proposals.length; i++) {
            weightedSum += proposals[i].voteCount * i;
        }
        return weightedSum;
    }

    function changeProposalName(uint index, string memory newName) public {
        require(msg.sender == chairperson, "Only chairperson can change proposal names.");
        require(index < proposals.length, "Proposal index out of bounds.");
        proposals[index].name = newName;
        updateConcatenatedProposalNames();
    }

    function complexCalculation(uint iterations) public view returns (uint) {
        uint result = 0;
        for (uint i = 0; i < iterations; i++) {
            for (uint j = 0; j < proposals.length; j++) {
                result += (i + 1) * (j + 1) * proposals[j].voteCount;
            }
        }
        return result;
    }
}