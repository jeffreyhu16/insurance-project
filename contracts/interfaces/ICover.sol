//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ICover {
    enum CoverStatus {
        Active,
        Expired
    }

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

    function addCover(
        address payable coverAddress,
        address coverProtocol,
        string calldata coverAsset,
        uint256 coverAmount,
        uint256 premiumAmount,
        uint256 coverStart,
        uint256 coverEnd
    ) external returns (uint256 coverId);

    function covers(uint256 coverId) external view returns (CoverData memory);

    function getCoverStatus(uint256 coverId) external view returns (CoverStatus);
}
