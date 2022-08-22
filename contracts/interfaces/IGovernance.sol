//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IGovernance {
    function addMember(address memberAddress, uint256 fractalId) external;
    function proposedProtocolPassed(address protocolAddress) external returns (bool);
}