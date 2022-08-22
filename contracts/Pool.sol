//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

error Pool__TransferFailed();
error Pool__NotClaimCaller();

contract Pool is Ownable {
    using SafeERC20 for IERC20;

    address public claimAddress;
    mapping(address => uint256) public tokenBalance;
    mapping(string => address) public tokenSymbolToAddress;

    event ReceivedEth(address indexed sender, uint256 indexed amount);

    modifier onlyClaim {
        if (msg.sender != claimAddress) {
            revert Pool__NotClaimCaller();
        }
        _;
    }

    constructor() {
        tokenSymbolToAddress[
            "NXP"
        ] = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }

    receive() external payable {
        emit ReceivedEth(msg.sender, msg.value);
    }

    function setClaimAddress(address _claimAddress) external onlyOwner {
        claimAddress = _claimAddress;
    }

    function fundToken(
        string calldata tokenSymbol,
        address msgSender,
        address pool,
        uint256 amount
    ) public {
        address tokenAddress = matchTokenSymbol(tokenSymbol);
        IERC20 token = IERC20(tokenAddress);
        token.safeTransferFrom(msgSender, pool, amount);
        tokenBalance[tokenAddress] += amount;
    }

    function withdrawToken(
        address msgSender,
        uint256 claimAmount,
        string calldata tokenSymbol
    ) public onlyClaim {
        if (keccak256(bytes(tokenSymbol)) == keccak256(bytes("ETH"))) {
            (bool success, ) = msgSender.call{value: claimAmount}("");
            if (!success) {
                revert Pool__TransferFailed();
            }
        } else {
            address tokenAddress = matchTokenSymbol(tokenSymbol);
            IERC20 token = IERC20(tokenAddress);
            tokenBalance[tokenAddress] -= claimAmount;
            token.safeTransfer(msgSender, claimAmount);
        }
    }

    function matchTokenSymbol(string calldata symbol)
        private
        view
        returns (address)
    {
        return tokenSymbolToAddress[symbol];
    }
}
