// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import {xcvDOT} from "src/xcvDOT.sol";
import {xcvGLMR} from "src/xcvGLMR.sol";
import {xcvASTR} from "src/xcvASTR.sol";
import {BifrostMock} from "src/BifrostMock.sol";

contract MoonbeamSlpx is Ownable, Pausable {
    /*//////////////////////////////////////////////////////////////
                            CONSTANTS
    //////////////////////////////////////////////////////////////*/
    address internal constant NATIVE_ASSET_ADDRESS = 0x0000000000000000000000000000000000000802;
    address internal constant XCM_TRANSACTORV2_ADDRESS = 0x000000000000000000000000000000000000080D;
    address internal constant XTOKENS = 0x0000000000000000000000000000000000000804;
    bytes1 internal constant MOONBEAM_CHAIN = 0x01;

    address public BNCAddress = 0xFFffffFf7cC06abdF7201b350A1265c62C8601d2; // set at 0xFFffffFf7cC06abdF7201b350A1265c62C8601d2
    uint32 public bifrostParaId = 2030; // set at 2030

    BifrostMock bifrostMock;


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
                            TEST LSTs
    //////////////////////////////////////////////////////////////*/
    xcvDOT xcvdot;
    xcvGLMR xcvglmr;
    xcvASTR xcvastr;

    /*//////////////////////////////////////////////////////////////
                            TOKENS
    //////////////////////////////////////////////////////////////*/
    IERC20 glmr;
    IERC20 xcdot;
    IERC20 xcastr;

    /*//////////////////////////////////////////////////////////////
                            STRUCTS & ENUMS
    //////////////////////////////////////////////////////////////*/
    enum Operation {
        Mint,
        Redeem,
        ZenlinkSwap,
        StableSwap
    }

    struct AssetInfo {
        bytes2 currencyId;
        uint256 operationalMin;
    }

    struct FeeInfo {
        uint64 transactRequiredWeightAtMost;
        uint256 feeAmount;
        uint64 overallWeight;
    }

    struct DestChainInfo {
        bool is_evm;
        bool is_substrate;
        bytes1 raw_chain_index;
    }

    /*//////////////////////////////////////////////////////////////
                            MAPPINGS
    //////////////////////////////////////////////////////////////*/
    mapping(address => AssetInfo) public addressToAssetInfo;
    mapping(Operation => FeeInfo) public operationToFeeInfo;
    mapping(uint64 => DestChainInfo) public destChainInfo;

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(address _glmr, address _xcdot, address _xcastr, address _xcvdot, address _xcvglmr, address _xcvastr, address _owner) Ownable(_owner) {
        glmr = IERC20(_glmr);
        xcdot = IERC20(_xcdot);
        xcastr = IERC20(_xcastr);
        xcvdot = xcvDOT(_xcvdot);
        xcvglmr = xcvGLMR(_xcvglmr);
        xcvastr = xcvASTR(_xcvastr);
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

    /*//////////////////////////////////////////////////////////////
                            MAIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Create order to mint vAsset or redeem vAsset on bifrost chain
     * @param assetAddress The address of the asset to mint or redeem
     * @param amount The amount of the asset to mint or redeem
     * @param dest_chain_id When order is executed, Asset/vAsset will be transferred to this chain
     * @param receiver The receiver address on the destination chain, 20 bytes for EVM, 32 bytes for Substrate
     * @param remark The remark of the order, less than 32 bytes. For example, "OmniLS"
     * @param channel_id The channel id of the order, you can set it. Bifrost chain will use it to share reward.
     **/
    function create_order(
        address assetAddress,
        uint128 amount,
        uint64 dest_chain_id,
        bytes memory receiver,
        string memory remark,
        uint32 channel_id
    ) external payable {
        // Check remark
        require(
            bytes(remark).length > 0 && bytes(remark).length <= 32,
            "remark must be less than 32 bytes and not empty"
        );

        // Check amount
        require(amount > 0, "amount must be greater than 0");

        // Load dest chain info
        DestChainInfo memory chainInfo = destChainInfo[dest_chain_id];

        // Separate evm and substrate chain
        if (chainInfo.is_evm) {
            require(receiver.length == 20, "evm address must be 20 bytes");
        } else if (chainInfo.is_substrate) {
            require(
                receiver.length == 32,
                "substrate public key must be 32 bytes"
            );
        } else {
            revert("Destination chain is not supported"); // revert if dest chain is not supported
        }

        // Check asset - temporarily disable
        // bytes2 token = checkAssetIsExist(assetAddress);

        // Transfer asset to bifrost mock
        if (assetAddress == NATIVE_ASSET_ADDRESS) {
            (bool sent, ) = address(bifrostMock).call{value: msg.value}("");
            require(sent, "Failed to send GLMR to Bifrost");
        }
        if (assetAddress == address(xcvdot)) {
            xcvdot.transferFrom(_msgSender(), address(this), amount);
        }
        if (assetAddress == address(xcvglmr)) {
            xcvglmr.transferFrom(_msgSender(), address(this), amount);
        }
        if (assetAddress == address(xcvastr)) {
            xcvastr.transferFrom(_msgSender(), address(this), amount);
        }

        // Check for fee info - temporarily disable
        // FeeInfo memory feeInfo = checkFeeInfo(Operation.Mint); 

        // Mint vAsset
        if (assetAddress == address(xcvdot)) {
            xcvdot.mint(_msgSender(), amount);
        } else if (assetAddress == address(xcvglmr)) {
            xcvglmr.mint(_msgSender(), amount);
        } else if (assetAddress == address(xcvastr)) {
            xcvastr.mint(_msgSender(), amount);
        } else {
            revert("Asset is not supported");
        }

        emit CreateOrder(
            assetAddress,
            amount,
            dest_chain_id,
            receiver,
            remark,
            channel_id
        );
    }

}