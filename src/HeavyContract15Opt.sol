
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract15Opt {
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

        // Directly append the new bid if bidder is already present
        if (bids[msg.sender].length == 0) {
            bidders.push(msg.sender);
        }
        bids[msg.sender].push(Bid(msg.sender, amount));
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
        uint256 bidders_len = bidders.length;
        bytes memory tempConcatenated = "";
        for (uint256 i = 0; i < bidders_len; i++) {
            address bidder = bidders[i];
            uint256 bid_length = bids[bidder].length;
            for (uint256 j = 0; j < bid_length; j++) {
                tempConcatenated = abi.encodePacked(tempConcatenated, uint2str(bids[bidder][j].amount), ";");
            }
        }
        concatenatedBids = string(tempConcatenated);
    }

    // Execute complex calculations
    function _complexCalculations(uint256 base) internal {
        uint256 result = 1;
        for (uint256 i = 1; i <= 10; i++) {
            result *= base + i + 10;
        }
        bidHistory.push(uint2str(result));
    }

    // Simulate a heavy computation and update storage
    function simulateHeavyLoad(uint256 iterations) public {
        require(iterations > 0 && iterations <= 100, "Invalid number of iterations");
        uint256 sum;
        for (uint256 i = 0; i < iterations; i++) {
            uint256 tempSum;
            for (uint256 j = 0; j < iterations; j++) {
                tempSum += i * j;
            }
            sum += tempSum;
        }
        balances[msg.sender] = sum; // Single SSTORE
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
            bstr[--k] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    // Reset the auction for a new round
    function resetAuction() public {
        uint256 bidders_len = bidders.length;
        for (uint256 i = 0; i < bidders_len; i++) {
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
