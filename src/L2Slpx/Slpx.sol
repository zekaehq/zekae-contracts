// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import {IVToken} from "src/L2Slpx/IVToken.sol";

contract Slpx is Ownable {
    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/
    error InvalidTokenAddress();
    error InvalidMinOrderAmount();
    error InvalidTokenConversionRate();
    error InvalidTokenFee();
    error InvalidVTokenAddress();
    error InvalidOperation();
    error InvalidOrderAmount();
    error InsufficientBalance();
    error InsufficientApproval();
    error InsufficientVTokenBalance();
    error ETHTransferFailed();


    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/
    event CreateOrder(address tokenAddress, Operation operation, uint256 amount, string remark);

    /*//////////////////////////////////////////////////////////////
                            STRUCTS & ENUMS
    //////////////////////////////////////////////////////////////*/
    enum Operation {
        Mint,
        Redeem
    }

    struct TokenConversionInfo {
        Operation operation;
        uint256 minOrderAmount;
        uint256 tokenConversionRate;
        uint256 tokenFee;
        address vTokenAddress;
    }

    /*//////////////////////////////////////////////////////////////
                            MAPPINGS
    //////////////////////////////////////////////////////////////*/
    mapping(address => TokenConversionInfo) public addressToTokenConversionInfo;

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    /// @notice Initialize the contract
    /// @param _owner The owner of the contract
    constructor(address _owner) Ownable(_owner) {}

    /*//////////////////////////////////////////////////////////////
                            CORE LOGIC
    //////////////////////////////////////////////////////////////*/

    function createOrder(address tokenAddress, uint256 amount, Operation operation, string memory remark)
        external
        payable
    {
        // Checks
        if (!checkSupportToken(tokenAddress)) revert InvalidTokenAddress();
        if (amount < addressToTokenConversionInfo[tokenAddress].minOrderAmount) revert InvalidOrderAmount();
        if (amount < addressToTokenConversionInfo[tokenAddress].tokenFee) revert InvalidOrderAmount();
        if (operation != addressToTokenConversionInfo[tokenAddress].operation) revert InvalidOperation();
        if (tokenAddress == address(0)) {
            // Handle native ETH
            if (msg.value < amount) revert InsufficientBalance();
            if (msg.value < addressToTokenConversionInfo[tokenAddress].tokenFee) revert InsufficientBalance();
        } else {
            if (IVToken(tokenAddress).balanceOf(msg.sender) < amount) revert InsufficientBalance();
            if (IVToken(tokenAddress).allowance(msg.sender, address(this)) < amount) revert InsufficientApproval();
        }

        // Effects
        if (operation == Operation.Mint) {
            if (tokenAddress == address(0)) {
                // Native ETH comes with the msg.value
                IVToken(addressToTokenConversionInfo[tokenAddress].vTokenAddress).mint(msg.sender, amount);
            } else {
                IVToken(tokenAddress).transferFrom(msg.sender, address(this), amount);
                IVToken(addressToTokenConversionInfo[tokenAddress].vTokenAddress).mint(msg.sender, amount);
            }
        }

        if (operation == Operation.Redeem) {
            if (tokenAddress == address(0)) {
                // Native ETH comes with the msg.value
                IVToken(addressToTokenConversionInfo[tokenAddress].vTokenAddress).burn(amount);
                (bool success, ) = msg.sender.call{value: amount}("");
                if (!success) revert ETHTransferFailed();
            } else {
                IVToken(addressToTokenConversionInfo[tokenAddress].vTokenAddress).burn(amount);
                IVToken(tokenAddress).transfer(msg.sender, amount);
            }
        }

        emit CreateOrder(tokenAddress, operation, amount, remark);
    }

    /*//////////////////////////////////////////////////////////////
                            ADMIN SETTERS
    //////////////////////////////////////////////////////////////*/

    function setTokenConversionInfo(
        address tokenAddress,
        Operation operation,
        uint256 minOrderAmount,
        uint256 tokenConversionRate,
        uint256 tokenFee,
        address vTokenAddress
    ) public onlyOwner {
        if (minOrderAmount <= 0) revert InvalidMinOrderAmount();
        if (tokenConversionRate <= 0) revert InvalidTokenConversionRate();
        if (tokenFee < 0) revert InvalidTokenFee();
        if (operation != Operation.Mint && operation != Operation.Redeem) revert InvalidOperation();
        if (vTokenAddress == address(0)) revert InvalidVTokenAddress();
        addressToTokenConversionInfo[tokenAddress] =
            TokenConversionInfo(operation, minOrderAmount, tokenConversionRate, tokenFee, vTokenAddress);
    }

    /*//////////////////////////////////////////////////////////////
                            SUPPORT FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /// @notice Check if the token is supported
    /// @param tokenAddress The address of the token
    /// @return true if the token is supported, false otherwise
    function checkSupportToken(address tokenAddress) public view returns (bool) {
        TokenConversionInfo memory tokenConversionInfo = addressToTokenConversionInfo[tokenAddress];
        return tokenConversionInfo.minOrderAmount > 0 && tokenConversionInfo.tokenConversionRate > 0
            && tokenConversionInfo.tokenFee >= 0;
    }

    /// @notice Get the token conversion info
    /// @param tokenAddress The address of the token
    /// @return The token conversion info
    function getTokenConversionInfo(address tokenAddress) public view returns (TokenConversionInfo memory) {
        return addressToTokenConversionInfo[tokenAddress];
    }
}
