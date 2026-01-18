// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract82 {
    struct Voter {
        bool voted;
        uint256 weight;
        uint256 vote;
    }

    struct Proposal {
        uint256 voteCount;
    }

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    uint256 public constant RECURSION_LIMIT = 50;

    constructor(uint256 numProposals) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        for (uint256 i = 0; i < numProposals; i++) {
            proposals.push(Proposal({ voteCount: 0 }));
        }
    }

    function register(address toVoter) public {
        require(msg.sender == chairperson, "Only chairperson can register.");
        require(!voters[toVoter].voted, "Already voted.");
        require(voters[toVoter].weight == 0, "Already registered.");
        voters[toVoter].weight = 1;
    }

    function vote(uint256 proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        // Gas intensive update
        for (uint256 i = 0; i < sender.weight; i++) {
            proposals[proposal].voteCount += 1;
        }
    }

    function computeHeavyTask(uint256 n) public pure returns (uint256) {
        uint256 result = 0;
        for (uint256 i = 0; i < n; i++) {
            for (uint256 j = 0; j < 100; j++) {
                result = uint256(keccak256(abi.encodePacked(result, i, j)));
            }
        }
        return result;
    }

    function bitwiseAndOperation(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a;
        for (uint256 i = 0; i < 256; i++) {
            result &= (b >> i);
        }
        return result;
    }

    function recursiveComputation(uint256 n) public pure returns (uint256) {
        if (n <= 1) {
            return 1;
        } else {
            return n * recursiveComputation(n - 1);
        }
    }

    function updateWeights(address[] memory votersList, uint256 increment) public {
        require(msg.sender == chairperson, "Only chairperson can update weights.");
        for (uint256 i = 0; i < votersList.length; i++) {
            address voterAddress = votersList[i];
            Voter storage voter = voters[voterAddress];
            uint256 newWeight = computeWeightedValue(voter.weight, increment);
            voter.weight = newWeight;
        }
    }

    function computeWeightedValue(uint256 weight, uint256 increment) internal pure returns (uint256) {
        uint256 result = weight;
        for (uint256 i = 0; i < increment; i++) {
            result += i;
            result ^= i;
            result |= (i << 5);
        }
        return result;
    }
}