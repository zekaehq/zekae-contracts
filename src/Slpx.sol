// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {vTOKEN} from "src/vTOKEN.sol";
import {IGateway} from "src/IGateway.sol";

contract Slpx is Ownable {
    /*//////////////////////////////////////////////////////////////
                            VARIABLES
    //////////////////////////////////////////////////////////////*/
    IGateway public gateway;
    uint128 public destinationFee; // set at 1000000
    uint32 public paraId; // set at 2030
    uint256 public fee; // set at 1000000

    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/
    event CreateOrder(
        address assetAddress,
        uint128 amount,
        uint64 dest_chain_id,
        bytes receiver,
        string remark,
        uint32 channel_id
    );

    /*//////////////////////////////////////////////////////////////
                            TOKENS
    //////////////////////////////////////////////////////////////*/
    vTOKEN public vtoken;


    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(address _gateway, address _vtoken, uint128 _destinationFee, uint128 _fee, uint32 _paraId, address _owner)
        Ownable(_owner)
    {
        gateway = IGateway(_gateway);
        vtoken = vTOKEN(_vtoken);
        destinationFee = _destinationFee;
        fee = _fee;
        paraId = _paraId;
    }

    /*//////////////////////////////////////////////////////////////
                            CORE LOGIC
    //////////////////////////////////////////////////////////////*/
    // function mint() external payable {
    //     require(msg.value >= fee, "msg.value to low");
    //     uint256 exchangeRate = gateway.quoteExchangeRate(address(vtoken), paraId, destinationFee);
    //     vtoken.mint(msg.sender, msg.value * 1e18 / exchangeRate);
    // }

    // function redeem(uint256 amount) external {
    //     vtoken.burn(amount);
    //     gateway.redeem(address(vtoken), amount, paraId, msg.sender);
    // }


    function createOrder(address assetAddress, uint128 amount, uint64 dest_chain_id, bytes memory receiver, string memory remark, uint32 channel_id) external payable {
        require(msg.value >= fee, "msg.value to low");
        emit CreateOrder(assetAddress, amount, dest_chain_id, receiver, remark, channel_id);
    }

    /*//////////////////////////////////////////////////////////////
                            SETTERS
    //////////////////////////////////////////////////////////////*/
    function setGateway(address _gateway) external onlyOwner {
        gateway = IGateway(_gateway);
    }

    function setVtoken(address _vtoken) external onlyOwner {
        vtoken = vTOKEN(_vtoken);
    }

    function setDestinationFee(uint128 _destinationFee) external onlyOwner {
        destinationFee = _destinationFee;
    }

    function setParaId(uint32 _paraId) external onlyOwner {
        paraId = _paraId;
    }

    /*//////////////////////////////////////////////////////////////
                            SUPPORT FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function checkAssetIsExist(
        address assetAddress
    ) internal view returns (bytes2) {
        AssetInfo memory assetInfo = addressToAssetInfo[assetAddress];
        require(assetInfo.operationalMin > 0, "Asset is not exist");
        require(assetInfo.currencyId != bytes2(0), "Invalid asset");
        return assetInfo.currencyId;
    }

    function checkFeeInfo(
        Operation operation
    ) internal view returns (FeeInfo memory) {
        FeeInfo memory feeInfo = operationToFeeInfo[operation];
        require(
            feeInfo.transactRequiredWeightAtMost > 0,
            "Invalid transactRequiredWeightAtMost"
        );
        require(feeInfo.feeAmount > 0, "Invalid feeAmount");
        require(feeInfo.overallWeight > 0, "Invalid overallWeight");
        return feeInfo;
    }

    function setOperationToFeeInfo(
        Operation _operation,
        uint64 _transactRequiredWeightAtMost,
        uint64 _overallWeight,
        uint256 _feeAmount
    ) public onlyOwner {
        operationToFeeInfo[_operation] = FeeInfo(
            _transactRequiredWeightAtMost,
            _feeAmount,
            _overallWeight
        );
    }

    function setAssetAddressInfo(
        address assetAddress,
        bytes2 currencyId,
        uint256 minimumValue
    ) public onlyOwner {
        require(assetAddress != address(0), "Invalid assetAddress");
        require(minimumValue != 0, "Invalid minimumValue");
        require(currencyId != bytes2(0), "Invalid currencyId");
        AssetInfo storage assetInfo = addressToAssetInfo[assetAddress];
        assetInfo.currencyId = currencyId;
        assetInfo.operationalMin = minimumValue;
    }

    function setDestChainInfo(
        uint64 dest_chain_id,
        bool is_evm,
        bool is_substrate,
        bytes1 raw_chain_index
    ) public onlyOwner {
        require(
            !(is_evm && is_substrate),
            "Both is_evm and is_substrate cannot be true"
        );
        DestChainInfo storage chainInfo = destChainInfo[dest_chain_id];
        chainInfo.is_evm = is_evm;
        chainInfo.is_substrate = is_substrate;
        chainInfo.raw_chain_index = raw_chain_index;
    }
}
