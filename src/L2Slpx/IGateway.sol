// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IGateway {
    function quoteSendTokenFee(address token, uint32 paraId, uint128 destinationFee) external view returns (uint256);

    function setSendTokenFee(uint256 _fee) external returns (uint256);

    function quoteExchangeRate(address token, uint32 paraId, uint128 destinationFee) external view returns (uint256);

    function setExchangeRate(uint256 _rate) external returns (uint256);
}
