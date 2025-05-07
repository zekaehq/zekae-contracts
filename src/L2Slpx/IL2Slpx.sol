// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IL2Slpx {
    function createOrder(address tokenAddress, Operation operation, uint256 amount, string memory remark) external;

    function setTokenConversionInfo(address tokenAddress, Operation operation, uint256 minOrderAmount, uint256 tokenConversionRate, uint256 orderFee, address outputTokenAddress) external;
    function removeTokenConversionInfo(address tokenAddress) external;
    function withdrawFees(address tokenAddress) external;

    enum Operation {
        Mint,
        Redeem
    }

    struct TokenConversionInfo {
        Operation operation;
        uint256 minOrderAmount;
        uint256 tokenConversionRate;
        uint256 orderFee;
    }

    event CreateOrder(address tokenAddress, Operation operation, uint256 amount, string remark);

    error InvalidTokenAddress();
    error InvalidMinOrderAmount();
    error InvalidTokenConversionRate();
    error InvalidTokenFee();
    error InvalidVTokenAddress();
    error InvalidOperation();

    function addressToTokenConversionInfo(address tokenAddress) external view returns (TokenConversionInfo memory);
    function checkSupportToken(address tokenAddress) external view returns (bool);
    function getTokenConversionInfo(address tokenAddress) external view returns (TokenConversionInfo memory);
}