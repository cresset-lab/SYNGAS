// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract15 {
    struct Bid {
        address bidder;
        uint256 amount;
    }

    mapping(address => uint256) public balances;
    mapping(address => Bid[]) public bids;
    address[] public bidders;
    string public concatenatedBids;
    uint256 public highestBid;
    address public highestBidder;
    string[] public bidHistory;

    // Place a new bid
    function placeBid(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");

        // Update bid storage
        bids[msg.sender].push(Bid(msg.sender, amount));
        bidders.push(msg.sender);
        balances[msg.sender] += amount;

        // Check if the current bid is the highest
        if (amount > highestBid) {
            highestBid = amount;
            highestBidder = msg.sender;
        }

        // Perform gas-heavy operations
        _heavyConcatenation();
        _complexCalculations(amount);
    }

    // Concatenate all bids into a single string
    function _heavyConcatenation() internal {
        string memory tempConcatenated = "";
        for (uint256 i = 0; i < bidders.length; i++) {
            for (uint256 j = 0; j < bids[bidders[i]].length; j++) {
                tempConcatenated = string(abi.encodePacked(tempConcatenated, uint2str(bids[bidders[i]][j].amount), ";"));
            }
        }
        concatenatedBids = tempConcatenated;
    }

    // Execute complex calculations
    function _complexCalculations(uint256 base) internal {
        uint256 result = 1;
        for (uint256 i = 1; i <= 10; i++) {
            result *= base + i;
            for (uint256 j = 0; j < 5; j++) {
                result += i * j;
            }
        }
        bidHistory.push(uint2str(result));
    }

    // Simulate a heavy computation and update storage
    function simulateHeavyLoad(uint256 iterations) public {
        require(iterations > 0 && iterations <= 100, "Invalid number of iterations");
        uint256 sum = 0;
        for (uint256 i = 0; i < iterations; i++) {
            for (uint256 j = 0; j < iterations; j++) {
                sum += i * j;
            }
            balances[msg.sender] = sum; // Frequent SSTORE
        }
    }

    // Convert a uint to a string
    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    // Reset the auction for a new round
    function resetAuction() public {
        for (uint256 i = 0; i < bidders.length; i++) {
            delete bids[bidders[i]];
        }
        delete bidders;
        concatenatedBids = "";
        highestBid = 0;
        highestBidder = address(0);
    }
    
    // Get the bid history
    function getBidHistory() public view returns (string[] memory) {
        return bidHistory;
    }
}