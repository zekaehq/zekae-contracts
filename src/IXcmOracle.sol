// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title IXcmOracle Interface
/// @notice Interface for the XCM Oracle that handles cross-chain message verification
interface IXcmOracle {

    struct PoolInfo {
        address token;
        uint256 balance;
        // Add other necessary fields based on your requirements
    }

    struct RateInfo {
        uint8 mintRate;
        uint8 redeemRate;
    }

    /// @notice Returns the owner address of the contract
    /// @return address The owner address
    function owner() external view returns (address);

    /// @notice Returns the vToken amount by the token amount
    /// @param _assetAddress The asset address
    /// @param _assetAmount The asset amount
    /// @return uint256 The vToken amount
    function getVTokenByToken(address _assetAddress, uint256 _assetAmount) external view returns (uint256);

    /// @notice Returns the token amount by the vToken amount
    /// @param _assetAddress The asset address
    /// @param _vAssetAmount The vToken amount
    /// @return uint256 The token amount
    function getTokenByVToken(address _assetAddress, uint256 _vAssetAmount) external view returns (uint256);

    /// @notice Returns the currencyId by the asset address
    /// @param _assetAddress The asset address
    /// @return bytes2 The currencyId
    function getCurrencyIdByAssetAddress(address _assetAddress) external view returns (bytes2);
}
