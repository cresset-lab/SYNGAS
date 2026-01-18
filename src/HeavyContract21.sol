// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract21 {
    struct Voter {
        uint weight;
        bool voted;
        uint vote;
    }

    struct Proposal {
        string name;
        uint voteCount;
    }

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;
    uint[] public complexArray;
    string public resultString;
    uint public heavyCalculationResult;

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
        require(voters[voter].weight == 0, "Voter already has the right to vote.");
        voters[voter].weight = 1;
    }

    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
        updateComplexArray(proposal);
    }

    function executeComplexCalculation(uint seed) public {
        heavyCalculationResult = 0;
        uint length = complexArray.length;
        for (uint i = 0; i < length; i++) {
            heavyCalculationResult += complexArray[i] * seed;
            for (uint j = 0; j < 100; j++) {
                complexArray[i] = complexArray[i] * 2 + j;
            }
        }

        while (length > 0) {
            length--;
            heavyCalculationResult += complexArray[length] * length;
        }
    }

    function concatenateProposalNames() public {
        string memory concatenatedNames = "";
        for(uint i = 0; i < proposals.length; i++) {
            string memory tempName = proposals[i].name;
            for(uint j = 0; j < 10; j++) {
                tempName = string(abi.encodePacked(tempName, "X"));
            }
            concatenatedNames = string(abi.encodePacked(concatenatedNames, tempName));
        }
        resultString = concatenatedNames;
    }

    function updateComplexArray(uint value) internal {
        complexArray.push(value);
        for(uint i = 0; i < complexArray.length; i++) {
            complexArray[i] = (complexArray[i] + value) * 2;
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

    function winnerName() public view returns (string memory winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }
}