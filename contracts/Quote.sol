//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Quote is Ownable {
    struct QuoteData {
        string protocolName;
        address protocolAddress;
        int16 premiumRate;
    }

    // add cross-chain filter

    QuoteData[] public quotes;

    event QuoteDataAdded(
        string indexed protocolName,
        address indexed protocolAddress,
        int16 indexed premiumRate
    );

    function addQuote(
        string calldata protocolName,
        address protocolAddress,
        int16 premiumRate
    ) public onlyOwner {
        quotes.push(QuoteData(protocolName, protocolAddress, premiumRate));
        emit QuoteDataAdded(protocolName, protocolAddress, premiumRate);
    }

    function getQuotes() public view returns (QuoteData[] memory) {
        return quotes;
    }
}
