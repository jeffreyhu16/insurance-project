//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Distributable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/ICover.sol";
import "./interfaces/IPool.sol";
import "./interfaces/IGovernance.sol";

error Claim__NotDistributionCaller();
error Claim__protocolUnapproved();
error Claim__incorrectClaimAmount();

contract Claim is Distributable {
    using Counters for Counters.Counter;

    struct ClaimData {
        uint256 claimDate;
        uint256 coverId;
        address protocol;
        uint256 claimAmount;
    }

    ICover public immutable cover;
    IPool public immutable pool;
    IGovernance public gov;
    Counters.Counter public claimCount;
    mapping(uint256 => ClaimData) public claims;

    event ClaimCreated(uint256 indexed claimId, uint256 claimAmount);
    event ClaimRedeemed(uint256 indexed claimId, uint256 claimAmount);

    constructor(
        address coverAddress,
        address poolAddress
    ) {
        cover = ICover(coverAddress);
        pool = IPool(poolAddress);
    }

    function setGovernance(address governanceAddress) external onlyOwner {
        gov = IGovernance(governanceAddress);
    }

    function addClaim(
        address msgSender,
        uint256 _coverId,
        address _protocol,
        uint256 _claimAmount
    ) public onlyDistribution {
        bool proposedProtocolStatus = gov.proposedProtocolPassed(_protocol);
        if (!proposedProtocolStatus) {
            revert Claim__protocolUnapproved();
        }
        claimCount.increment();
        uint256 claimId = claimCount.current();
        ClaimData storage newClaim = claims[claimId];

        newClaim.claimDate = block.timestamp;
        newClaim.coverId = _coverId;
        newClaim.protocol = _protocol;
        newClaim.claimAmount = _claimAmount;

        emit ClaimCreated(claimId, _claimAmount);
        redeemClaim(msgSender, claimId, _coverId);
    }

    function redeemClaim(
        address msgSender,
        uint256 claimId,
        uint256 coverId
    ) private {
        uint256 claimAmount = claims[claimId].claimAmount;
        uint256 coverAmount = cover.covers(coverId).coverAmount;
        if (claimAmount != coverAmount) {
            revert Claim__incorrectClaimAmount();
        }
        string memory coverAsset = cover.covers(coverId).coverAsset;
        pool.withdrawToken(msgSender, claimAmount, coverAsset);
        emit ClaimRedeemed(claimId, claimAmount);
    }
}
