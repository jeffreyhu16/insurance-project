//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Distributable.sol";
import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";

error Governance__IneligibleVoter();
error Governance__NotDistributionCaller();

contract Governance is
    Distributable,
    Governor,
    GovernorSettings,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction
{
    address[] public accounts;
    mapping(address => uint256) public memberAddressToFractalId;
    mapping(uint256 => mapping(uint256 => bool))
        public proposalToFractalIdVoted;
    mapping(address => bool) public proposedProtocolPassed;

    constructor(
        IVotes _token,
        uint256 _votingDelay,
        uint256 _votingPeriod,
        uint256 quorumPercentage
    )
        Governor("Governance")
        GovernorSettings(_votingDelay, _votingPeriod, 0)
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(quorumPercentage)
    {} // use chainlink keepers to checkUpkeep for executing proposal

    function addMember(address memberAddress, uint256 fractalId)
        public
        onlyDistribution
    {
        memberAddressToFractalId[memberAddress] = fractalId;
        accounts.push(memberAddress);
    } // add access modifier

    function getaccounts() public view returns (address[] memory) {
        return accounts;
    }

    function castVote(uint256 proposalId, uint8 support)
        public
        override
        onlyDistribution
        returns (uint256 voteWeight)
    {
        uint256 fractalId = memberAddressToFractalId[msg.sender];
        bool isMember = fractalId > 0;
        bool hasVoted = proposalToFractalIdVoted[proposalId][fractalId];
        if (!isMember || hasVoted) {
            revert Governance__IneligibleVoter();
        }
        voteWeight = super._castVote(proposalId, msg.sender, support, "");
        proposalToFractalIdVoted[proposalId][fractalId] = true;
    }

    function votingDelay()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingDelay();
    }

    function votingPeriod()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function proposalThreshold()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.proposalThreshold();
    }

    function _getVotes(
        address, /*account*/
        uint256, /*blockNumber*/
        bytes memory /*params*/
    ) internal pure override(Governor, GovernorVotes) returns (uint256) {
        return 1;
    }

    function updateProposedProtocolPassed(address protocol) private {
        proposedProtocolPassed[protocol] = true;
    }
}
