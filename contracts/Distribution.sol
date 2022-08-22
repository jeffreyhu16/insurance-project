//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ICover.sol";
import "./interfaces/IClaim.sol";
import "./interfaces/IQuote.sol";
import "./interfaces/IPool.sol";
import "./interfaces/IGovernance.sol";

error Distribution__NotApprovedNorOwner();
error Distribution__CoverInactive();
error Distribution_TransferFailed();

contract Distribution is ERC721Votes, Ownable {
    ICover public immutable cover;
    IClaim public immutable claim;
    IQuote public immutable quote;
    IPool public immutable pool;
    IGovernance public gov;

    event ReceivedEth(address indexed sender, uint256 indexed amount);

    modifier onlyTokenApprovedOrCreator(uint256 coverId) {
        if (!_isApprovedOrOwner(msg.sender, coverId)) {
            revert Distribution__NotApprovedNorOwner();
        }
        _;
    }

    constructor(
        address coverAddress,
        address claimAddress,
        address quoteAddress,
        address poolAddress
    ) ERC721("Nexus !Fungible Token", "NFT") EIP712("Nexus Plus", "v0.0.1") {
        cover = ICover(coverAddress);
        claim = IClaim(claimAddress);
        quote = IQuote(quoteAddress);
        pool = IPool(poolAddress);
    }

    receive() external payable {
        emit ReceivedEth(msg.sender, msg.value);
    }

    function setGovernance(address governanceAddress) external onlyOwner {
        gov = IGovernance(governanceAddress);
    }

    function buyCover(
        uint256 fractalId,
        address coverProtocol,
        string calldata coverAsset,
        uint256 coverAmount,
        uint256 premiumAmount,
        uint256 coverStart,
        uint256 coverEnd
    ) public payable {
        if (keccak256(bytes(coverAsset)) == keccak256(bytes("ETH"))) {
            (bool success, ) = address(pool).call{value: msg.value}("");
            if (!success) {
                revert Distribution_TransferFailed();
            }
        } else {
            pool.fundToken(
                coverAsset,
                msg.sender,
                address(pool),
                premiumAmount
            );
        }
        uint256 coverId = cover.addCover(
            payable(msg.sender),
            coverProtocol,
            coverAsset,
            coverAmount,
            premiumAmount,
            coverStart,
            coverEnd
        );
        _safeMint(msg.sender, coverId);
        gov.addMember(msg.sender, fractalId);
    }

    function submitClaim(
        uint256 coverId,
        address protocolAddress,
        uint256 claimAmount
    ) public onlyTokenApprovedOrCreator(coverId) {
        if (cover.getCoverStatus(coverId) != ICover.CoverStatus.Active) {
            revert Distribution__CoverInactive();
        }
        claim.addClaim(msg.sender, coverId, protocolAddress, claimAmount);
    }

    function _getVotingUnits(
        address /*account*/
    ) internal pure override returns (uint256) {
        return 1;
    }
}
