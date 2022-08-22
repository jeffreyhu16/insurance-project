//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IPool {
    function fundToken(
        string calldata tokenSymbol,
        address msgSender,
        address pool,
        uint256 amount
    ) external;

    function withdrawToken(
        address msgSender,
        uint256 claimAmount,
        string calldata coverAsset
    ) external;
}
