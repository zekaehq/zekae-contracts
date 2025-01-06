// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "src/SlpxContracts/interfaces/IVETH.sol";
import "src/SlpxContracts/interfaces/snowbridge/IGateway.sol";
import "src/SlpxContracts/interfaces/snowbridge/MultiAddress.sol";

contract BaseSlpx {
    address public gateway;
    address public slpcore;
    address public veth;
    uint128 public destinationFee;
    uint32 public paraId;

    constructor(address _gateway) {
        gateway = _gateway;
        slpcore = _slpcore;
        veth = _veth;
        destinationFee = _destinationFee;
        paraId = _paraId;
    }

    /*//////////////////////////////////////////////////////////////
                            CORE LOGIC
    //////////////////////////////////////////////////////////////*/
    function mint() external payable {
        uint256 fee = IGateway(gateway).quoteSendTokenFee(
            veth,
            paraId,
            destinationFee
        );
        require(msg.value >= fee, "msg.value to low");
        IVETH(slpcore).mint{value: msg.value - fee}();
        uint256 vethAmount = IERC20(veth).balanceOf(address(this));
        IERC20(veth).approve(gateway, vethAmount);
        IGateway(gateway).sendToken{value: fee}(
            veth,
            paraId,
            MultiAddress.MultiAddress({
                kind: MultiAddress.Kind.Index,
                data: abi.encode(paraId)
            }),
            destinationFee,
            uint128(vethAmount)
        );
    }


    /*//////////////////////////////////////////////////////////////
                            SETTERS
    //////////////////////////////////////////////////////////////*/
    function setGateway(address _gateway) external {
        gateway = _gateway;
    }


    function setSlpcore(address _slpcore) external {
        slpcore = _slpcore;
    }


    function setVeth(address _veth) external {
        veth = _veth;
    }


    function setDestinationFee(uint128 _destinationFee) external {
        destinationFee = _destinationFee;
    }


    function setParaId(uint32 _paraId) external {
        paraId = _paraId;
    }
}
