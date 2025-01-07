// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
pragma solidity ^0.8.28;

contract XcmOracle is Ownable {

    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/


    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    struct PoolInfo {
        uint256 assetAmount;
        uint256 vAssetAmount;
    }

    struct RateInfo {
        uint8 mintRate;
        uint8 redeemRate;
    }

    mapping(address => bytes2) public addressToCurrencyId;

    RateInfo public rateInfo;

    mapping(bytes2 => PoolInfo) public tokenPool;

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(
        address _owner
    ) Ownable(_owner) {}

    /*//////////////////////////////////////////////////////////////
                            CORE LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Setting the rate for minting and redeeming.
    /// @dev This function is used to set the rate for minting and redeeming.
    /// @param _mintRate The mint rate.
    /// @param _redeemRate The redeem rate.
    function setRate(uint8 _mintRate, uint8 _redeemRate) public onlyOwner {
        rateInfo.mintRate = _mintRate;
        rateInfo.redeemRate = _redeemRate;
    }

    /// @notice Setting up data with XCM.
    /// @dev This function is used to set up data with XCM.
    /// @param _currencyId The currencyId.
    /// @param _assetAmount The asset amount.
    /// @param _vAssetAmount The vAsset amount.
    function setTokenAmount(
        bytes2 _currencyId,
        uint256 _assetAmount,
        uint256 _vAssetAmount
    ) public onlyOwner {
        PoolInfo storage poolInfo = tokenPool[_currencyId];
        poolInfo.assetAmount = _assetAmount;
        poolInfo.vAssetAmount = _vAssetAmount;
    }

    /// @notice Get the vToken amount by the token amount.
    /// @dev This function is used to get the vToken amount by the token amount.
    /// @param _assetAddress The asset address.
    /// @param _assetAmount The token amount.
    /// @return The vToken amount.
    function getVTokenByToken(
        address _assetAddress,
        uint256 _assetAmount
    ) public view returns (uint256) {
        bytes2 currencyId = getCurrencyIdByAssetAddress(_assetAddress);
        PoolInfo memory poolInfo = tokenPool[currencyId];
        require(
            poolInfo.vAssetAmount != 0 && poolInfo.assetAmount != 0,
            "Not ready"
        );
        uint256 mintFee = (rateInfo.mintRate * _assetAmount) / 10000;
        uint256 assetAmountExcludingFee = _assetAmount - mintFee;
        uint256 vAssetAmount = (assetAmountExcludingFee *
            poolInfo.vAssetAmount) / poolInfo.assetAmount;
        return vAssetAmount;
    }

    /// @notice Get the token amount by the vToken amount.
    /// @dev This function is used to get the token amount by the vToken amount.
    /// @param _assetAddress The asset address.
    /// @param _vAssetAmount The vToken amount.
    /// @return The token amount.
    function getTokenByVToken(
        address _assetAddress,
        uint256 _vAssetAmount
    ) public view returns (uint256) {
        bytes2 currencyId = getCurrencyIdByAssetAddress(_assetAddress);
        PoolInfo memory poolInfo = tokenPool[currencyId];
        require(
            poolInfo.vAssetAmount != 0 && poolInfo.assetAmount != 0,
            "Not ready"
        );
        uint256 redeemFee = (rateInfo.redeemRate * _vAssetAmount) / 10000;
        uint256 vAssetAmountExcludingFee = _vAssetAmount - redeemFee;
        uint256 assetAmount = (vAssetAmountExcludingFee *
            poolInfo.assetAmount) / poolInfo.vAssetAmount;
        return assetAmount;
    }

    /// @notice Get the currencyId by the asset address.
    /// @dev This function is used to get the currencyId by the asset address.
    /// @param _assetAddress The asset address.
    /// @return The currencyId.
    function getCurrencyIdByAssetAddress(
        address _assetAddress
    ) public view returns (bytes2) {
        bytes2 currencyId = addressToCurrencyId[_assetAddress];
        require(currencyId != 0x0000, "Not found");
        return currencyId;
    }

    /// @notice Set the currencyId by the asset address.
    /// @dev This function is used to set the currencyId by the asset address.
    /// @param _assetAddress The asset address.
    /// @param _currencyId The currencyId.
    function setAddressToCurrencyId(
        address _assetAddress,
        bytes2 _currencyId
    ) public onlyOwner {
        addressToCurrencyId[_assetAddress] = _currencyId;
    }
}
