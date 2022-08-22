//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IClaim {
    function addClaim(
        address msgSender,
        uint256 coverId,
        address protocolAddress,
        uint256 claimAmount
    ) external;
}
