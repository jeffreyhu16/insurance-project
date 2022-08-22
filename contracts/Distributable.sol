//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

error Distributable__NotDistributionCaller();

contract Distributable is Ownable {
    address public distributionAddress;

    modifier onlyDistribution {
        if (msg.sender != distributionAddress) {
            revert Distributable__NotDistributionCaller();
        }
        _;
    }

    function setDistribution(address _distributionAddress) external onlyOwner {
        distributionAddress = _distributionAddress;
    }
}