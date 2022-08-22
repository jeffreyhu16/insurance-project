//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./Distributable.sol";

error Cover__NotDistributionCaller();

contract Cover is Distributable {
    using Counters for Counters.Counter;

    enum CoverStatus {
        Active,
        Expired
    }

    // create a chainlink keepers function to update CoverStatus

    struct CoverData {
        address payable coverAddress;
        address coverProtocol;
        string coverAsset;
        uint256 coverAmount;
        uint256 premiumAmount;
        uint256 coverStart;
        uint256 coverEnd;
        CoverStatus status;
    }

    Counters.Counter public coverCount;
    mapping(uint256 => CoverData) public covers;

    event CoverPurchased(
        uint256 indexed coverId,
        address indexed coverAddress,
        uint256 indexed premiumAmount
    );

    function addCover(
        address payable coverAddress,
        address coverProtocol,
        string calldata coverAsset,
        uint256 coverAmount,
        uint256 premiumAmount,
        uint256 coverStart,
        uint256 coverEnd
    ) public onlyDistribution {
        coverCount.increment();
        uint256 coverId = coverCount.current();
        covers[coverId] = CoverData(
            coverAddress,
            coverProtocol,
            coverAsset,
            coverAmount,
            premiumAmount,
            coverStart,
            coverEnd,
            CoverStatus.Active
        );
        emit CoverPurchased(coverId, coverAddress, premiumAmount);
    }

    function getCoverStatus(uint256 coverId) public view returns (CoverStatus) {
        return covers[coverId].status;
    }
}
