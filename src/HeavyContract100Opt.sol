// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HeavyContract100Opt {
    struct Bid {
        address bidder;
        uint256 amount;
    }

    mapping(uint256 => Bid[]) public auctionBids;
    mapping(uint256 => Bid) public highestBid;
    uint256 public auctionCounter;

    event NewBid(uint256 auctionId, address bidder, uint256 amount);
    event AuctionProcessed(uint256 auctionId, address highestBidder, uint256 highestAmount);

    function startNewAuction() public {
        auctionCounter++;
    }

    function placeBid(uint256 auctionId) public payable {
        require(auctionId > 0 && auctionId <= auctionCounter, "Invalid auctionId");
        require(msg.value > 0, "Bid amount must be greater than zero");

        auctionBids[auctionId].push(Bid(msg.sender, msg.value));
        emit NewBid(auctionId, msg.sender, msg.value);

        Bid storage currentHighest = highestBid[auctionId];
        if (msg.value > currentHighest.amount) {
            highestBid[auctionId] = Bid(msg.sender, msg.value);
        }
    }

    function processAuction(uint256 auctionId) public {
        require(auctionId > 0 && auctionId <= auctionCounter, "Invalid auctionId");

        Bid[] storage bids = auctionBids[auctionId];
        uint256 totalBids = bids.length;
        
        if(totalBids == 0) return; // Save gas by returning early if no bids
        
        uint256[][] memory matrix = new uint256[][](totalBids);
        
        for (uint256 i = 0; i < totalBids; ) {
            uint256[] memory row = new uint256[](totalBids); // cache row
            for (uint256 j = 0; j < totalBids; ) {
                row[j] = (bids[i].amount + bids[j].amount) / (i + j + 1);
                unchecked { j++; } // Unchecked increment to save gas
            }
            matrix[i] = row;
            unchecked { i++; } // Unchecked increment to save gas
        }

        uint256 sum;
        for (uint256 i = 0; i < totalBids; ) {
            for (uint256 j = 0; j < totalBids; ) {
                sum += matrix[i][j] * (i + j + 1);
                unchecked { j++; }
            }
            unchecked { i++; }
        }

        uint256 dummy = 1;
        for (uint256 i = 1; i < totalBids; ) {
            for (uint256 j = 1; j < totalBids; ) {
                dummy = (dummy * (matrix[i][j] % (i + j + 1))) + 1;
                unchecked { j++; }
            }
            unchecked { i++; }
        }

        emit AuctionProcessed(auctionId, highestBid[auctionId].bidder, highestBid[auctionId].amount);
    }

    function recursiveHeavyFunction(uint256 count) public pure returns (uint256) {
        if (count == 0) {
            return 0; // Fix logic to return 0 instead of count
        }
        return count + recursiveHeavyFunction(count - 1);
    }

    function getNumberOfBids(uint256 auctionId) public view returns (uint256) {
        require(auctionId > 0 && auctionId <= auctionCounter, "Invalid auctionId");
        return auctionBids[auctionId].length;
    }

    function manipulateAndStore(uint256 auctionId) public {
        require(auctionId > 0 && auctionId <= auctionCounter, "Invalid auctionId");

        uint256 len = auctionBids[auctionId].length; // Cache length in local variable
        uint256[] memory amounts = new uint256[](len);

        for (uint256 i = 0; i < len; ) {
            amounts[i] = auctionBids[auctionId][i].amount * (i + 1);
            unchecked { i++; }
        }

        uint256 sum;
        for (uint256 i = 0; i < len; ) {
            sum += amounts[i];
            unchecked { i++; }
        }

        if (sum > highestBid[auctionId].amount) {
            highestBid[auctionId].amount = sum;
        }
    }
}